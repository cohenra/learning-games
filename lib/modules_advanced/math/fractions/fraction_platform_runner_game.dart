import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'dart:async';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/kid_back_button.dart';

/// משחק Fraction Platform Runner - ריצה אינסופית עם שברים!
class FractionPlatformRunnerGame extends StatefulWidget {
  const FractionPlatformRunnerGame({super.key});

  @override
  State<FractionPlatformRunnerGame> createState() =>
      _FractionPlatformRunnerGameState();
}

class _FractionPlatformRunnerGameState
    extends State<FractionPlatformRunnerGame>
    with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();
  bool _isHebrew = true;

  // Game state
  int _score = 0;
  int _distance = 0;
  double _gameSpeed = 0.005;
  bool _gameOver = false;
  bool _hasShield = false;
  bool _hasMagnet = false;

  // Player state
  int _currentLane = 1; // 0=top, 1=middle, 2=bottom
  bool _isJumping = false;
  double _jumpHeight = 0.0;
  bool _canDoubleJump = false;
  bool _hasUsedDoubleJump = false;

  // Current question
  int? _targetNumerator;
  int? _targetDenominator;

  // Game objects
  List<Platform> _platforms = [];
  List<Obstacle> _obstacles = [];
  List<Coin> _coins = [];
  List<PowerUp> _powerUps = [];
  List<Particle> _particles = [];
  Timer? _gameTimer;

  // Animations
  late AnimationController _runController;
  late AnimationController _particleController;
  late AnimationController _shieldController;
  late Animation<double> _runAnimation;
  late Animation<double> _shieldAnimation;

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
      _startGame();
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage(_isHebrew ? 'he-IL' : 'en-US');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
  }

  void _initAnimations() {
    _runController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);
    _runAnimation = Tween<double>(begin: 0, end: 1).animate(_runController);

    _shieldController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _shieldAnimation = Tween<double>(begin: 0, end: 1).animate(_shieldController);

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

  void _startGame() {
    setState(() {
      _score = 0;
      _distance = 0;
      _gameSpeed = 0.005;
      _gameOver = false;
      _currentLane = 1;
      _isJumping = false;
      _jumpHeight = 0.0;
      _hasShield = false;
      _hasMagnet = false;
      _canDoubleJump = false;
      _hasUsedDoubleJump = false;
      _platforms.clear();
      _obstacles.clear();
      _coins.clear();
      _powerUps.clear();
      _particles.clear();
    });

    _generateQuestion();
    _initializeLevel();
    _startGameLoop();
  }

  void _generateQuestion() {
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

    final target = fractions[_random.nextInt(fractions.length)];
    setState(() {
      _targetNumerator = target[0];
      _targetDenominator = target[1];
    });

    _speak(_isHebrew
        ? 'קפוץ על $_targetNumerator חלקי $_targetDenominator'
        : 'Jump on $_targetNumerator divided by $_targetDenominator');
  }

  void _initializeLevel() {
    // Create initial platforms
    for (int i = 0; i < 10; i++) {
      _spawnPlatform(0.3 + i * 0.2);
    }

    // Create initial obstacles and coins
    for (int i = 0; i < 5; i++) {
      if (_random.nextDouble() < 0.3) {
        _spawnObstacle(0.5 + i * 0.3);
      }
      if (_random.nextDouble() < 0.4) {
        _spawnCoin(0.5 + i * 0.25);
      }
    }
  }

  void _startGameLoop() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted || _gameOver) {
        timer.cancel();
        return;
      }
      _updateGame();
    });
  }

  void _updateGame() {
    setState(() {
      // Increase speed over time
      _distance++;
      if (_distance % 500 == 0) {
        _gameSpeed = (_gameSpeed * 1.1).clamp(0.005, 0.015);
      }

      // Update jump
      if (_isJumping) {
        _jumpHeight += 0.04;
        if (_jumpHeight >= 1.0) {
          _jumpHeight = 0.0;
          _isJumping = false;
          _hasUsedDoubleJump = false;
        }
      }

      // Update platforms
      for (int i = _platforms.length - 1; i >= 0; i--) {
        _platforms[i] = _platforms[i].update(_gameSpeed);

        // Check if player landed on platform
        if (_platforms[i].x < 0.25 &&
            _platforms[i].x > 0.15 &&
            _platforms[i].lane == _currentLane &&
            !_isJumping) {
          // Check if it's the correct fraction
          if (_platforms[i].numerator == _targetNumerator &&
              _platforms[i].denominator == _targetDenominator) {
            _collectPlatform(_platforms[i]);
          }
        }

        // Remove if off screen
        if (_platforms[i].x < -0.2) {
          _platforms.removeAt(i);
        }
      }

      // Spawn new platforms
      if (_platforms.isEmpty || _platforms.last.x < 0.8) {
        _spawnPlatform(1.2);
      }

      // Update obstacles
      for (int i = _obstacles.length - 1; i >= 0; i--) {
        _obstacles[i] = _obstacles[i].update(_gameSpeed);

        // Check collision with player
        if (_obstacles[i].x < 0.25 &&
            _obstacles[i].x > 0.15 &&
            _obstacles[i].lane == _currentLane &&
            !_isJumping) {
          _hitObstacle();
          _obstacles.removeAt(i);
        }
        // Remove if off screen
        else if (_obstacles[i].x < -0.2) {
          _obstacles.removeAt(i);
        }
      }

      // Update coins
      for (int i = _coins.length - 1; i >= 0; i--) {
        _coins[i] = _coins[i].update(_gameSpeed);

        // Check collection
        final distance = sqrt(pow(_coins[i].x - 0.2, 2) +
            pow((_coins[i].lane * 0.33) - (_currentLane * 0.33), 2));
        if (distance < 0.1 || (_hasMagnet && distance < 0.3)) {
          _collectCoin(_coins[i]);
          _coins.removeAt(i);
        }
        // Remove if off screen
        else if (_coins[i].x < -0.2) {
          _coins.removeAt(i);
        }
      }

      // Spawn coins
      if (_random.nextDouble() < 0.02) {
        _spawnCoin(1.2);
      }

      // Update power-ups
      for (int i = _powerUps.length - 1; i >= 0; i--) {
        _powerUps[i] = _powerUps[i].update(_gameSpeed);

        // Check collection
        if (_powerUps[i].x < 0.25 &&
            _powerUps[i].x > 0.15 &&
            _powerUps[i].lane == _currentLane) {
          _collectPowerUp(_powerUps[i]);
          _powerUps.removeAt(i);
        }
        // Remove if off screen
        else if (_powerUps[i].x < -0.2) {
          _powerUps.removeAt(i);
        }
      }

      // Spawn obstacles
      if (_random.nextDouble() < 0.015) {
        _spawnObstacle(1.2);
      }

      // Spawn power-ups
      if (_random.nextDouble() < 0.005) {
        _spawnPowerUp(1.2);
      }
    });
  }

  void _spawnPlatform(double x) {
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
    final platform = Platform(
      numerator: fraction[0],
      denominator: fraction[1],
      x: x,
      lane: _random.nextInt(3),
      color: _getFractionColor(fraction[0], fraction[1]),
    );

    setState(() {
      _platforms.add(platform);
    });
  }

  Color _getFractionColor(int numerator, int denominator) {
    final value = numerator / denominator;
    if (value <= 0.25) return Colors.red;
    if (value <= 0.5) return Colors.blue;
    if (value <= 0.75) return Colors.green;
    return Colors.purple;
  }

  void _spawnObstacle(double x) {
    final obstacle = Obstacle(
      x: x,
      lane: _random.nextInt(3),
      type: _random.nextInt(2), // 0: wall, 1: spikes
    );

    setState(() {
      _obstacles.add(obstacle);
    });
  }

  void _spawnCoin(double x) {
    final coin = Coin(
      x: x,
      lane: _random.nextInt(3),
    );

    setState(() {
      _coins.add(coin);
    });
  }

  void _spawnPowerUp(double x) {
    final powerUp = PowerUp(
      x: x,
      lane: _random.nextInt(3),
      type: _random.nextInt(3), // 0: shield, 1: magnet, 2: double jump
    );

    setState(() {
      _powerUps.add(powerUp);
    });
  }

  void _collectPlatform(Platform platform) {
    setState(() {
      _score += 50;
    });

    _createSuccessParticles(platform.x, platform.lane * 0.33 + 0.5);
    _speak(_isHebrew ? 'מצוין!' : 'Great!');

    // Generate new question
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _generateQuestion();
    });
  }

  void _collectCoin(Coin coin) {
    setState(() {
      _score += 10;
    });

    _createCoinParticles(coin.x, coin.lane * 0.33 + 0.5);
  }

  void _collectPowerUp(PowerUp powerUp) {
    switch (powerUp.type) {
      case 0: // Shield
        setState(() {
          _hasShield = true;
        });
        _speak(_isHebrew ? 'מגן!' : 'Shield!');
        Future.delayed(const Duration(seconds: 10), () {
          if (mounted) setState(() => _hasShield = false);
        });
        break;
      case 1: // Magnet
        setState(() {
          _hasMagnet = true;
        });
        _speak(_isHebrew ? 'מגנט!' : 'Magnet!');
        Future.delayed(const Duration(seconds: 8), () {
          if (mounted) setState(() => _hasMagnet = false);
        });
        break;
      case 2: // Double jump
        setState(() {
          _canDoubleJump = true;
        });
        _speak(_isHebrew ? 'קפיצה כפולה!' : 'Double jump!');
        break;
    }

    _createPowerUpParticles(powerUp.x, powerUp.lane * 0.33 + 0.5);
  }

  void _hitObstacle() {
    if (_hasShield) {
      setState(() {
        _hasShield = false;
      });
      _speak(_isHebrew ? 'המגן הגן עליך!' : 'Shield protected you!');
      return;
    }

    _endGame();
  }

  void _jump() {
    if (_isJumping && !_hasUsedDoubleJump && _canDoubleJump) {
      setState(() {
        _jumpHeight = 0.3;
        _hasUsedDoubleJump = true;
      });
    } else if (!_isJumping) {
      setState(() {
        _isJumping = true;
        _jumpHeight = 0.0;
      });
    }
  }

  void _changeLane(int newLane) {
    if (!_gameOver && newLane >= 0 && newLane <= 2) {
      setState(() {
        _currentLane = newLane;
      });
    }
  }

  void _createSuccessParticles(double x, double y) {
    final newParticles = List.generate(20, (i) {
      final angle = (i / 20) * 2 * pi;
      return Particle(
        x: x,
        y: y,
        vx: cos(angle) * 0.015,
        vy: sin(angle) * 0.015,
        color: [Colors.yellow, Colors.orange, Colors.pink][_random.nextInt(3)],
        size: 3 + _random.nextDouble() * 4,
        life: 1.0,
      );
    });
    setState(() => _particles.addAll(newParticles));
    _particleController.forward(from: 0);
  }

  void _createCoinParticles(double x, double y) {
    final newParticles = List.generate(8, (i) {
      final angle = (i / 8) * 2 * pi;
      return Particle(
        x: x,
        y: y,
        vx: cos(angle) * 0.01,
        vy: sin(angle) * 0.01,
        color: Colors.yellow.shade600,
        size: 2 + _random.nextDouble() * 3,
        life: 1.0,
      );
    });
    setState(() => _particles.addAll(newParticles));
    _particleController.forward(from: 0);
  }

  void _createPowerUpParticles(double x, double y) {
    final newParticles = List.generate(15, (i) {
      final angle = (i / 15) * 2 * pi;
      return Particle(
        x: x,
        y: y,
        vx: cos(angle) * 0.012,
        vy: sin(angle) * 0.012,
        color: [Colors.cyan, Colors.lightBlue, Colors.blue][_random.nextInt(3)],
        size: 3 + _random.nextDouble() * 4,
        life: 1.0,
      );
    });
    setState(() => _particles.addAll(newParticles));
    _particleController.forward(from: 0);
  }

  void _endGame() {
    setState(() {
      _gameOver = true;
    });

    _gameTimer?.cancel();
    _speak(_isHebrew ? 'משחק נגמר!' : 'Game over!');

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      _showGameOverDialog();
    });
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
              colors: [Colors.orange.shade100, Colors.red.shade100],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏃‍♂️💥', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                _isHebrew ? 'משחק נגמר!' : 'Game Over!',
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                _isHebrew ? 'ניקוד:' : 'Score:',
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                '$_score',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isHebrew ? 'מרחק:' : 'Distance:',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                '${(_distance / 10).toStringAsFixed(1)}m',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
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
                      _startGame();
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

  @override
  void dispose() {
    _flutterTts.stop();
    _gameTimer?.cancel();
    _runController.dispose();
    _particleController.dispose();
    _shieldController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    _isHebrew = Localizations.localeOf(context).languageCode == 'he';

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragUpdate: (details) {
          if (_gameOver) return;
          // Swipe up = move up (decrease lane: 2→1→0)
          // Swipe down = move down (increase lane: 0→1→2)
          if (details.delta.dy < -10) {
            // Swipe up - go to upper lane
            if (_currentLane > 0) _changeLane(_currentLane - 1);
          } else if (details.delta.dy > 10) {
            // Swipe down - go to lower lane
            if (_currentLane < 2) _changeLane(_currentLane + 1);
          }
        },
        onTap: () {
          if (_gameOver) return;
          _jump();
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade300,
                Colors.green.shade200,
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Background
                CustomPaint(
                  painter: BackgroundPainter(_distance),
                  size: Size.infinite,
                ),

                // Game objects
                AnimatedBuilder(
                  animation: _runAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: GamePainter(
                        platforms: _platforms,
                        obstacles: _obstacles,
                        coins: _coins,
                        powerUps: _powerUps,
                        playerLane: _currentLane,
                        isJumping: _isJumping,
                        jumpHeight: _jumpHeight,
                        runValue: _runAnimation.value,
                        hasShield: _hasShield,
                        shieldValue: _shieldAnimation.value,
                      ),
                      size: Size.infinite,
                    );
                  },
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
                    _buildQuestion(responsive),
                    const Spacer(),
                    _buildPowerUpIndicators(responsive),
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
          colors: [Colors.black.withOpacity(0.5), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          KidBackButton(
            onPressed: () => Navigator.pop(context),
            color: Colors.orange.shade300,
            isHebrew: _isHebrew,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatBadge(
                  responsive,
                  '⭐',
                  '$_score',
                  Colors.yellow,
                ),
                _buildStatBadge(
                  responsive,
                  '📏',
                  '${(_distance / 10).toStringAsFixed(0)}m',
                  Colors.blue,
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
      ResponsiveHelper responsive, String emoji, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing(12),
        vertical: responsive.spacing(8),
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: responsive.iconSize(20))),
          SizedBox(width: responsive.spacing(6)),
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.fontSize(18),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(ResponsiveHelper responsive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
      padding: EdgeInsets.all(responsive.spacing(12)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade400, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isHebrew
                ? '🎯 קפוץ על פלטפורמה עם: $_targetNumerator/$_targetDenominator'
                : '🎯 Jump on platform with: $_targetNumerator/$_targetDenominator',
            style: TextStyle(
              fontSize: responsive.fontSize(18),
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.spacing(6)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.spacing(8),
              vertical: responsive.spacing(4),
            ),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isHebrew ? 'בקרים:' : 'Controls:',
                  style: TextStyle(
                    fontSize: responsive.fontSize(11),
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                SizedBox(height: responsive.spacing(2)),
                Text(
                  _isHebrew
                      ? '👆 לחיצה = קפיצה\n⬆️ החלק למעלה/למטה = שנה מסלול'
                      : '👆 Tap = Jump\n⬆️ Swipe up/down = Change lane',
                  style: TextStyle(
                    fontSize: responsive.fontSize(9),
                    color: Colors.orange.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerUpIndicators(ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_hasShield)
            Container(
              padding: EdgeInsets.all(responsive.spacing(8)),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: Text(
                '🛡️',
                style: TextStyle(fontSize: responsive.iconSize(24)),
              ),
            ),
          if (_hasMagnet)
            Container(
              margin: EdgeInsets.only(left: responsive.spacing(8)),
              padding: EdgeInsets.all(responsive.spacing(8)),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple, width: 2),
              ),
              child: Text(
                '🧲',
                style: TextStyle(fontSize: responsive.iconSize(24)),
              ),
            ),
          if (_canDoubleJump)
            Container(
              margin: EdgeInsets.only(left: responsive.spacing(8)),
              padding: EdgeInsets.all(responsive.spacing(8)),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Text(
                '⬆️⬆️',
                style: TextStyle(fontSize: responsive.iconSize(24)),
              ),
            ),
        ],
      ),
    );
  }
}

// Data classes
class Platform {
  final int numerator;
  final int denominator;
  final double x;
  final int lane;
  final Color color;

  Platform({
    required this.numerator,
    required this.denominator,
    required this.x,
    required this.lane,
    required this.color,
  });

  Platform update(double speed) {
    return Platform(
      numerator: numerator,
      denominator: denominator,
      x: x - speed,
      lane: lane,
      color: color,
    );
  }
}

class Obstacle {
  final double x;
  final int lane;
  final int type;

  Obstacle({
    required this.x,
    required this.lane,
    required this.type,
  });

  Obstacle update(double speed) {
    return Obstacle(
      x: x - speed,
      lane: lane,
      type: type,
    );
  }
}

class Coin {
  final double x;
  final int lane;

  Coin({
    required this.x,
    required this.lane,
  });

  Coin update(double speed) {
    return Coin(
      x: x - speed,
      lane: lane,
    );
  }
}

class PowerUp {
  final double x;
  final int lane;
  final int type;

  PowerUp({
    required this.x,
    required this.lane,
    required this.type,
  });

  PowerUp update(double speed) {
    return PowerUp(
      x: x - speed,
      lane: lane,
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
      vy: vy + 0.0005,
      color: color,
      size: size * 0.96,
      life: life - 0.02,
    );
  }
}

// Painters
class BackgroundPainter extends CustomPainter {
  final int distance;

  BackgroundPainter(this.distance);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw ground lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2;

    for (int i = 0; i < 10; i++) {
      final x = (size.width * ((distance % 100) / 100)) + (i * size.width / 10);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x - size.width * 0.2, size.height),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) =>
      oldDelegate.distance != distance;
}

class GamePainter extends CustomPainter {
  final List<Platform> platforms;
  final List<Obstacle> obstacles;
  final List<Coin> coins;
  final List<PowerUp> powerUps;
  final int playerLane;
  final bool isJumping;
  final double jumpHeight;
  final double runValue;
  final bool hasShield;
  final double shieldValue;

  GamePainter({
    required this.platforms,
    required this.obstacles,
    required this.coins,
    required this.powerUps,
    required this.playerLane,
    required this.isJumping,
    required this.jumpHeight,
    required this.runValue,
    required this.hasShield,
    required this.shieldValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw lane dividers
    final dividerPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height * 0.33),
      Offset(size.width, size.height * 0.33),
      dividerPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.67),
      Offset(size.width, size.height * 0.67),
      dividerPaint,
    );

    // Draw platforms
    for (final platform in platforms) {
      _drawPlatform(canvas, size, platform);
    }

    // Draw obstacles
    for (final obstacle in obstacles) {
      _drawObstacle(canvas, size, obstacle);
    }

    // Draw coins
    for (final coin in coins) {
      _drawCoin(canvas, size, coin);
    }

    // Draw power-ups
    for (final powerUp in powerUps) {
      _drawPowerUp(canvas, size, powerUp);
    }

    // Draw player
    _drawPlayer(canvas, size);
  }

  void _drawPlatform(Canvas canvas, Size size, Platform platform) {
    final y = (platform.lane * 0.33 + 0.25) * size.height;
    final x = platform.x * size.width;

    final platformRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(x, y),
        width: 100,
        height: 40,
      ),
      const Radius.circular(10),
    );

    final platformPaint = Paint()
      ..shader = LinearGradient(
        colors: [platform.color, platform.color.withOpacity(0.7)],
      ).createShader(platformRect.outerRect);

    canvas.drawRRect(platformRect, platformPaint);

    // Draw fraction
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${platform.numerator}/${platform.denominator}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  void _drawObstacle(Canvas canvas, Size size, Obstacle obstacle) {
    final y = (obstacle.lane * 0.33 + 0.25) * size.height;
    final x = obstacle.x * size.width;

    if (obstacle.type == 0) {
      // Wall
      final wallPaint = Paint()
        ..color = Colors.red.shade700
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, y), width: 40, height: 60),
        wallPaint,
      );
    } else {
      // Spikes
      final spikePaint = Paint()
        ..color = Colors.grey.shade800
        ..style = PaintingStyle.fill;

      for (int i = 0; i < 3; i++) {
        final path = Path();
        path.moveTo(x - 30 + i * 30, y + 20);
        path.lineTo(x - 15 + i * 30, y - 20);
        path.lineTo(x + i * 30, y + 20);
        path.close();
        canvas.drawPath(path, spikePaint);
      }
    }
  }

  void _drawCoin(Canvas canvas, Size size, Coin coin) {
    final y = (coin.lane * 0.33 + 0.25) * size.height;
    final x = coin.x * size.width;

    final coinPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.yellow.shade300, Colors.yellow.shade700],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: 15));

    canvas.drawCircle(Offset(x, y), 15, coinPaint);

    // Draw $ symbol
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '★',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  void _drawPowerUp(Canvas canvas, Size size, PowerUp powerUp) {
    final y = (powerUp.lane * 0.33 + 0.25) * size.height;
    final x = powerUp.x * size.width;

    final boxPaint = Paint()
      ..color = Colors.cyan.shade400
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(center: Offset(x, y), width: 35, height: 35),
      boxPaint,
    );

    // Draw icon
    final icon = ['🛡️', '🧲', '⬆️'][powerUp.type];
    final textPainter = TextPainter(
      text: TextSpan(
        text: icon,
        style: const TextStyle(fontSize: 20),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  void _drawPlayer(Canvas canvas, Size size) {
    final baseY = (playerLane * 0.33 + 0.25) * size.height;
    final jumpOffset = isJumping ? -sin(jumpHeight * pi) * 80 : 0;
    final y = baseY + jumpOffset;
    final x = size.width * 0.2;

    // Body
    final bodyPaint = Paint()..color = Colors.orange.shade600;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y), width: 30, height: 40),
      bodyPaint,
    );

    // Head
    final headPaint = Paint()..color = Colors.orange.shade700;
    canvas.drawCircle(Offset(x, y - 25), 15, headPaint);

    // Legs (animated)
    final legPaint = Paint()
      ..color = Colors.orange.shade800
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final legOffset = sin(runValue * 2 * pi) * 10;
    canvas.drawLine(
      Offset(x, y + 20),
      Offset(x - legOffset, y + 35),
      legPaint,
    );
    canvas.drawLine(
      Offset(x, y + 20),
      Offset(x + legOffset, y + 35),
      legPaint,
    );

    // Shield
    if (hasShield) {
      final shieldPaint = Paint()
        ..color = Colors.blue.withOpacity(0.3 + sin(shieldValue * 2 * pi) * 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawCircle(Offset(x, y), 35, shieldPaint);
    }
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) => true;
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
