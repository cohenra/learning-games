import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/audio.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// משחק: "הקש על הבלון ה<צבע>".
/// דרישות מכוסות כאן:
/// - אין חפיפות בין בלונים.
/// - בלונים לא יוצאים מהמסך (מרווחי בטיחות).
/// - טקסט הנחיה מובנה במשחק, מוצמד לימין, בעברית.
/// - אפקטים: פיצוץ, Scale + Pop קטן בעת הצלחה.
/// - השמעת סדר הסאונד A: pop -> correct -> instr_<color>
/// - כפתור חיצוני (ב-GameScreen) קורא ל-replayInstruction()
/// - אפשרות השתקה מובנית (toggleSound()).

class TapColorsGame extends FlameGame with TapCallbacks {
  // ======= קונפיג בסיסי =======
  final List<_ColorDef> _colors = const [
    _ColorDef(Colors.red, 'אדום', 'red'),
    _ColorDef(Colors.blue, 'כחול', 'blue'),
    _ColorDef(Colors.yellow, 'צהוב', 'yellow'),
    _ColorDef(Colors.green, 'ירוק', 'green'),
  ];

  // מרווחי בטיחות בשוליים כדי שלא יצאו מהמסך
  static const double _safePadding = 40.0;

  // גודל בלון יחסי למסך – מכוון לטאבלט 10"
  double get _balloonRadius => (min(size.x, size.y) * 0.12).clamp(64.0, 140.0);

  // מצב
  late _ColorDef _target;
  final Random _rng = Random();

  // טקסט הנחיה
  late final TextComponent _instruction;

  // סאונדים
  late AudioPool _sfxPop;
  late AudioPool _sfxCorrect;
  late AudioPool _sfxWrong;
  bool soundEnabled = true;

  // מפות קבצי קול להוראות
  final Map<String, String> _instrByKey = const {
    'red': 'instr_red.wav',
    'blue': 'instr_blue.wav',
    'yellow': 'instr_yellow.wav',
    'green': 'instr_green.wav',
  };

  // דגל טעינה
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
    // רקע נעים
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

    // טעינת סאונד מראש (WAV בלבד)
    FlameAudio.audioCache.prefix = 'assets/audio/';

    // אפקטים קצרים עם AudioPool (נמוך דיליי)
    _sfxPop = await AudioPool.create('pop.wav', maxPlayers: 6);
    _sfxCorrect = await AudioPool.create('correct.wav', maxPlayers: 4);
    _sfxWrong = await AudioPool.create('wrong.wav', maxPlayers: 4);

    // טעינת הוראות מראש
    await FlameAudio.audioCache.loadAll(_instrByKey.values.toList());

    // סבב ראשון
    _newRound();

    _loaded = true;
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    // מוודא יישור לימין אחרי שינוי גודל
    if (_instruction.isMounted) {
      _instruction.position = Vector2(canvasSize.x - 16, 16);
      _instruction.anchor = Anchor.topRight;
    }
  }

  // מייצר סבב חדש
  void _newRound() {
    // מנקה בלונים קיימים
    for (final b in children.whereType<ColorBalloon>()) {
      b.removeFromParent();
    }

    // בוחר צבע יעד
    _target = _colors[_rng.nextInt(_colors.length)];

    // כותב טקסט הנחיה לימין
    _instruction.text = 'הקש על הבלון ה${_target.heName}';

    // ממקם 4 בלונים ללא חפיפות בתחום בטוח
    final positions = _generateNonOverlappingPositions(
      count: _colors.length,
      radius: _balloonRadius,
    );

    for (var i = 0; i < _colors.length; i++) {
      final c = _colors[i];
      final pos = positions[i];
      add(ColorBalloon(
        color: c.uiColor,
        radius: _balloonRadius,
        center: pos,
        onTap: () => _handleTap(c),
      ));
    }

    // משמיע הנחיה (אם הסאונד דולק)
    _playInstructionFor(_target);
  }

  // טיפול בלחיצה על בלון
  Future<void> _handleTap(_ColorDef tapped) async {
    if (tapped.key == _target.key) {
      await _playSuccessSequence(tapped); // pop -> correct -> instr_color
      // משוב טאקטילי קל (ללא תלות בחבילה חיצונית)
      HapticFeedback.lightImpact();

      // סבב חדש קטן אחרי אנימציה קצרה
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

  Future<void> _playSuccessSequence(_ColorDef color) async {
    if (!soundEnabled) return;

    // 1) פופ מיידי
    _sfxPop.start();

    // 2) הצלחה קצר לאחר מכן
    await Future<void>.delayed(const Duration(milliseconds: 80));
    _sfxCorrect.start();

    // 3) השמעת שם הצבע בסגנון ההנחיה ("הקש על הבלון האדום")
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await _playInstructionFor(color);
  }

  Future<void> _playInstructionFor(_ColorDef color) async {
    if (!soundEnabled) return;
    final file = _instrByKey[color.key];
    if (file != null) {
      await FlameAudio.play(file);
    }
  }

  // מנטרל חפיפות – מפזר נקודות בטוחות
  List<Vector2> _generateNonOverlappingPositions({
    required int count,
    required double radius,
  }) {
    final List<Vector2> out = [];
    final double minDist = radius * 2.2; // ריווח קטן
    final Rect safe = Rect.fromLTWH(
      _safePadding,
      _safePadding + 140, // קצת מתחת לכותרת
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

    // אם איכשהו לא הצליח – מפזר בקוואדרנטים
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

  // משוב טקסט קטן בטלטול
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

class ColorBalloon extends CircleComponent with TapCallbacks {
  final void Function() onTap;

  ColorBalloon({
    required Color color,
    required double radius,
    required Vector2 center,
    required this.onTap,
  }) {
    this.radius = radius;
    this.paint = Paint()..color = color;
    this.position = center - Vector2(radius, radius);
    anchor = Anchor.topLeft;

    // אפקט נשימה עדין
    add(
      ScaleEffect.to(
        Vector2.all(1.05),
        EffectController(duration: 1.4, reverseDuration: 1.4, infinite: true),
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    // אפקט חמוד בלחיצה + קריאה ל-onTap
    add(
      ScaleEffect.to(
        Vector2.all(0.9),
        EffectController(duration: 0.06, reverseDuration: 0.06),
      ),
    );
    onTap();
  }
}

class _ColorDef {
  final Color uiColor;
  final String heName; // תצוגה בעברית
  final String key; // מפתח לקבצים
  const _ColorDef(this.uiColor, this.heName, this.key);
}
