import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flame/audio.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FloatingBalloonsGame extends FlameGame with HasCollisionDetection {
  // Config
  final List<_ColorDef> _colors = const [
    _ColorDef(Colors.red, 'אדום', 'red'),
    _ColorDef(Colors.blue, 'כחול', 'blue'),
    _ColorDef(Colors.yellow, 'צהוב', 'yellow'),
    _ColorDef(Colors.green, 'ירוק', 'green'),
  ];

  late _ColorDef _target;
  final Random _rng = Random();

  // State
  int _correctCount = 0;
  static const int _requiredCorrect = 5;
  bool _soundEnabled = true;
  bool _loaded = false;

  // Components
  late final TextComponent _instruction;
  late final Timer _spawnTimer;

  // Audio
  late AudioPool _sfxPop;
  late AudioPool _sfxCorrect;
  late AudioPool _sfxWrong;
  final Map<String, String> _instrByKey = const {
    'red': 'instr_red.wav',
    'blue': 'instr_blue.wav',
    'yellow': 'instr_yellow.wav',
    'green': 'instr_green.wav',
  };

  // Cached Sprites
  final Map<String, Sprite> _balloonSprites = {};

  @override
  Future<void> onLoad() async {
    // Viewport setup
    camera.viewport = FixedSizeViewport(800, 1280);

    // Load Audio
    FlameAudio.audioCache.prefix = 'assets/audio/';
    _sfxPop = await AudioPool.create('pop.wav', maxPlayers: 6);
    _sfxCorrect = await AudioPool.create('correct.wav', maxPlayers: 4);
    _sfxWrong = await AudioPool.create('wrong.wav', maxPlayers: 4);
    await FlameAudio.audioCache.loadAll(_instrByKey.values.toList());

    // Generate Sprites
    for (final colorDef in _colors) {
      final image = await _generateBalloonImage(colorDef.uiColor);
      _balloonSprites[colorDef.key] = Sprite(image);
    }

    // Instruction Text
    _instruction = TextComponent(
      text: '',
      anchor: Anchor.topRight,
      position: Vector2(size.x - 20, 20),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          shadows: [
            Shadow(blurRadius: 6, color: Colors.black54, offset: Offset(1, 2)),
          ],
          fontFamily: 'Arial', // Ensure a font that supports Hebrew is used if available, or system default
        ),
      ),
    );
    add(_instruction);

    // Spawn Timer
    _spawnTimer = Timer(1.2, repeat: true, onTick: _spawnBalloon);
    _spawnTimer.start();

    // Start First Round
    _newRound();

    _loaded = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _spawnTimer.update(dt);
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    if (_instruction.isMounted) {
      _instruction.position = Vector2(canvasSize.x - 20, 20);
    }
  }

  void _newRound() {
    _correctCount = 0;
    // Ensure we pick a different color if possible, or just random
    _ColorDef newTarget;
    do {
      newTarget = _colors[_rng.nextInt(_colors.length)];
    } while (_colors.length > 1 && _loaded && newTarget.key == _target.key);

    _target = newTarget;

    // Update text
    _instruction.text = 'הקש על הבלון ה${_target.heName}';

    // Play instruction
    replayInstruction();
  }

  void _spawnBalloon() {
    // 40% chance to spawn target color, else random
    _ColorDef colorToSpawn;
    if (_rng.nextDouble() < 0.4) {
      colorToSpawn = _target;
    } else {
      colorToSpawn = _colors[_rng.nextInt(_colors.length)];
    }

    final double radius = 50 + _rng.nextDouble() * 20; // Radius between 50 and 70
    final double xPos = radius + _rng.nextDouble() * (size.x - 2 * radius);

    // Create balloon at bottom
    final balloon = Balloon(
      sprite: _balloonSprites[colorToSpawn.key]!,
      colorDef: colorToSpawn,
      gameRef: this,
      position: Vector2(xPos, size.y + radius * 2),
      size: Vector2.all(radius * 2.5), // Slightly taller than wide usually, but sprite is square-ish
      speed: 100 + _rng.nextDouble() * 150, // Speed 100-250
    );

    add(balloon);
  }

  // --- Interaction Logic ---

  Future<void> handleBalloonTap(Balloon balloon) async {
    if (balloon.colorDef.key == _target.key) {
      // Correct!
      _correctCount++;

      // Visuals
      _spawnExplosion(balloon.position, balloon.colorDef.uiColor);
      balloon.pop();

      // Audio
      if (_soundEnabled) {
        _sfxPop.start();
        Future.delayed(const Duration(milliseconds: 100), () => _sfxCorrect.start());
      }
      HapticFeedback.lightImpact();

      // Check win condition
      if (_correctCount >= _requiredCorrect) {
        await Future.delayed(const Duration(milliseconds: 500));
        _spawnCelebration();
        _newRound();
      }
    } else {
      // Wrong!
      balloon.wobbleError();
      if (_soundEnabled) _sfxWrong.start();
      HapticFeedback.mediumImpact();
      _shakeInstruction();
    }
  }

  void _spawnExplosion(Vector2 position, Color color) {
    add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 20,
          lifespan: 0.8,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 200),
            speed: Vector2(_rng.nextDouble() * 400 - 200, _rng.nextDouble() * 400 - 200),
            position: Vector2.zero(),
            child: CircleParticle(
              radius: 4,
              paint: Paint()..color = color,
            ),
          ),
        ),
      ),
    );
  }

  void _spawnCelebration() {
    // Big confetti
    for (int i = 0; i < 5; i++) {
        Future.delayed(Duration(milliseconds: i * 200), () {
            _spawnExplosion(Vector2(size.x / 2, size.y / 2), _colors[_rng.nextInt(_colors.length)].uiColor);
        });
    }
  }

  void _shakeInstruction() {
    _instruction.add(
      MoveByEffect(
        Vector2(10, 0),
        EffectController(duration: 0.05, reverseDuration: 0.05, repeatCount: 4),
      ),
    );
  }

  // --- External Interface ---

  Future<void> replayInstruction() async {
    if (!_loaded) return;
    if (_soundEnabled) {
      final file = _instrByKey[_target.key];
      if (file != null) {
        await FlameAudio.play(file);
      }
    }
  }

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  // --- Helpers ---

  Future<ui.Image> _generateBalloonImage(Color color) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(100, 120);

    // Balloon body
    final paint = Paint()..color = color;
    final path = Path();
    path.addOval(Rect.fromLTWH(0, 0, 100, 110));
    canvas.drawPath(path, paint);

    // Knot
    final knotPath = Path();
    knotPath.moveTo(45, 108);
    knotPath.lineTo(55, 108);
    knotPath.lineTo(50, 118);
    knotPath.close();
    canvas.drawPath(knotPath, paint);

    // Shine (Reflection)
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawOval(const Rect.fromLTWH(20, 20, 20, 30), shinePaint);

    // String
    final stringPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(
      Path()
        ..moveTo(50, 118)
        ..quadraticBezierTo(50, 130, 45, 140),
      stringPaint,
    );

    final picture = recorder.endRecording();
    return picture.toImage(100, 140);
  }
}

class Balloon extends SpriteComponent with TapCallbacks {
  final _ColorDef colorDef;
  final FloatingBalloonsGame gameRef;
  final double speed;

  double _time = 0;
  final double _wobbleOffset;

  Balloon({
    required Sprite sprite,
    required this.colorDef,
    required this.gameRef,
    required Vector2 position,
    required Vector2 size,
    required this.speed,
  }) : _wobbleOffset = Random().nextDouble() * 100,
       super(sprite: sprite, position: position, size: size, anchor: Anchor.center) {
    // Pop in effect
    scale = Vector2.zero();
    add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.5, curve: Curves.elasticOut)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    // Floating up
    position.y -= speed * dt;

    // Wobble
    position.x += sin(_time * 2 + _wobbleOffset) * 0.5;
    angle = sin(_time * 1.5 + _wobbleOffset) * 0.05;

    // Destroy if off screen
    if (position.y < -height) {
      removeFromParent();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    gameRef.handleBalloonTap(this);
  }

  void pop() {
    // Remove with effect
    add(
      ScaleEffect.to(
        Vector2.zero(),
        EffectController(duration: 0.1),
        onComplete: () => removeFromParent(),
      ),
    );
  }

  void wobbleError() {
    add(
      RotateEffect.by(
        0.5,
        EffectController(
          duration: 0.1,
          reverseDuration: 0.1,
          repeatCount: 2,
        ),
      ),
    );
  }
}

class _ColorDef {
  final Color uiColor;
  final String heName;
  final String key;
  const _ColorDef(this.uiColor, this.heName, this.key);
}
