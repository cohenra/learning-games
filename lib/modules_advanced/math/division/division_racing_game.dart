import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'dart:async';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/kid_button.dart';
import '../../../widgets/kid_back_button.dart';

/// משחק מרוץ החילוק - ארקייד תחרותי עם גרפיקה מתקדמת
class DivisionRacingGame extends StatefulWidget {
  const DivisionRacingGame({super.key});

  @override
  State<DivisionRacingGame> createState() => _DivisionRacingGameState();
}

class _DivisionRacingGameState extends State<DivisionRacingGame>
    with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();
  bool _isHebrew = true;

  // Game state
  int _currentQuestion = 0;
  final int _totalQuestions = 5;
  int _score = 0;
  int _difficulty = 1; // 1=Easy, 2=Medium, 3=Hard

  // Current question
  int? _dividend;
  int? _divisor;
  int? _correctAnswer;
  List<int> _options = [];
  int? _selectedAnswer;
  bool? _isCorrect;

  // Racing positions (0.0 = start, 1.0 = finish)
  double _playerPosition = 0.0;
  double _opponent1Position = 0.0;
  double _opponent2Position = 0.0;
  double _opponent3Position = 0.0;

  // Animations
  late AnimationController _turboController;
  late AnimationController _wrongShakeController;
  late AnimationController _particleController;
  late Animation<double> _turboAnimation;
  late Animation<double> _shakeAnimation;

  // Particles for effects
  List<Particle> _particles = [];
  bool _showTurbo = false;

  // Timer for opponent AI
  Timer? _opponentTimer;

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
      _selectDifficulty();
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage(_isHebrew ? 'he-IL' : 'en-US');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
  }

  void _initAnimations() {
    _turboController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _turboAnimation = CurvedAnimation(
      parent: _turboController,
      curve: Curves.easeOutCubic,
    );

    _wrongShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _wrongShakeController, curve: Curves.elasticIn),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..addListener(() {
        setState(() {
          _particles = _particles.map((p) => p.update()).toList();
          _particles.removeWhere((p) => p.life <= 0);
        });
      });
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _selectDifficulty() {
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
              colors: [Colors.purple.shade50, Colors.blue.shade50],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isHebrew ? '🏁 בחר רמת קושי' : '🏁 Select Difficulty',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildDifficultyButton(
                1,
                _isHebrew ? 'קל' : 'Easy',
                _isHebrew ? 'חילוק עד 20' : 'Division up to 20',
                Colors.green,
                '🐢',
              ),
              const SizedBox(height: 12),
              _buildDifficultyButton(
                2,
                _isHebrew ? 'בינוני' : 'Medium',
                _isHebrew ? 'חילוק עד 50' : 'Division up to 50',
                Colors.orange,
                '🐇',
              ),
              const SizedBox(height: 12),
              _buildDifficultyButton(
                3,
                _isHebrew ? 'קשה' : 'Hard',
                _isHebrew ? 'חילוק עד 100' : 'Division up to 100',
                Colors.red,
                '🚀',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(
      int level, String title, String subtitle, MaterialColor color, String emoji) {
    return InkWell(
      onTap: () {
        setState(() => _difficulty = level);
        Navigator.pop(context);
        _startRace();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.shade300, color.shade500],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }

  void _startRace() {
    setState(() {
      _currentQuestion = 0;
      _score = 0;
      _playerPosition = 0.0;
      _opponent1Position = 0.0;
      _opponent2Position = 0.0;
      _opponent3Position = 0.0;
    });
    _generateQuestion();
    _startOpponentAI();
  }

  void _startOpponentAI() {
    _opponentTimer?.cancel();
    _opponentTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        // Opponents move slowly and randomly
        if (_opponent1Position < 1.0) {
          _opponent1Position += _random.nextDouble() * 0.08;
        }
        if (_opponent2Position < 1.0) {
          _opponent2Position += _random.nextDouble() * 0.06;
        }
        if (_opponent3Position < 1.0) {
          _opponent3Position += _random.nextDouble() * 0.07;
        }
      });
    });
  }

  void _generateQuestion() {
    int dividend, divisor, answer;

    switch (_difficulty) {
      case 1: // Easy
        divisor = _random.nextInt(4) + 2; // 2-5
        answer = _random.nextInt(4) + 2; // 2-5
        dividend = divisor * answer;
        break;
      case 2: // Medium
        divisor = _random.nextInt(6) + 2; // 2-7
        answer = _random.nextInt(6) + 2; // 2-7
        dividend = divisor * answer;
        break;
      case 3: // Hard
        divisor = _random.nextInt(8) + 2; // 2-9
        answer = _random.nextInt(10) + 2; // 2-11
        dividend = divisor * answer;
        break;
      default:
        divisor = 2;
        answer = 2;
        dividend = 4;
    }

    final options = <int>{answer};
    while (options.length < 4) {
      final offset = _random.nextInt(7) - 3;
      final option = (answer + offset).clamp(1, 100);
      options.add(option);
    }

    setState(() {
      _dividend = dividend;
      _divisor = divisor;
      _correctAnswer = answer;
      _options = options.toList()..shuffle();
      _selectedAnswer = null;
      _isCorrect = null;
    });

    _speak(_isHebrew ? 'כמה זה $_dividend חלקי $_divisor?' : 'What is $_dividend divided by $_divisor?');
  }

  void _answerQuestion(int answer) {
    if (_selectedAnswer != null) return; // Already answered

    setState(() {
      _selectedAnswer = answer;
      _isCorrect = answer == _correctAnswer;
    });

    if (_isCorrect!) {
      _speak(_isHebrew ? 'נכון! קדימה!' : 'Correct! Go!');
      _triggerTurbo();
      _createParticles();
      setState(() => _score++);

      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        _currentQuestion++;
        if (_currentQuestion >= _totalQuestions) {
          _finishRace();
        } else {
          _generateQuestion();
        }
      });
    } else {
      _speak(_isHebrew ? 'לא נכון, נסה שוב' : 'Wrong, try again');
      _wrongShakeController.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() {
          _selectedAnswer = null;
          _isCorrect = null;
        });
      });
    }
  }

  void _triggerTurbo() {
    setState(() {
      _showTurbo = true;
      _playerPosition = ((_currentQuestion + 1) / _totalQuestions)
          .clamp(0.0, 1.0);
    });
    _turboController.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showTurbo = false);
    });
  }

  void _createParticles() {
    final newParticles = List.generate(15, (i) {
      return Particle(
        x: 0.2 + _random.nextDouble() * 0.1,
        y: 0.3 + _random.nextDouble() * 0.4,
        vx: (_random.nextDouble() - 0.5) * 0.02,
        vy: -_random.nextDouble() * 0.02,
        color: [Colors.yellow, Colors.orange, Colors.red][_random.nextInt(3)],
        size: _random.nextDouble() * 8 + 4,
      );
    });
    setState(() => _particles.addAll(newParticles));
    _particleController.forward(from: 0);
  }

  void _finishRace() {
    _opponentTimer?.cancel();

    final playerWon = _playerPosition > _opponent1Position &&
        _playerPosition > _opponent2Position &&
        _playerPosition > _opponent3Position;

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
              colors: playerWon
                  ? [Colors.yellow.shade100, Colors.orange.shade100]
                  : [Colors.blue.shade100, Colors.purple.shade100],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                playerWon
                    ? (_isHebrew ? '🏆 ניצחון! 🏆' : '🏆 Victory! 🏆')
                    : (_isHebrew ? '🎯 כמעט! 🎯' : '🎯 Almost! 🎯'),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                _isHebrew ? 'תשובות נכונות:' : 'Correct answers:',
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                '$_score / $_totalQuestions',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),
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
                      _selectDifficulty();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
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
    _opponentTimer?.cancel();
    _flutterTts.stop();
    _turboController.dispose();
    _wrongShakeController.dispose();
    _particleController.dispose();
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
              Colors.blue.shade300,
              Colors.blue.shade100,
              Colors.green.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: _dividend == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    Column(
                      children: [
                        _buildHeader(responsive),
                        SizedBox(height: responsive.spacing(16)),
                        _buildQuestion(responsive),
                        SizedBox(height: responsive.spacing(16)),
                        Expanded(child: _buildRaceTrack(responsive)),
                        SizedBox(height: responsive.spacing(16)),
                        _buildAnswerOptions(responsive),
                        SizedBox(height: responsive.spacing(16)),
                      ],
                    ),
                    if (_particles.isNotEmpty)
                      CustomPaint(
                        painter: ParticlePainter(_particles),
                        size: Size.infinite,
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
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          KidBackButton(
            onPressed: () => Navigator.pop(context),
            color: Colors.blue.shade600,
            isHebrew: _isHebrew,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatBadge(
                  responsive,
                  '🏁',
                  '${_currentQuestion + 1}/$_totalQuestions',
                  _isHebrew ? 'שאלה' : 'Question',
                ),
                _buildStatBadge(
                  responsive,
                  '⭐',
                  '$_score',
                  _isHebrew ? 'נכונות' : 'Score',
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
      ResponsiveHelper responsive, String emoji, String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing(12),
        vertical: responsive.spacing(8),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.purple.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
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
                value,
                style: TextStyle(
                  fontSize: responsive.fontSize(16),
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: responsive.fontSize(10),
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(ResponsiveHelper responsive) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value * (_isCorrect == false ? 1 : 0), 0),
          child: child,
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
        padding: EdgeInsets.all(responsive.spacing(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.shade400, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          '$_dividend ÷ $_divisor = ?',
          style: TextStyle(
            fontSize: responsive.fontSize(32),
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildRaceTrack(ResponsiveHelper responsive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: responsive.spacing(8)),
      child: CustomPaint(
        painter: RaceTrackPainter(
          playerPosition: _playerPosition,
          opponent1Position: _opponent1Position,
          opponent2Position: _opponent2Position,
          opponent3Position: _opponent3Position,
          showTurbo: _showTurbo,
          turboValue: _turboAnimation.value,
        ),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildAnswerOptions(ResponsiveHelper responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.5,
        children: _options.map((option) {
          final isSelected = _selectedAnswer == option;
          final showResult = _isCorrect != null && isSelected;

          return GestureDetector(
            onTap: _selectedAnswer == null ? () => _answerQuestion(option) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: showResult
                      ? (_isCorrect!
                          ? [Colors.green.shade400, Colors.green.shade600]
                          : [Colors.red.shade400, Colors.red.shade600])
                      : [Colors.white, Colors.blue.shade50],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: showResult
                      ? (_isCorrect! ? Colors.green : Colors.red)
                      : Colors.blue.shade300,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (showResult
                            ? (_isCorrect! ? Colors.green : Colors.red)
                            : Colors.blue)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  option.toString(),
                  style: TextStyle(
                    fontSize: responsive.fontSize(28),
                    fontWeight: FontWeight.bold,
                    color: showResult ? Colors.white : Colors.blue.shade900,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Particle class for effects
class Particle {
  double x, y, vx, vy;
  Color color;
  double size;
  double life;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    this.life = 1.0,
  });

  Particle update() {
    return Particle(
      x: x + vx,
      y: y + vy,
      vx: vx,
      vy: vy,
      color: color,
      size: size * 0.95,
      life: life - 0.02,
    );
  }
}

// Particle painter
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.life)
        ..style = PaintingStyle.fill;

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

// Race track painter with advanced graphics
class RaceTrackPainter extends CustomPainter {
  final double playerPosition;
  final double opponent1Position;
  final double opponent2Position;
  final double opponent3Position;
  final bool showTurbo;
  final double turboValue;

  RaceTrackPainter({
    required this.playerPosition,
    required this.opponent1Position,
    required this.opponent2Position,
    required this.opponent3Position,
    required this.showTurbo,
    required this.turboValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final trackHeight = size.height / 4;

    // Draw background lanes with gradient
    for (int i = 0; i < 4; i++) {
      final rect = Rect.fromLTWH(0, i * trackHeight, size.width, trackHeight);
      final gradient = LinearGradient(
        colors: i.isEven
            ? [Colors.green.shade200, Colors.green.shade300]
            : [Colors.green.shade300, Colors.green.shade400],
      );
      final paint = Paint()..shader = gradient.createShader(rect);
      canvas.drawRect(rect, paint);

      // Draw lane dividers
      if (i > 0) {
        final dividerPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(0, i * trackHeight),
          Offset(size.width, i * trackHeight),
          dividerPaint,
        );
      }
    }

    // Draw finish line
    _drawFinishLine(canvas, size);

    // Draw racers
    _drawRacer(canvas, size, 0, playerPosition, Colors.blue, '🏎️', showTurbo, turboValue);
    _drawRacer(canvas, size, 1, opponent1Position, Colors.red, '🚗', false, 0);
    _drawRacer(canvas, size, 2, opponent2Position, Colors.yellow, '🚙', false, 0);
    _drawRacer(canvas, size, 3, opponent3Position, Colors.purple, '🚕', false, 0);
  }

  void _drawFinishLine(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    const squareSize = 20.0;
    final finishX = size.width - 40;

    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 3; j++) {
        paint.color = (i + j).isEven ? Colors.white : Colors.black;
        canvas.drawRect(
          Rect.fromLTWH(
            finishX,
            i * (size.height / 4) + j * squareSize,
            40,
            squareSize,
          ),
          paint,
        );
      }
    }
  }

  void _drawRacer(Canvas canvas, Size size, int lane, double position,
      MaterialColor color, String emoji, bool hasTurbo, double turboValue) {
    final trackHeight = size.height / 4;
    final centerY = lane * trackHeight + trackHeight / 2;
    final maxX = size.width - 80; // Account for finish line
    final x = 40 + (position * maxX);

    // Draw turbo effect
    if (hasTurbo && turboValue > 0) {
      final turboPaint = Paint()
        ..color = Colors.orange.withOpacity(0.6 * turboValue)
        ..style = PaintingStyle.fill;

      for (int i = 0; i < 3; i++) {
        canvas.drawCircle(
          Offset(x - 20 - i * 10, centerY),
          10 - i * 2,
          turboPaint,
        );
      }
    }

    // Draw car body
    final carRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x, centerY), width: 50, height: 30),
      const Radius.circular(8),
    );
    final carPaint = Paint()
      ..shader = LinearGradient(
        colors: [color.shade300, color.shade600],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(carRect.outerRect);
    canvas.drawRRect(carRect, carPaint);

    // Draw windows
    final windowPaint = Paint()
      ..color = Colors.blue.shade100.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, centerY - 5), width: 20, height: 10),
        const Radius.circular(4),
      ),
      windowPaint,
    );

    // Draw wheels
    final wheelPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(x - 15, centerY + 12), 6, wheelPaint);
    canvas.drawCircle(Offset(x + 15, centerY + 12), 6, wheelPaint);
  }

  @override
  bool shouldRepaint(RaceTrackPainter oldDelegate) {
    return oldDelegate.playerPosition != playerPosition ||
        oldDelegate.opponent1Position != opponent1Position ||
        oldDelegate.opponent2Position != opponent2Position ||
        oldDelegate.opponent3Position != opponent3Position ||
        oldDelegate.showTurbo != showTurbo ||
        oldDelegate.turboValue != turboValue;
  }
}
