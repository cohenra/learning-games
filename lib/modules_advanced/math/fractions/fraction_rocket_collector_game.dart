import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'dart:async';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/kid_back_button.dart';

/// משחק Fraction Rocket Collector - אסוף שברים בחלל!
class FractionRocketCollectorGame extends StatefulWidget {
  const FractionRocketCollectorGame({super.key});

  @override
  State<FractionRocketCollectorGame> createState() =>
      _FractionRocketCollectorGameState();
}

class _FractionRocketCollectorGameState
    extends State<FractionRocketCollectorGame>
    with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();
  bool _isHebrew = true;

  // Game state
  int _currentLevel = 1;
  final int _maxLevels = 5;
  int _score = 0;
  double _collected = 0.0; // Sum of collected fractions
  bool _gameOver = false;
  bool _levelComplete = false;

  // Rocket position (0.0 to 1.0)
  double _rocketX = 0.5;
  double _rocketY = 0.7;

  // Game objects
  List<FallingFraction> _fallingFractions = [];
  List<Obstacle> _obstacles = [];
  List<Particle> _particles = [];
  Timer? _gameTimer;
  Timer? _spawnTimer;

  // Animations
  late AnimationController _rocketFlameController;
  late AnimationController _explosionController;
  late AnimationController _starfieldController;
  late AnimationController _particleController;
  late Animation<double> _flameAnimation;
  late Animation<double> _explosionAnimation;
  late Animation<double> _starfieldAnimation;

  bool _showExplosion = false;
  Offset? _explosionPosition;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initTts();
    _initAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isHebrew = Localizations.localeOf(context).languageCode == 'he';
      });
      _startLevel();
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage(_isHebrew ? 'he-IL' : 'en-US');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
  }

  void _initAnimations() {
    _rocketFlameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..repeat(reverse: true);
    _flameAnimation =
        Tween<double>(begin: 0.8, end: 1.2).animate(_rocketFlameController);

    _explosionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _explosionAnimation = CurvedAnimation(
      parent: _explosionController,
      curve: Curves.easeOut,
    );

    _starfieldController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _starfieldAnimation =
        Tween<double>(begin: 0, end: 1).animate(_starfieldController);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..addListener(() {
        if (!mounted) return;
        setState(() {
          _particles = _particles.map((p) => p.update()).toList();
          _particles.removeWhere((p) => p.life <= 0);
        });
      });
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _startLevel() {
    setState(() {
      _collected = 0.0;
      _fallingFractions.clear();
      _obstacles.clear();
      _particles.clear();
      _gameOver = false;
      _levelComplete = false;
    });

    _speak(_isHebrew
        ? 'שלב $_currentLevel! אסוף שברים עד 1 שלם!'
        : 'Level $_currentLevel! Collect fractions up to 1 whole!');

    _startGameLoop();
    _startSpawning();
  }

  void _startGameLoop() {
    _gameTimer?.cancel();
    final speed = 16; // 60 FPS
    _gameTimer = Timer.periodic(Duration(milliseconds: speed), (timer) {
      if (!mounted || _gameOver || _levelComplete) {
        timer.cancel();
        return;
      }
      _updateGame();
    });
  }

  void _startSpawning() {
    _spawnTimer?.cancel();
    final spawnInterval = (1000 - (_currentLevel * 150)).clamp(300, 1000);
    _spawnTimer =
        Timer.periodic(Duration(milliseconds: spawnInterval), (timer) {
      if (!mounted || _gameOver || _levelComplete) {
        timer.cancel();
        return;
      }
      _spawnGameObject();
    });
  }

  void _spawnGameObject() {
    // 70% chance for fraction, 30% for obstacle
    if (_random.nextDouble() < 0.7) {
      _spawnFraction();
    } else {
      _spawnObstacle();
    }
  }

  void _spawnFraction() {
    // Create fractions that make sense
    final fractions = [
      [1, 2],
      [1, 3],
      [2, 3],
      [1, 4],
      [3, 4],
      [1, 5],
      [2, 5],
      [3, 5],
      [4, 5],
      [1, 6],
      [5, 6],
      [1, 8],
      [3, 8],
      [5, 8],
      [7, 8]
    ];

    final fraction = fractions[_random.nextInt(fractions.length)];
    final newFraction = FallingFraction(
      numerator: fraction[0],
      denominator: fraction[1],
      x: _random.nextDouble() * 0.8 + 0.1, // 0.1 to 0.9
      y: -0.1,
      speed: 0.003 + (_currentLevel * 0.001),
      color: _getFractionColor(fraction[0], fraction[1]),
    );

    setState(() {
      _fallingFractions.add(newFraction);
    });
  }

  Color _getFractionColor(int numerator, int denominator) {
    final value = numerator / denominator;
    if (value <= 0.25) return Colors.blue;
    if (value <= 0.5) return Colors.green;
    if (value <= 0.75) return Colors.orange;
    return Colors.purple;
  }

  void _spawnObstacle() {
    final obstacle = Obstacle(
      x: _random.nextDouble() * 0.8 + 0.1,
      y: -0.1,
      speed: 0.004 + (_currentLevel * 0.0015),
      type: _random.nextInt(3), // 0: asteroid, 1: black hole, 2: laser
    );

    setState(() {
      _obstacles.add(obstacle);
    });
  }

  void _updateGame() {
    setState(() {
      // Update fractions
      for (int i = _fallingFractions.length - 1; i >= 0; i--) {
        _fallingFractions[i] = _fallingFractions[i].update();

        // Check collision with rocket
        if (_checkCollision(
            _fallingFractions[i].x, _fallingFractions[i].y, _rocketX, _rocketY)) {
          _collectFraction(_fallingFractions[i]);
          _fallingFractions.removeAt(i);
        }
        // Remove if off screen
        else if (_fallingFractions[i].y > 1.1) {
          _fallingFractions.removeAt(i);
        }
      }

      // Update obstacles
      for (int i = _obstacles.length - 1; i >= 0; i--) {
        _obstacles[i] = _obstacles[i].update();

        // Check collision with rocket
        if (_checkCollision(
            _obstacles[i].x, _obstacles[i].y, _rocketX, _rocketY)) {
          _hitObstacle(_obstacles[i]);
          _obstacles.removeAt(i);
        }
        // Remove if off screen
        else if (_obstacles[i].y > 1.1) {
          _obstacles.removeAt(i);
        }
      }
    });
  }

  bool _checkCollision(double x1, double y1, double x2, double y2) {
    final distance = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
    return distance < 0.08;
  }

  void _collectFraction(FallingFraction fraction) {
    final value = fraction.numerator / fraction.denominator;
    final newTotal = _collected + value;

    // Create particles at collection point
    _createCollectionParticles(fraction.x, fraction.y, fraction.color);

    if (newTotal > 1.0) {
      // BOOM! Over 1!
      _explode();
    } else {
      setState(() {
        _collected = newTotal;
        _score += 10 * _currentLevel;
      });

      if ((_collected - 1.0).abs() < 0.001) {
        // Exactly 1!
        _completeLevel();
      }
    }
  }

  void _hitObstacle(Obstacle obstacle) {
    _createExplosionParticles(_rocketX, _rocketY);
    _explode();
  }

  void _explode() {
    setState(() {
      _showExplosion = true;
      _explosionPosition = Offset(_rocketX, _rocketY);
      _gameOver = true;
    });

    _explosionController.forward(from: 0);
    _speak(_isHebrew ? 'בום! נסה שוב!' : 'Boom! Try again!');

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _showGameOverDialog();
    });
  }

  void _completeLevel() {
    setState(() {
      _levelComplete = true;
      _score += 50 * _currentLevel;
    });

    _createSuccessParticles(_rocketX, _rocketY);
    _speak(_isHebrew ? 'מושלם! שלב הושלם!' : 'Perfect! Level complete!');

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      if (_currentLevel >= _maxLevels) {
        _showVictoryDialog();
      } else {
        setState(() {
          _currentLevel++;
        });
        _startLevel();
      }
    });
  }

  void _createCollectionParticles(double x, double y, Color color) {
    final newParticles = List.generate(10, (i) {
      final angle = (i / 10) * 2 * pi;
      return Particle(
        x: x,
        y: y,
        vx: cos(angle) * 0.01,
        vy: sin(angle) * 0.01,
        color: color,
        size: 3 + _random.nextDouble() * 4,
        life: 1.0,
      );
    });
    setState(() => _particles.addAll(newParticles));
    _particleController.forward(from: 0);
  }

  void _createExplosionParticles(double x, double y) {
    final newParticles = List.generate(30, (i) {
      final angle = (i / 30) * 2 * pi;
      return Particle(
        x: x,
        y: y,
        vx: cos(angle) * 0.015,
        vy: sin(angle) * 0.015,
        color: [Colors.red, Colors.orange, Colors.yellow][_random.nextInt(3)],
        size: 4 + _random.nextDouble() * 8,
        life: 1.0,
      );
    });
    setState(() => _particles.addAll(newParticles));
    _particleController.forward(from: 0);
  }

  void _createSuccessParticles(double x, double y) {
    final newParticles = List.generate(40, (i) {
      final angle = (i / 40) * 2 * pi;
      return Particle(
        x: x,
        y: y,
        vx: cos(angle) * 0.02,
        vy: sin(angle) * 0.02,
        color: [Colors.yellow, Colors.cyan, Colors.pink, Colors.lime]
            [_random.nextInt(4)],
        size: 4 + _random.nextDouble() * 10,
        life: 1.0,
      );
    });
    setState(() => _particles.addAll(newParticles));
    _particleController.forward(from: 0);
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.red.shade100, Colors.orange.shade100],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💥', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                _isHebrew ? 'נפץ!' : 'Exploded!',
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                _isHebrew ? 'ניקוד סופי:' : 'Final Score:',
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                '$_score',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text(_isHebrew ? 'יציאה' : 'Exit'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _score = 0;
                        _currentLevel = 1;
                      });
                      _startLevel();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                    ),
                    child: Text(_isHebrew ? 'שחק שוב' : 'Play Again'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.yellow.shade100, Colors.green.shade100],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆🚀🏆', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                _isHebrew ? 'ניצחון!' : 'Victory!',
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                _isHebrew
                    ? 'השלמת את כל השלבים!'
                    : 'You completed all levels!',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _isHebrew ? 'ניקוד סופי:' : 'Final Score:',
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                '$_score',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text(_isHebrew ? 'יציאה' : 'Exit'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _score = 0;
                        _currentLevel = 1;
                      });
                      _startLevel();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                    ),
                    child: Text(_isHebrew ? 'שחק שוב' : 'Play Again'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _rocketFlameController.dispose();
    _explosionController.dispose();
    _starfieldController.dispose();
    _particleController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    _isHebrew = Localizations.localeOf(context).languageCode == 'he';

    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          if (_gameOver || _levelComplete) return;
          setState(() {
            _rocketX = (details.localPosition.dx / responsive.screenWidth)
                .clamp(0.1, 0.9);
            _rocketY = (details.localPosition.dy / responsive.screenHeight)
                .clamp(0.1, 0.9);
          });
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF000428),
                const Color(0xFF004e92),
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Starfield background
                AnimatedBuilder(
                  animation: _starfieldAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: StarfieldPainter(_starfieldAnimation.value),
                      size: Size.infinite,
                    );
                  },
                ),

                // Game objects
                CustomPaint(
                  painter: GameObjectsPainter(
                    fallingFractions: _fallingFractions,
                    obstacles: _obstacles,
                    rocketX: _rocketX,
                    rocketY: _rocketY,
                    flameValue: _flameAnimation.value,
                    showExplosion: _showExplosion,
                    explosionPosition: _explosionPosition,
                    explosionValue: _explosionAnimation.value,
                  ),
                  size: Size.infinite,
                ),

                // Particles
                if (_particles.isNotEmpty)
                  CustomPaint(
                    painter: ParticlePainter(_particles),
                    size: Size.infinite,
                  ),

                // UI
                Column(
                  children: [
                    _buildHeader(responsive),
                    const Spacer(),
                    _buildFuelMeter(responsive),
                    SizedBox(height: responsive.spacing(16)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(12)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          KidBackButton(
            onPressed: () => Navigator.pop(context),
            color: Colors.cyan.shade300,
            isHebrew: _isHebrew,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatBadge(
                  responsive,
                  '🚀',
                  _isHebrew ? 'שלב' : 'Level',
                  '$_currentLevel/$_maxLevels',
                ),
                _buildStatBadge(
                  responsive,
                  '⭐',
                  _isHebrew ? 'ניקוד' : 'Score',
                  '$_score',
                ),
              ],
            ),
          ),
          SizedBox(width: responsive.spacing(48)),
        ],
      ),
    );
  }

  Widget _buildStatBadge(
      ResponsiveHelper responsive, String emoji, String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing(12),
        vertical: responsive.spacing(8),
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan.shade300, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: responsive.iconSize(20))),
          SizedBox(width: responsive.spacing(6)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: responsive.fontSize(10),
                  color: Colors.cyan.shade200,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: responsive.fontSize(16),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFuelMeter(ResponsiveHelper responsive) {
    final percentage = _collected.clamp(0.0, 1.0);
    final isOverfull = _collected > 1.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
      padding: EdgeInsets.all(responsive.spacing(12)),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverfull ? Colors.red : Colors.cyan.shade300,
          width: 3,
        ),
      ),
      child: Column(
        children: [
          Text(
            _isHebrew ? 'מד דלק (יעד: 1 שלם)' : 'Fuel Meter (Target: 1 whole)',
            style: TextStyle(
              fontSize: responsive.fontSize(14),
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive.spacing(8)),
          Stack(
            children: [
              Container(
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 30,
                width: responsive.screenWidth * 0.8 * percentage,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isOverfull
                        ? [Colors.red.shade700, Colors.red.shade900]
                        : percentage < 0.5
                            ? [Colors.blue.shade400, Colors.blue.shade600]
                            : percentage < 0.8
                                ? [Colors.green.shade400, Colors.green.shade600]
                                : [
                                    Colors.yellow.shade400,
                                    Colors.orange.shade600
                                  ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              Container(
                height: 30,
                alignment: Alignment.center,
                child: Text(
                  '${(_collected * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: responsive.fontSize(16),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Data classes
class FallingFraction {
  final int numerator;
  final int denominator;
  final double x;
  final double y;
  final double speed;
  final Color color;

  FallingFraction({
    required this.numerator,
    required this.denominator,
    required this.x,
    required this.y,
    required this.speed,
    required this.color,
  });

  FallingFraction update() {
    return FallingFraction(
      numerator: numerator,
      denominator: denominator,
      x: x,
      y: y + speed,
      speed: speed,
      color: color,
    );
  }
}

class Obstacle {
  final double x;
  final double y;
  final double speed;
  final int type;

  Obstacle({
    required this.x,
    required this.y,
    required this.speed,
    required this.type,
  });

  Obstacle update() {
    return Obstacle(
      x: x,
      y: y + speed,
      speed: speed,
      type: type,
    );
  }
}

class Particle {
  final double x;
  final double y;
  final double vx;
  final double vy;
  final Color color;
  final double size;
  final double life;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.life,
  });

  Particle update() {
    return Particle(
      x: x + vx,
      y: y + vy,
      vx: vx,
      vy: vy + 0.0005, // Gravity
      color: color,
      size: size * 0.96,
      life: life - 0.02,
    );
  }
}

// Painters
class StarfieldPainter extends CustomPainter {
  final double animationValue;
  final Random _random = Random(42); // Fixed seed for consistent stars

  StarfieldPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (int i = 0; i < 100; i++) {
      final x = _random.nextDouble() * size.width;
      final y = (_random.nextDouble() * size.height + animationValue * size.height) %
          size.height;
      final starSize = _random.nextDouble() * 2 + 0.5;

      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }

  @override
  bool shouldRepaint(StarfieldPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class GameObjectsPainter extends CustomPainter {
  final List<FallingFraction> fallingFractions;
  final List<Obstacle> obstacles;
  final double rocketX;
  final double rocketY;
  final double flameValue;
  final bool showExplosion;
  final Offset? explosionPosition;
  final double explosionValue;

  GameObjectsPainter({
    required this.fallingFractions,
    required this.obstacles,
    required this.rocketX,
    required this.rocketY,
    required this.flameValue,
    required this.showExplosion,
    required this.explosionPosition,
    required this.explosionValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw fractions
    for (final fraction in fallingFractions) {
      _drawFraction(canvas, size, fraction);
    }

    // Draw obstacles
    for (final obstacle in obstacles) {
      _drawObstacle(canvas, size, obstacle);
    }

    // Draw rocket
    if (!showExplosion) {
      _drawRocket(canvas, size);
    }

    // Draw explosion
    if (showExplosion && explosionPosition != null) {
      _drawExplosion(canvas, size);
    }
  }

  void _drawFraction(Canvas canvas, Size size, FallingFraction fraction) {
    final center = Offset(fraction.x * size.width, fraction.y * size.height);

    // Draw star shape
    final starPath = Path();
    final outerRadius = 25.0;
    final innerRadius = 12.0;
    final points = 5;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * pi / points) - pi / 2;
      final x = center.dx + cos(angle) * radius;
      final y = center.dy + sin(angle) * radius;

      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();

    // Draw star with gradient
    final starPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          fraction.color.withOpacity(0.9),
          fraction.color.withOpacity(0.6),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius));

    canvas.drawPath(starPath, starPaint);

    // Draw glow
    final glowPaint = Paint()
      ..color = fraction.color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawPath(starPath, glowPaint);

    // Draw fraction text
    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${fraction.numerator}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const TextSpan(
            text: '/',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          TextSpan(
            text: '${fraction.denominator}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawObstacle(Canvas canvas, Size size, Obstacle obstacle) {
    final center = Offset(obstacle.x * size.width, obstacle.y * size.height);

    switch (obstacle.type) {
      case 0: // Asteroid
        _drawAsteroid(canvas, center);
        break;
      case 1: // Black hole
        _drawBlackHole(canvas, center);
        break;
      case 2: // Laser
        _drawLaser(canvas, center, size);
        break;
    }
  }

  void _drawAsteroid(Canvas canvas, Offset center) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.grey.shade700, Colors.grey.shade900],
      ).createShader(Rect.fromCircle(center: center, radius: 30));

    // Irregular shape
    final path = Path();
    final angles = [0, 60, 120, 180, 240, 300];
    for (int i = 0; i < angles.length; i++) {
      final angle = angles[i] * pi / 180;
      final radius = 25 + (i % 2) * 10.0;
      final x = center.dx + cos(angle) * radius;
      final y = center.dy + sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawBlackHole(Canvas canvas, Offset center) {
    // Outer ring
    for (int i = 3; i > 0; i--) {
      final paint = Paint()
        ..color = Colors.purple.withOpacity(0.3 * i / 3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(center, 20.0 + i * 10, paint);
    }

    // Black center
    final centerPaint = Paint()..color = Colors.black;
    canvas.drawCircle(center, 20, centerPaint);
  }

  void _drawLaser(Canvas canvas, Offset center, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.red.shade900, Colors.red.shade400],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(center.dx - 15, 0, 30, size.height))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawRect(
      Rect.fromLTWH(center.dx - 15, 0, 30, size.height),
      paint,
    );
  }

  void _drawRocket(Canvas canvas, Size size) {
    final center = Offset(rocketX * size.width, rocketY * size.height);

    // Draw flame first (behind rocket)
    _drawFlame(canvas, center);

    // Rocket body
    final rocketPath = Path();
    rocketPath.moveTo(center.dx, center.dy - 40); // Nose
    rocketPath.lineTo(center.dx - 15, center.dy + 20);
    rocketPath.lineTo(center.dx - 15, center.dy + 30);
    rocketPath.lineTo(center.dx + 15, center.dy + 30);
    rocketPath.lineTo(center.dx + 15, center.dy + 20);
    rocketPath.close();

    final rocketPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.cyan.shade400, Colors.blue.shade700],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(
        center.dx - 15,
        center.dy - 40,
        center.dx + 15,
        center.dy + 30,
      ));

    canvas.drawPath(rocketPath, rocketPaint);

    // Window
    final windowPaint = Paint()..color = Colors.lightBlue.shade100;
    canvas.drawCircle(Offset(center.dx, center.dy - 10), 8, windowPaint);

    // Wings
    final wingPaint = Paint()..color = Colors.red.shade600;
    final leftWing = Path()
      ..moveTo(center.dx - 15, center.dy + 10)
      ..lineTo(center.dx - 30, center.dy + 25)
      ..lineTo(center.dx - 15, center.dy + 25)
      ..close();
    canvas.drawPath(leftWing, wingPaint);

    final rightWing = Path()
      ..moveTo(center.dx + 15, center.dy + 10)
      ..lineTo(center.dx + 30, center.dy + 25)
      ..lineTo(center.dx + 15, center.dy + 25)
      ..close();
    canvas.drawPath(rightWing, wingPaint);
  }

  void _drawFlame(Canvas canvas, Offset center) {
    final flamePath = Path();
    final flameHeight = 30 * flameValue;

    flamePath.moveTo(center.dx - 12, center.dy + 30);
    flamePath.quadraticBezierTo(
      center.dx,
      center.dy + 30 + flameHeight,
      center.dx + 12,
      center.dy + 30,
    );
    flamePath.close();

    final flamePaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.yellow, Colors.orange, Colors.red],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(
        center.dx - 12,
        center.dy + 30,
        24,
        flameHeight,
      ));

    canvas.drawPath(flamePath, flamePaint);

    // Inner flame
    final innerFlamePath = Path();
    innerFlamePath.moveTo(center.dx - 6, center.dy + 30);
    innerFlamePath.quadraticBezierTo(
      center.dx,
      center.dy + 30 + flameHeight * 0.7,
      center.dx + 6,
      center.dy + 30,
    );
    innerFlamePath.close();

    final innerFlamePaint = Paint()..color = Colors.yellow.shade100;
    canvas.drawPath(innerFlamePath, innerFlamePaint);
  }

  void _drawExplosion(Canvas canvas, Size size) {
    final center =
        Offset(explosionPosition!.dx * size.width, explosionPosition!.dy * size.height);

    // Multiple explosion circles
    for (int i = 0; i < 3; i++) {
      final radius = (50 + i * 30) * explosionValue;
      final paint = Paint()
        ..color = [Colors.yellow, Colors.orange, Colors.red][i]
            .withOpacity((1 - explosionValue) * 0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(GameObjectsPainter oldDelegate) => true;
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.life * 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
