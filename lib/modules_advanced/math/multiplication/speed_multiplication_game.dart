import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:math';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/kid_button.dart';
import '../../../widgets/kid_back_button.dart';
import '../../../widgets/reward_animation.dart';

/// משחק כפל מהיר עם טיימר - כמה מהר אתה יכול לענות?
class SpeedMultiplicationGame extends StatefulWidget {
  const SpeedMultiplicationGame({super.key});

  @override
  State<SpeedMultiplicationGame> createState() =>
      _SpeedMultiplicationGameState();
}

class _SpeedMultiplicationGameState extends State<SpeedMultiplicationGame> {
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();

  bool _isHebrew = true;
  bool _gameStarted = false;
  int _maxNumber = 5;
  int _totalQuestions = 10;
  int _currentQuestion = 0;
  int _score = 0;
  int _timeLeft = 60; // 60 seconds
  Timer? _timer;

  int? _num1;
  int? _num2;
  List<int> _answerOptions = [];
  int? _selectedAnswer;
  bool? _isCorrect;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    // Hide system UI (navigation bar)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isHebrew = Localizations.localeOf(context).languageCode == 'he';
      });
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    final lang = _isHebrew ? 'he-IL' : 'en-US';
    await _flutterTts.setLanguage(lang);
    await _flutterTts.speak(text);
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _currentQuestion = 0;
      _score = 0;
      _timeLeft = 60;
      _showResult = false;
    });

    _startTimer();
    _generateQuestion();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _endGame();
      }
    });
  }

  void _generateQuestion() {
    setState(() {
      _num1 = _random.nextInt(_maxNumber) + 1;
      _num2 = _random.nextInt(_maxNumber) + 1;
      _selectedAnswer = null;
      _isCorrect = null;
    });

    _generateAnswerOptions();
  }

  void _generateAnswerOptions() {
    final correctAnswer = _num1! * _num2!;
    final options = <int>{correctAnswer};

    // Generate 3 wrong answers
    while (options.length < 4) {
      int wrongAnswer;
      if (_random.nextBool()) {
        wrongAnswer = correctAnswer + _random.nextInt(10) + 1;
      } else {
        wrongAnswer = max(1, correctAnswer - _random.nextInt(10) - 1);
      }
      if (wrongAnswer > 0 && wrongAnswer != correctAnswer) {
        options.add(wrongAnswer);
      }
    }

    setState(() {
      _answerOptions = options.toList()..shuffle();
    });
  }

  void _checkAnswer(int answer) {
    final correctAnswer = _num1! * _num2!;
    final isCorrect = answer == correctAnswer;

    setState(() {
      _selectedAnswer = answer;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      setState(() {
        _score++;
      });
      _speak(_isHebrew ? 'נכון!' : 'Correct!');
    } else {
      _speak(_isHebrew ? 'לא נכון' : 'Wrong');
      // Reset after wrong answer to allow retry
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && _isCorrect == false && _gameStarted) {
          setState(() {
            _selectedAnswer = null;
            _isCorrect = null;
          });
        }
      });
      return;
    }

    // Next question after 1500ms for correct answer
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _gameStarted) {
        setState(() {
          _currentQuestion++;
        });

        if (_currentQuestion < _totalQuestions) {
          _generateQuestion();
        } else {
          _endGame();
        }
      }
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() {
      _gameStarted = false;
      _showResult = true;
    });

    // Speak final score
    final percentage = (_score / _totalQuestions * 100).toInt();
    if (percentage >= 80) {
      _speak(_isHebrew ? 'מעולה!' : 'Excellent!');
    } else if (percentage >= 60) {
      _speak(_isHebrew ? 'טוב מאוד!' : 'Very good!');
    } else {
      _speak(_isHebrew ? 'תתאמן עוד קצת' : 'Keep practicing');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flutterTts.stop();
    // Restore system UI when leaving
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange.shade50, Colors.red.shade50],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              if (!_gameStarted && !_showResult)
                _buildStartScreen(responsive)
              else if (_gameStarted)
                _buildGameScreen(responsive)
              else
                _buildResultScreen(responsive),

              // Reward animation
              if (_isCorrect == true) const RewardAnimation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartScreen(ResponsiveHelper responsive) {
    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.all(responsive.spacing(12)),
          child: Stack(
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      '⚡',
                      style: TextStyle(fontSize: responsive.iconSize(80)),
                    ),
                    SizedBox(height: responsive.spacing(12)),
                    Text(
                      _isHebrew ? 'כפל מהיר' : 'Speed Multiplication',
                      style: TextStyle(
                        fontSize: responsive.titleSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: _isHebrew ? 0 : null,
                left: _isHebrew ? null : 0,
                child: KidBackButton(
                  onPressed: () => Navigator.pop(context),
                  color: Colors.orange.shade600,
                  isHebrew: _isHebrew,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: responsive.spacing(8)),

        // Instructions
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.spacing(32)),
          child: Column(
            children: [
              _buildInfoCard(
                responsive,
                icon: '❓',
                title: _isHebrew ? '10 שאלות' : '10 Questions',
                description: _isHebrew
                    ? 'ענה על כמה שיותר שאלות נכונות'
                    : 'Answer as many correctly as you can',
              ),
              SizedBox(height: responsive.spacing(6)),
              _buildInfoCard(
                responsive,
                icon: '⏱️',
                title: _isHebrew ? '60 שניות' : '60 Seconds',
                description: _isHebrew
                    ? 'כמה מהר אתה יכול לענות?'
                    : 'How fast can you answer?',
              ),
              SizedBox(height: responsive.spacing(6)),
              _buildInfoCard(
                responsive,
                icon: '🏆',
                title: _isHebrew ? 'צבור ניקוד' : 'Score Points',
                description: _isHebrew
                    ? 'תשובה נכונה = נקודה אחת'
                    : 'Correct answer = 1 point',
              ),
            ],
          ),
        ),

        SizedBox(height: responsive.spacing(8)),

        // Difficulty selector
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
          child: Column(
            children: [
              Text(
                _isHebrew ? 'בחר רמת קושי:' : 'Choose difficulty:',
                style: TextStyle(
                  fontSize: responsive.fontSize(18),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: responsive.spacing(12)),
              Row(
                children: [
                  Expanded(
                    child: _buildDifficultyButton(5, '1-5', Colors.green, responsive),
                  ),
                  SizedBox(width: responsive.spacing(8)),
                  Expanded(
                    child: _buildDifficultyButton(10, '1-10', Colors.orange, responsive),
                  ),
                  SizedBox(width: responsive.spacing(8)),
                  Expanded(
                    child: _buildDifficultyButton(12, '1-12', Colors.red, responsive),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: responsive.spacing(12)),

        // Start button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
          child: KidButton(
            text: _isHebrew ? 'התחל משחק! 🚀' : 'Start Game! 🚀',
            icon: Icons.play_arrow,
            onPressed: _startGame,
            color: Colors.orange,
            height: 70,
          ),
        ),

        SizedBox(height: responsive.spacing(6)),
      ],
    );
  }

  Widget _buildInfoCard(
    ResponsiveHelper responsive, {
    required String icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade300, width: 2),
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: TextStyle(fontSize: responsive.iconSize(32)),
          ),
          SizedBox(width: responsive.spacing(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: responsive.fontSize(15),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: responsive.fontSize(13),
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton(
    int max,
    String label,
    Color color,
    ResponsiveHelper responsive,
  ) {
    final isSelected = _maxNumber == max;
    return InkWell(
      onTap: () => setState(() => _maxNumber = max),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: responsive.spacing(12)),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameScreen(ResponsiveHelper responsive) {
    return Column(
      children: [
        // Header with timer, score and back button
        Container(
          padding: EdgeInsets.all(responsive.spacing(12)),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              KidBackButton(
                onPressed: () => Navigator.pop(context),
                color: Colors.orange.shade600,
                isHebrew: _isHebrew,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      responsive,
                      icon: '⏱️',
                      value: '$_timeLeft',
                      label: _isHebrew ? 'שניות' : 'sec',
                      color: _timeLeft <= 10 ? Colors.red : Colors.blue,
                    ),
                    _buildStatCard(
                      responsive,
                      icon: '❓',
                      value: '${_currentQuestion + 1}/$_totalQuestions',
                      label: _isHebrew ? 'שאלה' : 'Q',
                      color: Colors.purple,
                    ),
                    _buildStatCard(
                      responsive,
                      icon: '✅',
                      value: '$_score',
                      label: _isHebrew ? 'נכונות' : 'correct',
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
              SizedBox(width: responsive.spacing(48)),
            ],
          ),
        ),

        SizedBox(height: responsive.spacing(20)),

        // Question
        Text(
          '$_num1 ✖️ $_num2 = ?',
          style: TextStyle(
            fontSize: responsive.fontSize(40),
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade700,
          ),
        ),

        SizedBox(height: responsive.spacing(16)),

        // Answer options
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.spacing(20),
              vertical: responsive.spacing(8)
            ),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: responsive.spacing(10),
              crossAxisSpacing: responsive.spacing(10),
              childAspectRatio: responsive.quizButtonAspectRatio,
              physics: const NeverScrollableScrollPhysics(),
              children: _answerOptions.map((option) {
                final isSelected = _selectedAnswer == option;

                Color getButtonColor() {
                  if (!isSelected) {
                    return Colors.orange.shade400;
                  }
                  return _isCorrect! ? Colors.green.shade500 : Colors.red.shade500;
                }

                return GestureDetector(
                  onTap: _isCorrect == null ? () => _checkAnswer(option) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          getButtonColor(),
                          getButtonColor().withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(responsive.spacing(20)),
                      boxShadow: [
                        BoxShadow(
                          color: getButtonColor().withOpacity(0.3),
                          blurRadius: responsive.spacing(10),
                          offset: Offset(0, responsive.spacing(6)),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '$option',
                            style: TextStyle(
                              fontSize: responsive.largeNumberSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        SizedBox(height: responsive.spacing(12)),
      ],
    );
  }

  Widget _buildStatCard(
    ResponsiveHelper responsive, {
    required String icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          icon,
          style: TextStyle(fontSize: responsive.iconSize(30)),
        ),
        SizedBox(height: responsive.spacing(4)),
        Text(
          value,
          style: TextStyle(
            fontSize: responsive.fontSize(24),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.fontSize(12),
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildResultScreen(ResponsiveHelper responsive) {
    final percentage = (_score / _totalQuestions * 100).toInt();
    String emoji;
    String message;

    if (percentage >= 80) {
      emoji = '🏆';
      message = _isHebrew ? 'מעולה!' : 'Excellent!';
    } else if (percentage >= 60) {
      emoji = '⭐';
      message = _isHebrew ? 'טוב מאוד!' : 'Very good!';
    } else {
      emoji = '💪';
      message = _isHebrew ? 'תתאמן עוד!' : 'Keep practicing!';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: responsive.iconSize(80)),
        ),
        SizedBox(height: responsive.spacing(16)),
        Text(
          message,
          style: TextStyle(
            fontSize: responsive.fontSize(28),
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade700,
          ),
        ),
        SizedBox(height: responsive.spacing(24)),
        Container(
          margin: EdgeInsets.symmetric(horizontal: responsive.spacing(40)),
          padding: EdgeInsets.all(responsive.spacing(20)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                _isHebrew ? 'הניקוד שלך' : 'Your Score',
                style: TextStyle(
                  fontSize: responsive.fontSize(18),
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: responsive.spacing(10)),
              Text(
                '$_score / $_totalQuestions',
                style: TextStyle(
                  fontSize: responsive.fontSize(42),
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
              SizedBox(height: responsive.spacing(6)),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: responsive.fontSize(22),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: responsive.spacing(24)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
          child: KidButton(
            text: _isHebrew ? 'שחק שוב 🔄' : 'Play Again 🔄',
            icon: Icons.replay,
            onPressed: _startGame,
            color: Colors.orange,
            height: 70,
          ),
        ),
        SizedBox(height: responsive.spacing(16)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
          child: KidButton(
            text: _isHebrew ? 'חזור ⬅️' : 'Back ⬅️',
            icon: Icons.arrow_back,
            onPressed: () => Navigator.pop(context),
            color: Colors.grey,
            height: 70,
          ),
        ),
      ],
    );
  }
}
