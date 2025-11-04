import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/audio.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../data/hebrew_letters.dart';
import '../core/base_quiz_game.dart';

/// משחק חידון אותיות: "הקש על האות <אות>"
/// מתאים לגילאי 2-6: הנחיה קולית + טקסט
/// אין חפיפות בין הכפתורים
/// אפקטים חמודים ומשוב ויזואלי/קולי
class QuizLettersGame extends FlameGame with TapCallbacks implements BaseQuizGame {
  // קונפיג
  final List<HebrewLetter> _letters = HebrewLettersData.basicLetters;
  static const double _safePadding = 40.0;

  // גודל כפתור יחסי למסך
  double get _buttonRadius => (min(size.x, size.y) * 0.12).clamp(64.0, 140.0);

  // מצב
  late HebrewLetter _target;
  final Random _rng = Random();

  // טקסט הנחיה
  late final TextComponent _instruction;

  // סאונדים
  late AudioPool _sfxPop;
  late AudioPool _sfxCorrect;
  late AudioPool _sfxWrong;
  bool soundEnabled = true;

  bool _loaded = false;

  // חשיפה ל-UI: השמעת ההנחיה מחדש / השתקה
  Future<void> replayInstruction() async {
    if (!_loaded) return;
    await _playInstructionFor(_target);
  }

  void toggleSound() {
    soundEnabled = !soundEnabled;
  }

  @override
  Future<void> onLoad() async {
    camera.viewport = FixedSizeViewport(800, 1280);
    add(ScreenHitbox());

    // טקסט הנחיה (ימין-עליון)
    _instruction = TextComponent(
      text: '',
      anchor: Anchor.topRight,
      position: Vector2(size.x - 16, 16),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          shadows: [
            Shadow(blurRadius: 6, color: Colors.black54, offset: Offset(1, 2)),
          ],
        ),
      ),
    );
    add(_instruction);

    // טעינת סאונד מראש
    FlameAudio.audioCache.prefix = 'assets/audio/';

    // אפקטים קצרים
    _sfxPop = await AudioPool.create('ui/pop.wav', maxPlayers: 6);
    _sfxCorrect = await AudioPool.create('ui/correct.wav', maxPlayers: 4);
    _sfxWrong = await AudioPool.create('ui/wrong.wav', maxPlayers: 4);

    // טעינת הוראות אותיות מראש
    try {
      for (final letter in _letters) {
        await FlameAudio.audioCache.load('letters/${letter.key}.wav');
        await FlameAudio.audioCache.load('letters/instr_${letter.key}.wav');
      }
    } catch (e) {
      debugPrint('שגיאה בטעינת קבצי אודיו: $e');
    }

    // סבב ראשון
    _newRound();

    _loaded = true;
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    if (_instruction.isMounted) {
      _instruction.position = Vector2(canvasSize.x - 16, 16);
      _instruction.anchor = Anchor.topRight;
    }
  }

  // מייצר סבב חדש
  void _newRound() {
    // מנקה כפתורים קיימים
    for (final b in children.whereType<LetterButton>()) {
      b.removeFromParent();
    }

    // בוחר 4 אותיות שונות אקראיות
    final chosen = <HebrewLetter>[];
    final available = List<HebrewLetter>.from(_letters);

    for (int i = 0; i < 4 && available.isNotEmpty; i++) {
      final letter = available.removeAt(_rng.nextInt(available.length));
      chosen.add(letter);
    }

    // אם אין מספיק אותיות, משלים מהרשימה המלאה
    while (chosen.length < 4) {
      chosen.add(_letters[chosen.length % _letters.length]);
    }

    // בוחר אות יעד מבין ה-4
    _target = chosen[_rng.nextInt(chosen.length)];

    // כותב טקסט הנחיה
    _instruction.text = 'הקש על האות ${_target.letter}';

    // ממקם 4 כפתורים ללא חפיפות
    final positions = _generateNonOverlappingPositions(
      count: chosen.length,
      radius: _buttonRadius,
    );

    for (var i = 0; i < chosen.length; i++) {
      final letter = chosen[i];
      final pos = positions[i];
      add(LetterButton(
        letter: letter,
        radius: _buttonRadius,
        center: pos,
        onTap: () => _handleTap(letter),
      ));
    }

    // משמיע הנחיה
    _playInstructionFor(_target);
  }

  // טיפול בלחיצה על כפתור
  Future<void> _handleTap(HebrewLetter tapped) async {
    if (tapped.key == _target.key) {
      await _playSuccessSequence(tapped);
      HapticFeedback.lightImpact();

      await Future<void>.delayed(const Duration(milliseconds: 250));
      _newRound();
    } else {
      if (soundEnabled) {
        _sfxWrong.start();
      }
      HapticFeedback.mediumImpact();
      _shakeInstruction();
    }
  }

  Future<void> _playSuccessSequence(HebrewLetter letter) async {
    if (!soundEnabled) return;

    // 1) פופ מיידי
    _sfxPop.start();

    // 2) הצלחה
    await Future<void>.delayed(const Duration(milliseconds: 80));
    _sfxCorrect.start();

    // 3) השמעת שם האות
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await _playInstructionFor(letter);
  }

  Future<void> _playInstructionFor(HebrewLetter letter) async {
    if (!soundEnabled) return;
    try {
      // קובץ הנחיה: "הקש על האות א"
      await FlameAudio.play('letters/instr_${letter.key}.wav');
    } catch (e) {
      // אם אין קובץ הנחיה, מנגן רק את שם האות
      try {
        await FlameAudio.play('letters/${letter.key}.wav');
      } catch (e2) {
        debugPrint('שגיאה בהשמעת הנחיה: $e2');
      }
    }
  }

  // מניעת חפיפות
  List<Vector2> _generateNonOverlappingPositions({
    required int count,
    required double radius,
  }) {
    final List<Vector2> out = [];
    final double minDist = radius * 2.2;
    final Rect safe = Rect.fromLTWH(
      _safePadding,
      _safePadding + 140,
      size.x - 2 * _safePadding,
      size.y - (2 * _safePadding + 160),
    );

    int safety = 0;
    while (out.length < count && safety < 5000) {
      safety++;
      final p = Vector2(
        safe.left + _rng.nextDouble() * safe.width,
        safe.top + _rng.nextDouble() * safe.height,
      );

      bool ok = true;
      for (final q in out) {
        if (p.distanceTo(q) < minDist) {
          ok = false;
          break;
        }
      }
      if (ok) out.add(p);
    }

    // fallback
    if (out.length < count) {
      final List<Vector2> fallbacks = [
        Vector2(safe.left + safe.width * 0.25, safe.top + safe.height * 0.25),
        Vector2(safe.left + safe.width * 0.75, safe.top + safe.height * 0.25),
        Vector2(safe.left + safe.width * 0.25, safe.top + safe.height * 0.75),
        Vector2(safe.left + safe.width * 0.75, safe.top + safe.height * 0.75),
      ];
      out
        ..clear()
        ..addAll(fallbacks.take(count));
    }

    return out;
  }

  // טלטול טקסט במקרה של טעות
  void _shakeInstruction() {
    if (!_instruction.isMounted) return;
    _instruction.add(
      MoveByEffect(
        Vector2(12, 0),
        EffectController(
          duration: 0.04,
          reverseDuration: 0.04,
          repeatCount: 3,
        ),
      ),
    );
  }
}

/// כפתור אות - עיגול צבעוני עם האות במרכז
class LetterButton extends CircleComponent with TapCallbacks {
  final HebrewLetter letter;
  final void Function() onTap;

  LetterButton({
    required this.letter,
    required double radius,
    required Vector2 center,
    required this.onTap,
  }) {
    this.radius = radius;
    this.paint = Paint()..color = letter.color.withOpacity(0.9);
    this.position = center - Vector2(radius, radius);
    anchor = Anchor.topLeft;

    // אפקט נשימה
    add(
      ScaleEffect.to(
        Vector2.all(1.05),
        EffectController(duration: 1.4, reverseDuration: 1.4, infinite: true),
      ),
    );
  }

  @override
  void onMount() {
    super.onMount();
    // הוספת טקסט האות במרכז הכפתור
    final textComponent = TextComponent(
      text: letter.letter,
      anchor: Anchor.center,
      position: Vector2(radius, radius),
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: radius * 1.2,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [
            Shadow(
              blurRadius: 8,
              color: Colors.black45,
              offset: Offset(2, 2),
            ),
          ],
        ),
      ),
    );
    add(textComponent);
  }

  @override
  void onTapDown(TapDownEvent event) {
    // אפקט לחיצה
    add(
      ScaleEffect.to(
        Vector2.all(0.9),
        EffectController(duration: 0.06, reverseDuration: 0.06),
      ),
    );
    onTap();
  }
}
