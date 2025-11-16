import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:async';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/kid_back_button.dart';

/// משחק מרוץ מתמטיקה - ענה על שאלות מתמטיקה תוך כדי נהיגה
class MultiplicationRacingGame extends StatefulWidget {
  const MultiplicationRacingGame({super.key});

  @override
  State<MultiplicationRacingGame> createState() => _MultiplicationRacingGameState();
}

enum GameMode { multiplication, additionSubtraction }

class _MultiplicationRacingGameState extends State<MultiplicationRacingGame>
    with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();
  bool _isHebrew = true;

  // Game mode
  GameMode? _selectedMode;

  // Game state
  int _currentLane = 1; // 0-3 lanes
  int _score = 0;
  int _correctAnswers = 0;
  int _level = 1;
  bool _gameStarted = false;
  bool _gameOver = false;

  // Best scores (separate for each mode)
  int _bestScoreMultiplication = 0;
  int _bestCorrectMultiplication = 0;
  int _bestScoreAddSub = 0;
  int _bestCorrectAddSub = 0;

  // Current question
  int? _num1;
  int? _num2;
  String? _operation; // '+', '-', or '×'
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
      _bestScoreMultiplication = prefs.getInt('racing_mult_best_score') ?? 0;
      _bestCorrectMultiplication = prefs.getInt('racing_mult_best_correct') ?? 0;
      _bestScoreAddSub = prefs.getInt('racing_addsub_best_score') ?? 0;
      _bestCorrectAddSub = prefs.getInt('racing_addsub_best_correct') ?? 0;
    });
  }

  Future<void> _saveBestScores() async {
    final prefs = await SharedPreferences.getInstance();

    if (_selectedMode == GameMode.multiplication) {
      if (_correctAnswers > _bestCorrectMultiplication ||
          (_correctAnswers == _bestCorrectMultiplication && _elapsedSeconds < _bestScoreMultiplication && _bestScoreMultiplication > 0)) {
        await prefs.setInt('racing_mult_best_score', _elapsedSeconds);
        await prefs.setInt('racing_mult_best_correct', _correctAnswers);
        setState(() {
          _bestScoreMultiplication = _elapsedSeconds;
          _bestCorrectMultiplication = _correctAnswers;
        });
      }
    } else {
      if (_correctAnswers > _bestCorrectAddSub ||
          (_correctAnswers == _bestCorrectAddSub && _elapsedSeconds < _bestScoreAddSub && _bestScoreAddSub > 0)) {
        await prefs.setInt('racing_addsub_best_score', _elapsedSeconds);
        await prefs.setInt('racing_addsub_best_correct', _correctAnswers);
        setState(() {
          _bestScoreAddSub = _elapsedSeconds;
          _bestCorrectAddSub = _correctAnswers;
        });
      }
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
    if (_selectedMode == GameMode.multiplication) {
      // Multiplication mode
      int maxNum1 = min(9, 3 + (_level ~/ 3));
      int maxNum2 = min(9, 3 + (_level ~/ 3));

      if (_level > 10) {
        maxNum1 = min(15, 8 + (_level ~/ 5));
        maxNum2 = min(12, 6 + (_level ~/ 5));
      }

      setState(() {
        _num1 = _random.nextInt(maxNum1) + 2;
        _num2 = _random.nextInt(maxNum2) + 2;
        _operation = '×';
        _correctAnswer = _num1! * _num2!;
      });
    } else {
      // Addition/Subtraction mode
      final useAddition = _random.nextBool();
      int maxNum = min(20, 10 + (_level ~/ 2));

      if (_level > 10) {
        maxNum = min(50, 15 + (_level));
      }

      setState(() {
        if (useAddition) {
          _num1 = _random.nextInt(maxNum) + 1;
          _num2 = _random.nextInt(maxNum) + 1;
          _operation = '+';
          _correctAnswer = _num1! + _num2!;
        } else {
          // For subtraction, ensure num1 > num2 for positive results
          _num1 = _random.nextInt(maxNum) + 5;
          _num2 = _random.nextInt(_num1! - 1) + 1;
          _operation = '-';
          _correctAnswer = _num1! - _num2!;
        }
      });
    }

    setState(() {
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
    final currentBest = _selectedMode == GameMode.multiplication
        ? _bestCorrectMultiplication
        : _bestCorrectAddSub;
    final currentBestTime = _selectedMode == GameMode.multiplication
        ? _bestScoreMultiplication
        : _bestScoreAddSub;

    final isNewRecord = _correctAnswers > currentBest ||
        (_correctAnswers == currentBest && _elapsedSeconds < currentBestTime);

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
              '$currentBest ${_isHebrew ? 'תשובות ב-' : 'answers in '} ${currentBestTime}s',
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
              setState(() {
                _selectedMode = null;
              });
            },
            child: Text(
              _isHebrew ? 'חזור לתפריט' : 'Back to Menu',
              style: const TextStyle(fontSize: 16),
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
      // Fixed: swipe left = go left (decrease lane), swipe right = go right (increase lane)
      if (delta < 0 && _currentLane > 0) {
        _currentLane--;
      } else if (delta > 0 && _currentLane < 3) {
        _currentLane++;
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
              if (_selectedMode == null) ...[
                _buildModeSelectionScreen(responsive),
              ] else if (_gameStarted && !_gameOver) ...[
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
                  onPressed: () {
                    if (_selectedMode != null && !_gameStarted) {
                      setState(() {
                        _selectedMode = null;
                      });
                    } else {
                      Navigator.pop(context);
                    }
                  },
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

  Widget _buildModeSelectionScreen(ResponsiveHelper responsive) {
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
            _isHebrew ? 'מרוץ מתמטיקה' : 'Math Racing',
            style: TextStyle(
              fontSize: responsive.fontSize(36),
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
          SizedBox(height: responsive.spacing(10)),
          Text(
            _isHebrew ? 'בחר מצב משחק:' : 'Choose game mode:',
            style: TextStyle(
              fontSize: responsive.fontSize(20),
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: responsive.spacing(30)),
          _buildModeButton(
            responsive,
            icon: '✖️',
            title: _isHebrew ? 'כפל' : 'Multiplication',
            description: _isHebrew ? 'תרגול לוח הכפל' : 'Practice multiplication',
            color: Colors.purple,
            bestScore: _bestCorrectMultiplication,
            bestTime: _bestScoreMultiplication,
            onTap: () {
              setState(() {
                _selectedMode = GameMode.multiplication;
              });
            },
          ),
          SizedBox(height: responsive.spacing(20)),
          _buildModeButton(
            responsive,
            icon: '➕➖',
            title: _isHebrew ? 'חיבור וחיסור' : 'Addition & Subtraction',
            description: _isHebrew ? 'תרגול חיבור וחיסור' : 'Practice addition and subtraction',
            color: Colors.teal,
            bestScore: _bestCorrectAddSub,
            bestTime: _bestScoreAddSub,
            onTap: () {
              setState(() {
                _selectedMode = GameMode.additionSubtraction;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    ResponsiveHelper responsive, {
    required String icon,
    required String title,
    required String description,
    required Color color,
    required int bestScore,
    required int bestTime,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: responsive.spacing(30)),
        padding: EdgeInsets.all(responsive.spacing(20)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 32)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: responsive.fontSize(20),
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: responsive.fontSize(14),
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (bestScore > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🏆 ${_isHebrew ? 'שיא:' : 'Best:'}',
                      style: TextStyle(
                        fontSize: responsive.fontSize(14),
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$bestScore ${_isHebrew ? 'ב-' : 'in'} ${bestTime}s',
                      style: TextStyle(
                        fontSize: responsive.fontSize(14),
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStartScreen(ResponsiveHelper responsive) {
    final currentBest = _selectedMode == GameMode.multiplication
        ? _bestCorrectMultiplication
        : _bestCorrectAddSub;
    final currentBestTime = _selectedMode == GameMode.multiplication
        ? _bestScoreMultiplication
        : _bestScoreAddSub;

    final modeTitle = _selectedMode == GameMode.multiplication
        ? (_isHebrew ? 'מרוץ כפל' : 'Multiplication Racing')
        : (_isHebrew ? 'מרוץ חיבור וחיסור' : 'Addition & Subtraction Racing');

    final modeIcon = _selectedMode == GameMode.multiplication ? '✖️' : '➕➖';
    final modeInstruction = _selectedMode == GameMode.multiplication
        ? (_isHebrew ? 'ענה על שאלות כפל' : 'Answer multiplication questions')
        : (_isHebrew ? 'ענה על שאלות חיבור וחיסור' : 'Answer addition and subtraction questions');

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
            modeTitle,
            style: TextStyle(
              fontSize: responsive.fontSize(32),
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
            textAlign: TextAlign.center,
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
                _buildInstruction(modeIcon, modeInstruction),
                _buildInstruction('⚡', _isHebrew ? 'ככל שעולים ברמה המהירות עולה' : 'Speed increases with levels'),
                _buildInstruction('🏆', _isHebrew ? 'נסה להשיג את השיא!' : 'Try to beat the record!'),
                const SizedBox(height: 20),
                if (currentBest > 0) ...[
                  Text(
                    _isHebrew ? 'השיא שלך:' : 'Your Best:',
                    style: TextStyle(
                      fontSize: responsive.fontSize(16),
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    '$currentBest ${_isHebrew ? 'תשובות ב-' : 'answers in '} ${currentBestTime}s',
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
                  '$_num1 $_operation $_num2 = ?',
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

    // Draw answer blocks (all same color - don't reveal the answer!)
    if (answerPosition > -100 && answerPosition < size.height) {
      for (int i = 0; i < 4; i++) {
        final laneX = size.width * 0.1 + (laneWidth * i) + (laneWidth / 2);
        final answer = answers[i];

        final blockPaint = Paint()
          ..color = Colors.blue.shade400;

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

    // Draw car with better graphics
    final carLaneX = size.width * 0.1 + (laneWidth * currentLane) + (laneWidth / 2);
    final carY = size.height * 0.75;
    final carWidth = laneWidth * 0.7;
    final carHeight = 80.0;

    // Car body (main)
    final carBodyPaint = Paint()..color = Colors.red.shade600;
    final carBodyRect = Rect.fromCenter(
      center: Offset(carLaneX, carY),
      width: carWidth,
      height: carHeight * 0.6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(carBodyRect, const Radius.circular(8)),
      carBodyPaint,
    );

    // Car roof
    final roofPaint = Paint()..color = Colors.red.shade700;
    final roofRect = Rect.fromCenter(
      center: Offset(carLaneX, carY - carHeight * 0.25),
      width: carWidth * 0.7,
      height: carHeight * 0.35,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(roofRect, const Radius.circular(6)),
      roofPaint,
    );

    // Windows
    final windowPaint = Paint()..color = Colors.lightBlue.shade100;

    // Front window
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(carLaneX, carY - carHeight * 0.25),
          width: carWidth * 0.5,
          height: carHeight * 0.25,
        ),
        const Radius.circular(4),
      ),
      windowPaint,
    );

    // Wheels
    final wheelPaint = Paint()..color = Colors.grey.shade900;
    final wheelRadius = carWidth * 0.15;

    // Left wheel
    canvas.drawCircle(
      Offset(carLaneX - carWidth * 0.25, carY + carHeight * 0.35),
      wheelRadius,
      wheelPaint,
    );

    // Right wheel
    canvas.drawCircle(
      Offset(carLaneX + carWidth * 0.25, carY + carHeight * 0.35),
      wheelRadius,
      wheelPaint,
    );

    // Wheel rims
    final rimPaint = Paint()..color = Colors.grey.shade400;
    canvas.drawCircle(
      Offset(carLaneX - carWidth * 0.25, carY + carHeight * 0.35),
      wheelRadius * 0.5,
      rimPaint,
    );
    canvas.drawCircle(
      Offset(carLaneX + carWidth * 0.25, carY + carHeight * 0.35),
      wheelRadius * 0.5,
      rimPaint,
    );

    // Headlights
    final headlightPaint = Paint()..color = Colors.yellow.shade300;
    canvas.drawCircle(
      Offset(carLaneX + carWidth * 0.3, carY + carHeight * 0.1),
      4,
      headlightPaint,
    );
  }

  @override
  bool shouldRepaint(RoadPainter oldDelegate) => true;
}
