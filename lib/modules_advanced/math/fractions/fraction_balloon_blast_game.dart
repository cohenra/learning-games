import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'dart:async';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/kid_back_button.dart';

/// משחק Fraction Balloon Blast - פוצץ בלונים עם שברים!
class FractionBalloonBlastGame extends StatefulWidget {
  const FractionBalloonBlastGame({super.key});

  @override
  State<FractionBalloonBlastGame> createState() =>
      _FractionBalloonBlastGameState();
}

class _FractionBalloonBlastGameState extends State<FractionBalloonBlastGame>
    with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();
  bool _isHebrew = true;

  // Game state
  int _score = 0;
  int _lives = 3;
  int _combo = 0;
  int _maxCombo = 0;
  bool _gameOver = false;
  int _timeLeft = 60; // 60 seconds per game
  bool _isBonusRound = false;

  // Question
  String _questionType = 'match'; // 'match', 'bigger', 'smaller', 'sum'
  int? _targetNumerator;
  int? _targetDenominator;
  double? _targetValue;

  // Balloons
  List<Balloon> _balloons = [];
  Timer? _gameTimer;
  Timer? _spawnTimer;
  Timer? _bonusTimer;

  // Animations
  late AnimationController _floatController;
  late AnimationController _popController;
  List<PopAnimation> _popAnimations = [];
  List<Particle> _particles = [];

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
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
        if (!mounted) return;
        setState(() {
          _popAnimations = _popAnimations
              .map((pop) => pop.update(_popController.value))
              .where((pop) => pop.value < 1.0)
              .toList();
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
      _lives = 3;
      _combo = 0;
      _maxCombo = 0;
      _timeLeft = 60;
      _gameOver = false;
      _balloons.clear();
      _popAnimations.clear();
      _particles.clear();
    });

    _generateQuestion();
    _startTimers();
  }

  void _startTimers() {
    // Main game timer
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _gameOver) {
        timer.cancel();
        return;
      }

      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _endGame();
        }
      });

      // Bonus round every 15 seconds
      if (_timeLeft % 15 == 0 && _timeLeft > 0) {
        _triggerBonusRound();
      }
    });

    // Spawn balloons
    _spawnTimer?.cancel();
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted || _gameOver) {
        timer.cancel();
        return;
      }
      _spawnBalloon();
    });

    // Update balloon positions
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted || _gameOver) {
        timer.cancel();
        return;
      }
      _updateBalloons();
    });
  }

  void _generateQuestion() {
    final types = ['match', 'bigger', 'smaller'];
    _questionType = types[_random.nextInt(types.length)];

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
      _targetValue = target[0] / target[1];
      // Clear existing balloons so they don't have the old question's fractions
      _balloons.clear();
    });

    _speakQuestion();
  }

  void _speakQuestion() {
    String message = '';
    switch (_questionType) {
      case 'match':
        message = _isHebrew
            ? 'פוצץ את $_targetNumerator חלקי $_targetDenominator'
            : 'Pop $_targetNumerator divided by $_targetDenominator';
        break;
      case 'bigger':
        message = _isHebrew
            ? 'פוצץ שברים גדולים מ $_targetNumerator חלקי $_targetDenominator'
            : 'Pop fractions bigger than $_targetNumerator divided by $_targetDenominator';
        break;
      case 'smaller':
        message = _isHebrew
            ? 'פוצץ שברים קטנים מ $_targetNumerator חלקי $_targetDenominator'
            : 'Pop fractions smaller than $_targetNumerator divided by $_targetDenominator';
        break;
    }
    _speak(message);
  }

  void _triggerBonusRound() {
    setState(() {
      _isBonusRound = true;
    });

    _speak(_isHebrew ? 'בונוס ראונד! פוצץ כמה שיותר!' : 'Bonus round! Pop as many as you can!');

    // Spawn many balloons
    for (int i = 0; i < 15; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted && _isBonusRound) _spawnBalloon();
      });
    }

    _bonusTimer?.cancel();
    _bonusTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() {
        _isBonusRound = false;
      });
    });
  }

  void _spawnBalloon() {
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
    final balloon = Balloon(
      numerator: fraction[0],
      denominator: fraction[1],
      x: _random.nextDouble() * 0.9 + 0.05, // 0.05 to 0.95
      y: 1.1, // Start below screen
      speedY: -0.002 - _random.nextDouble() * 0.001,
      speedX: (_random.nextDouble() - 0.5) * 0.001,
      color: _getBalloonColor(fraction[0], fraction[1]),
      size: 50 + _random.nextDouble() * 20,
      floatOffset: _random.nextDouble() * 2 * pi,
    );

    setState(() {
      _balloons.add(balloon);
      // Limit balloons on screen
      if (_balloons.length > 20) {
        _balloons.removeAt(0);
      }
    });
  }

  Color _getBalloonColor(int numerator, int denominator) {
    final value = numerator / denominator;
    if (value <= 0.25) return Colors.red;
    if (value <= 0.5) return Colors.blue;
    if (value <= 0.75) return Colors.green;
    return Colors.purple;
  }

  void _updateBalloons() {
    setState(() {
      for (int i = _balloons.length - 1; i >= 0; i--) {
        _balloons[i] = _balloons[i].update();

        // Remove if off screen
        if (_balloons[i].y < -0.2) {
          _balloons.removeAt(i);
        }
      }
    });
  }

  void _popBalloon(Balloon balloon) {
    // Remove balloon immediately to prevent double-tap
    setState(() {
      _balloons.remove(balloon);
    });

    final isCorrect = _checkAnswer(balloon);

    // Create pop animation
    _popAnimations.add(PopAnimation(
      x: balloon.x,
      y: balloon.y,
      color: balloon.color,
      value: 0.0,
    ));

    // Create particles
    _createParticles(balloon.x, balloon.y, balloon.color, isCorrect);

    _popController.forward(from: 0);

    if (isCorrect) {
      _handleCorrectPop();
    } else {
      _handleWrongPop();
    }
  }

  bool _checkAnswer(Balloon balloon) {
    final value = balloon.numerator / balloon.denominator;

    if (_isBonusRound) return true; // All correct in bonus round

    switch (_questionType) {
      case 'match':
        return (value - _targetValue!).abs() < 0.001;
      case 'bigger':
        return value > _targetValue!;
      case 'smaller':
        return value < _targetValue!;
      default:
        return false;
    }
  }

  void _handleCorrectPop() {
    setState(() {
      _combo++;
      if (_combo > _maxCombo) _maxCombo = _combo;

      final points = _isBonusRound ? 20 : 10;
      final comboMultiplier = _combo >= 3 ? 2 : 1;
      _score += points * comboMultiplier;
    });

    if (_combo >= 3 && _combo % 3 == 0) {
      _speak(_isHebrew ? 'קומבו מדהים!' : 'Amazing combo!');
    }

    // Generate new question immediately after each correct answer (if not bonus round)
    if (!_isBonusRound) {
      _generateQuestion();
    }
  }

  void _handleWrongPop() {
    setState(() {
      _combo = 0;
      _lives--;

      if (_lives <= 0) {
        _endGame();
      }
    });

    _speak(_isHebrew ? 'אופס!' : 'Oops!');
  }

  void _createParticles(double x, double y, Color color, bool isCorrect) {
    final count = isCorrect ? 20 : 10;
    final colors = isCorrect
        ? [Colors.yellow, Colors.orange, Colors.pink, Colors.cyan]
        : [Colors.grey.shade600, Colors.grey.shade700];

    final newParticles = List.generate(count, (i) {
      final angle = (i / count) * 2 * pi;
      return Particle(
        x: x,
        y: y,
        vx: cos(angle) * 0.015,
        vy: sin(angle) * 0.015,
        color: colors[_random.nextInt(colors.length)],
        size: 3 + _random.nextDouble() * 5,
        life: 1.0,
      );
    });

    setState(() => _particles.addAll(newParticles));
  }

  void _endGame() {
    setState(() {
      _gameOver = true;
    });

    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _bonusTimer?.cancel();

    Future.delayed(const Duration(milliseconds: 500), () {
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
              colors: [Colors.purple.shade100, Colors.pink.shade100],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎈🎉🎈', style: TextStyle(fontSize: 64)),
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
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isHebrew ? 'קומבו מקסימלי:' : 'Max Combo:',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                '$_maxCombo',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
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
                      backgroundColor: Colors.purple.shade600,
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
    _bonusTimer?.cancel();
    _floatController.dispose();
    _popController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    _isHebrew = Localizations.localeOf(context).languageCode == 'he';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.lightBlue.shade100,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Clouds background
              CustomPaint(
                painter: CloudsPainter(),
                size: Size.infinite,
              ),

              // Balloons and particles
              GestureDetector(
                onTapDown: (details) {
                  if (_gameOver) return;
                  final x = details.localPosition.dx / responsive.screenWidth;
                  final y = details.localPosition.dy / responsive.screenHeight;

                  for (final balloon in _balloons) {
                    final distance = sqrt(pow(balloon.x - x, 2) + pow(balloon.y - y, 2));
                    if (distance < 0.08) {
                      _popBalloon(balloon);
                      break;
                    }
                  }
                },
                child: SizedBox.expand(
                  child: AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: BalloonsPainter(
                          balloons: _balloons,
                          floatValue: _floatController.value,
                          popAnimations: _popAnimations,
                        ),
                        size: Size.infinite,
                      );
                    },
                  ),
                ),
              ),

              // Particles
              if (_particles.isNotEmpty)
                CustomPaint(
                  painter: ParticlePainter(_particles),
                  size: Size.infinite,
                ),

              // Bonus round overlay
              if (_isBonusRound)
                Container(
                  color: Colors.yellow.withOpacity(0.2),
                  alignment: Alignment.center,
                  child: Text(
                    _isHebrew ? '🎉 בונוס ראונד! 🎉' : '🎉 BONUS ROUND! 🎉',
                    style: TextStyle(
                      fontSize: responsive.fontSize(40),
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                      shadows: const [
                        Shadow(
                          color: Colors.white,
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),

              // UI
              Column(
                children: [
                  _buildHeader(responsive),
                  _buildQuestion(responsive),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(12)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          KidBackButton(
            onPressed: () => Navigator.pop(context),
            color: Colors.purple.shade600,
            isHebrew: _isHebrew,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatBadge(
                  responsive,
                  '⏱️',
                  '$_timeLeft',
                  _timeLeft <= 10 ? Colors.red : Colors.blue,
                ),
                _buildStatBadge(
                  responsive,
                  '⭐',
                  '$_score',
                  Colors.purple,
                ),
                _buildStatBadge(
                  responsive,
                  '🔥',
                  'x$_combo',
                  _combo >= 3 ? Colors.orange : Colors.grey,
                ),
                _buildLivesBadge(responsive),
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
        horizontal: responsive.spacing(8),
        vertical: responsive.spacing(4),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: responsive.iconSize(20))),
          SizedBox(width: responsive.spacing(4)),
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivesBadge(ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing(8),
        vertical: responsive.spacing(4),
      ),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
          (i) => Text(
            i < _lives ? '❤️' : '🖤',
            style: TextStyle(fontSize: responsive.iconSize(20)),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion(ResponsiveHelper responsive) {
    String questionText = '';
    String explanation = '';

    switch (_questionType) {
      case 'match':
        questionText = _isHebrew
            ? 'פוצץ בלונים עם: $_targetNumerator/$_targetDenominator'
            : 'Pop balloons with: $_targetNumerator/$_targetDenominator';
        explanation = _isHebrew
            ? '(חפש בלונים עם השבר $_targetNumerator/$_targetDenominator)'
            : '(Find balloons with the fraction $_targetNumerator/$_targetDenominator)';
        break;
      case 'bigger':
        questionText = _isHebrew
            ? 'פוצץ שברים גדולים מ-$_targetNumerator/$_targetDenominator'
            : 'Pop fractions bigger than $_targetNumerator/$_targetDenominator';
        explanation = _isHebrew
            ? '(שברים שגדולים מ-${(_targetValue! * 100).toInt()}%)'
            : '(Fractions bigger than ${(_targetValue! * 100).toInt()}%)';
        break;
      case 'smaller':
        questionText = _isHebrew
            ? 'פוצץ שברים קטנים מ-$_targetNumerator/$_targetDenominator'
            : 'Pop fractions smaller than $_targetNumerator/$_targetDenominator';
        explanation = _isHebrew
            ? '(שברים שקטנים מ-${(_targetValue! * 100).toInt()}%)'
            : '(Fractions smaller than ${(_targetValue! * 100).toInt()}%)';
        break;
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: responsive.spacing(16),
        vertical: responsive.spacing(8),
      ),
      padding: EdgeInsets.all(responsive.spacing(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.shade400, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            questionText,
            style: TextStyle(
              fontSize: responsive.fontSize(20),
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.spacing(4)),
          Text(
            explanation,
            style: TextStyle(
              fontSize: responsive.fontSize(12),
              color: Colors.purple.shade700,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.spacing(4)),
          Text(
            _isHebrew ? '👆 גע על הבלונים!' : '👆 Tap the balloons!',
            style: TextStyle(
              fontSize: responsive.fontSize(11),
              color: Colors.purple.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Data classes
class Balloon {
  final int numerator;
  final int denominator;
  final double x;
  final double y;
  final double speedX;
  final double speedY;
  final Color color;
  final double size;
  final double floatOffset;

  Balloon({
    required this.numerator,
    required this.denominator,
    required this.x,
    required this.y,
    required this.speedX,
    required this.speedY,
    required this.color,
    required this.size,
    required this.floatOffset,
  });

  Balloon update() {
    return Balloon(
      numerator: numerator,
      denominator: denominator,
      x: (x + speedX).clamp(0.05, 0.95),
      y: y + speedY,
      speedX: speedX,
      speedY: speedY,
      color: color,
      size: size,
      floatOffset: floatOffset,
    );
  }
}

class PopAnimation {
  final double x;
  final double y;
  final Color color;
  final double value;

  PopAnimation({
    required this.x,
    required this.y,
    required this.color,
    required this.value,
  });

  PopAnimation update(double newValue) {
    return PopAnimation(
      x: x,
      y: y,
      color: color,
      value: newValue,
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
      vy: vy + 0.0008, // Gravity
      color: color,
      size: size * 0.96,
      life: life - 0.03,
    );
  }
}

// Painters
class CloudsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    // Draw clouds
    for (int i = 0; i < 5; i++) {
      final y = (i * size.height / 5) + 50;
      canvas.drawOval(
        Rect.fromLTWH(size.width * 0.1, y, 150, 60),
        paint,
      );
      canvas.drawOval(
        Rect.fromLTWH(size.width * 0.7, y + 30, 120, 50),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CloudsPainter oldDelegate) => false;
}

class BalloonsPainter extends CustomPainter {
  final List<Balloon> balloons;
  final double floatValue;
  final List<PopAnimation> popAnimations;

  BalloonsPainter({
    required this.balloons,
    required this.floatValue,
    required this.popAnimations,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw pop animations
    for (final pop in popAnimations) {
      _drawPopAnimation(canvas, size, pop);
    }

    // Draw balloons
    for (final balloon in balloons) {
      _drawBalloon(canvas, size, balloon);
    }
  }

  void _drawBalloon(Canvas canvas, Size size, Balloon balloon) {
    final floatY = sin(floatValue * 2 * pi + balloon.floatOffset) * 5;
    final center = Offset(
      balloon.x * size.width,
      balloon.y * size.height + floatY,
    );

    // Balloon body
    final balloonPath = Path();
    balloonPath.addOval(Rect.fromCenter(
      center: center,
      width: balloon.size,
      height: balloon.size * 1.2,
    ));

    final balloonPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          balloon.color.withOpacity(0.8),
          balloon.color,
        ],
        center: const Alignment(-0.3, -0.3),
      ).createShader(Rect.fromCircle(center: center, radius: balloon.size));

    canvas.drawPath(balloonPath, balloonPaint);

    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - balloon.size * 0.2, center.dy - balloon.size * 0.3),
        width: balloon.size * 0.3,
        height: balloon.size * 0.4,
      ),
      highlightPaint,
    );

    // String
    final stringPaint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final stringPath = Path();
    stringPath.moveTo(center.dx, center.dy + balloon.size * 0.6);
    stringPath.quadraticBezierTo(
      center.dx + 5,
      center.dy + balloon.size * 0.8,
      center.dx,
      center.dy + balloon.size * 1.0,
    );

    canvas.drawPath(stringPath, stringPaint);

    // Fraction text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${balloon.numerator}/${balloon.denominator}',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
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

  void _drawPopAnimation(Canvas canvas, Size size, PopAnimation pop) {
    final center = Offset(pop.x * size.width, pop.y * size.height);

    // Expanding circles
    for (int i = 0; i < 3; i++) {
      final radius = (30 + i * 20) * pop.value;
      final paint = Paint()
        ..color = pop.color.withOpacity((1 - pop.value) * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(BalloonsPainter oldDelegate) => true;
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
