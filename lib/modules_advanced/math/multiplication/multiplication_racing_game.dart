import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:async';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/kid_back_button.dart';

/// משחק מרוץ כפל - ענה על שאלות כפל תוך כדי נהיגה
class MultiplicationRacingGame extends StatefulWidget {
  const MultiplicationRacingGame({super.key});

  @override
  State<MultiplicationRacingGame> createState() => _MultiplicationRacingGameState();
}

class _MultiplicationRacingGameState extends State<MultiplicationRacingGame>
    with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();
  bool _isHebrew = true;

  // Game state
  int _currentLane = 1; // 0-3 lanes
  int _score = 0;
  int _correctAnswers = 0;
  int _level = 1;
  bool _gameStarted = false;
  bool _gameOver = false;

  // Best scores
  int _bestScore = 0;
  int _bestCorrectAnswers = 0;

  // Current question
  int? _num1;
  int? _num2;
  int? _correctAnswer;
  List<int> _answers = [];

  // Animation
  late AnimationController _roadAnimationController;
  late AnimationController _answerAnimationController;
  double _roadOffset = 0;
  double _answerPosition = -200;

  // Speed control
  double _baseSpeed = 1.0;
  Timer? _gameTimer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initTts();
    _loadBestScores();

    // Road animation
    _roadAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addListener(() {
      setState(() {
        _roadOffset = (_roadOffset + _baseSpeed) % 100;
      });
    });

    // Answer blocks animation
    _answerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..addListener(() {
      if (!_gameStarted || _gameOver) return;

      setState(() {
        _answerPosition += _baseSpeed * 3;

        // Check collision
        if (_answerPosition > 350 && _answerPosition < 450) {
          _checkAnswer();
        }

        // Reset if missed
        if (_answerPosition > 600) {
          _wrongAnswer();
        }
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isHebrew = Localizations.localeOf(context).languageCode == 'he';
      });
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage(_isHebrew ? 'he-IL' : 'en-US');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> _loadBestScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bestScore = prefs.getInt('racing_best_score') ?? 0;
      _bestCorrectAnswers = prefs.getInt('racing_best_correct') ?? 0;
    });
  }

  Future<void> _saveBestScores() async {
    if (_correctAnswers > _bestCorrectAnswers ||
        (_correctAnswers == _bestCorrectAnswers && _elapsedSeconds < _bestScore && _bestScore > 0)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('racing_best_score', _elapsedSeconds);
      await prefs.setInt('racing_best_correct', _correctAnswers);
      setState(() {
        _bestScore = _elapsedSeconds;
        _bestCorrectAnswers = _correctAnswers;
      });
    }
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _gameOver = false;
      _score = 0;
      _correctAnswers = 0;
      _level = 1;
      _baseSpeed = 1.0;
      _elapsedSeconds = 0;
      _currentLane = 1;
    });

    _roadAnimationController.repeat();
    _answerAnimationController.repeat();
    _generateQuestion();

    // Start game timer
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });

    _speak(_isHebrew ? 'בואו נתחיל!' : 'Let\'s go!');
  }

  void _generateQuestion() {
    // Difficulty scaling based on level
    int maxNum1 = min(9, 3 + (_level ~/ 3)); // Start with 3-6, increase gradually
    int maxNum2 = min(9, 3 + (_level ~/ 3));

    // After level 10, start using two-digit numbers
    if (_level > 10) {
      maxNum1 = min(15, 8 + (_level ~/ 5));
      maxNum2 = min(12, 6 + (_level ~/ 5));
    }

    setState(() {
      _num1 = _random.nextInt(maxNum1) + 2;
      _num2 = _random.nextInt(maxNum2) + 2;
      _correctAnswer = _num1! * _num2!;

      // Generate wrong answers
      _answers = [_correctAnswer!];
      while (_answers.length < 4) {
        int wrongAnswer = _correctAnswer! + _random.nextInt(20) - 10;
        if (wrongAnswer > 0 && !_answers.contains(wrongAnswer)) {
          _answers.add(wrongAnswer);
        }
      }
      _answers.shuffle();

      _answerPosition = -200;
    });
  }

  void _checkAnswer() {
    if (_answerPosition < 350 || _answerPosition > 450) return;

    final selectedAnswer = _answers[_currentLane];

    if (selectedAnswer == _correctAnswer) {
      _correctAnswerAction();
    } else {
      _wrongAnswer();
    }
  }

  void _correctAnswerAction() {
    setState(() {
      _score += (10 * _level);
      _correctAnswers++;
      _level++;

      // Increase speed
      _baseSpeed = min(2.5, 1.0 + (_level * 0.08));
    });

    _speak(_isHebrew ? 'מעולה!' : 'Great!');
    _generateQuestion();
  }

  void _wrongAnswer() {
    setState(() {
      _gameOver = true;
      _gameStarted = false;
    });

    _roadAnimationController.stop();
    _answerAnimationController.stop();
    _gameTimer?.cancel();

    _saveBestScores();
    _showGameOverDialog();
  }

  void _showGameOverDialog() {
    final isNewRecord = _correctAnswers > _bestCorrectAnswers ||
        (_correctAnswers == _bestCorrectAnswers && _elapsedSeconds < _bestScore);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          isNewRecord
              ? (_isHebrew ? '🏆 שיא חדש! 🏆' : '🏆 New Record! 🏆')
              : (_isHebrew ? '🏁 סיום משחק 🏁' : '🏁 Game Over 🏁'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isHebrew ? 'תוצאות המשחק:' : 'Game Results:',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildStatRow('⭐', _isHebrew ? 'ניקוד' : 'Score', '$_score'),
            _buildStatRow('✓', _isHebrew ? 'תשובות נכונות' : 'Correct', '$_correctAnswers'),
            _buildStatRow('⏱️', _isHebrew ? 'זמן' : 'Time', '${_elapsedSeconds}s'),
            _buildStatRow('📊', _isHebrew ? 'רמה' : 'Level', '$_level'),
            const Divider(height: 30),
            Text(
              _isHebrew ? 'השיא שלך:' : 'Your Best:',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 10),
            Text(
              '$_bestCorrectAnswers ${_isHebrew ? 'תשובות ב-' : 'answers in '} ${_bestScore}s',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              _isHebrew ? 'יציאה' : 'Exit',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
            ),
            child: Text(
              _isHebrew ? 'שחק שוב' : 'Play Again',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 16)),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  void _moveLane(double delta) {
    if (!_gameStarted || _gameOver) return;

    setState(() {
      if (delta < 0 && _currentLane < 3) {
        _currentLane++;
      } else if (delta > 0 && _currentLane > 0) {
        _currentLane--;
      }
    });
  }

  @override
  void dispose() {
    _roadAnimationController.dispose();
    _answerAnimationController.dispose();
    _gameTimer?.cancel();
    _flutterTts.stop();
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
            colors: [Colors.blue.shade200, Colors.blue.shade50],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Game area
              if (_gameStarted && !_gameOver) ...[
                _buildGameScreen(responsive),
              ] else ...[
                _buildStartScreen(responsive),
              ],

              // Back button
              Positioned(
                top: 10,
                left: _isHebrew ? null : 10,
                right: _isHebrew ? 10 : null,
                child: KidBackButton(
                  onPressed: () => Navigator.pop(context),
                  color: Colors.orange.shade600,
                  isHebrew: _isHebrew,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartScreen(ResponsiveHelper responsive) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '🏎️',
            style: TextStyle(fontSize: responsive.iconSize(80)),
          ),
          SizedBox(height: responsive.spacing(20)),
          Text(
            _isHebrew ? 'מרוץ כפל' : 'Multiplication Racing',
            style: TextStyle(
              fontSize: responsive.fontSize(36),
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
          SizedBox(height: responsive.spacing(20)),
          Container(
            margin: EdgeInsets.symmetric(horizontal: responsive.spacing(40)),
            padding: EdgeInsets.all(responsive.spacing(20)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  _isHebrew ? 'איך משחקים?' : 'How to Play?',
                  style: TextStyle(
                    fontSize: responsive.fontSize(20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: responsive.spacing(12)),
                _buildInstruction('🚗', _isHebrew ? 'הזז את המכונית בין הנתיבים' : 'Move the car between lanes'),
                _buildInstruction('✖️', _isHebrew ? 'ענה על שאלות כפל' : 'Answer multiplication questions'),
                _buildInstruction('⚡', _isHebrew ? 'ככל שעולים ברמה המהירות עולה' : 'Speed increases with levels'),
                _buildInstruction('🏆', _isHebrew ? 'נסה להשיג את השיא!' : 'Try to beat the record!'),
                const SizedBox(height: 20),
                if (_bestCorrectAnswers > 0) ...[
                  Text(
                    _isHebrew ? 'השיא שלך:' : 'Your Best:',
                    style: TextStyle(
                      fontSize: responsive.fontSize(16),
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    '$_bestCorrectAnswers ${_isHebrew ? 'תשובות ב-' : 'answers in '} ${_bestScore}s',
                    style: TextStyle(
                      fontSize: responsive.fontSize(20),
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: responsive.spacing(30)),
          ElevatedButton(
            onPressed: _startGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              padding: EdgeInsets.symmetric(
                horizontal: responsive.spacing(50),
                vertical: responsive.spacing(15),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              _isHebrew ? 'התחל משחק!' : 'Start Game!',
              style: TextStyle(
                fontSize: responsive.fontSize(24),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen(ResponsiveHelper responsive) {
    return Column(
      children: [
        // Header with question and stats
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(responsive.spacing(16)),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatBadge('⭐', '$_score', _isHebrew ? 'ניקוד' : 'Score'),
                  _buildStatBadge('✓', '$_correctAnswers', _isHebrew ? 'נכונות' : 'Correct'),
                  _buildStatBadge('📊', '$_level', _isHebrew ? 'רמה' : 'Level'),
                  _buildStatBadge('⏱️', '${_elapsedSeconds}s', _isHebrew ? 'זמן' : 'Time'),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade300, width: 2),
                ),
                child: Text(
                  '$_num1 × $_num2 = ?',
                  style: TextStyle(
                    fontSize: responsive.fontSize(32),
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Road and game area
        Expanded(
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              _moveLane(details.primaryVelocity ?? 0);
            },
            child: CustomPaint(
              size: Size.infinite,
              painter: RoadPainter(
                roadOffset: _roadOffset,
                currentLane: _currentLane,
                answers: _answers,
                answerPosition: _answerPosition,
                correctAnswer: _correctAnswer!,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatBadge(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the racing road
class RoadPainter extends CustomPainter {
  final double roadOffset;
  final int currentLane;
  final List<int> answers;
  final double answerPosition;
  final int correctAnswer;

  RoadPainter({
    required this.roadOffset,
    required this.currentLane,
    required this.answers,
    required this.answerPosition,
    required this.correctAnswer,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()..color = Colors.grey.shade700;
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final grassPaint = Paint()..color = Colors.green.shade700;

    // Draw grass on sides
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * 0.1, size.height), grassPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.9, 0, size.width * 0.1, size.height), grassPaint);

    // Draw road
    final roadRect = Rect.fromLTWH(size.width * 0.1, 0, size.width * 0.8, size.height);
    canvas.drawRect(roadRect, roadPaint);

    // Draw lane dividers (animated)
    final laneWidth = (size.width * 0.8) / 4;
    for (int i = 1; i < 4; i++) {
      final x = size.width * 0.1 + (laneWidth * i);
      for (double y = roadOffset; y < size.height; y += 50) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x, y + 30),
          linePaint,
        );
      }
    }

    // Draw answer blocks
    if (answerPosition > -100 && answerPosition < size.height) {
      for (int i = 0; i < 4; i++) {
        final laneX = size.width * 0.1 + (laneWidth * i) + (laneWidth / 2);
        final answer = answers[i];
        final isCorrect = answer == correctAnswer;

        final blockPaint = Paint()
          ..color = isCorrect ? Colors.green.shade400 : Colors.red.shade400;

        final blockRect = Rect.fromCenter(
          center: Offset(laneX, answerPosition),
          width: laneWidth * 0.8,
          height: 60,
        );

        canvas.drawRRect(
          RRect.fromRectAndRadius(blockRect, const Radius.circular(12)),
          blockPaint,
        );

        // Draw answer text
        final textPainter = TextPainter(
          text: TextSpan(
            text: answer.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            laneX - textPainter.width / 2,
            answerPosition - textPainter.height / 2,
          ),
        );
      }
    }

    // Draw car
    final carLaneX = size.width * 0.1 + (laneWidth * currentLane) + (laneWidth / 2);
    final carY = size.height * 0.75;

    final carPaint = Paint()..color = Colors.blue.shade600;
    final carRect = Rect.fromCenter(
      center: Offset(carLaneX, carY),
      width: laneWidth * 0.7,
      height: 80,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(carRect, const Radius.circular(8)),
      carPaint,
    );

    // Draw car windows
    final windowPaint = Paint()..color = Colors.lightBlue.shade200;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(carLaneX, carY - 10),
          width: laneWidth * 0.5,
          height: 30,
        ),
        const Radius.circular(6),
      ),
      windowPaint,
    );
  }

  @override
  bool shouldRepaint(RoadPainter oldDelegate) => true;
}
