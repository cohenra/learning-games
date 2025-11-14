import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:math';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/kid_button.dart';
import '../../../widgets/kid_back_button.dart';

/// משחק מפעל השוקולד - למד כפל על ידי יצירת לוחות שוקולד
class ChocolateFactoryGame extends StatefulWidget {
  const ChocolateFactoryGame({super.key});

  @override
  State<ChocolateFactoryGame> createState() => _ChocolateFactoryGameState();
}

class _ChocolateFactoryGameState extends State<ChocolateFactoryGame>
    with SingleTickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();

  bool _isHebrew = true;
  bool _gameStarted = false;
  int _level = 1;
  int _score = 0;
  int _coins = 0;

  // Current order
  int? _rows;
  int? _cols;
  int _correctAnswer = 0;

  // Animation state
  bool _isBuilding = false;
  int _builtSquares = 0;
  bool _showQuestion = false;
  int? _selectedAnswer;
  bool? _isCorrect;
  List<int> _answerOptions = [];

  // Animation controller
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initTts();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
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

  @override
  void dispose() {
    _flutterTts.stop();
    _animationController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _level = 1;
      _score = 0;
      _coins = 0;
    });
    _generateOrder();
  }

  void _generateOrder() {
    setState(() {
      _isBuilding = false;
      _builtSquares = 0;
      _showQuestion = false;
      _selectedAnswer = null;
      _isCorrect = null;

      // Generate order based on level
      if (_level <= 3) {
        _rows = _random.nextInt(4) + 2; // 2-5
        _cols = _random.nextInt(4) + 2; // 2-5
      } else if (_level <= 6) {
        _rows = _random.nextInt(5) + 3; // 3-7
        _cols = _random.nextInt(5) + 3; // 3-7
      } else {
        _rows = _random.nextInt(7) + 4; // 4-10
        _cols = _random.nextInt(7) + 4; // 4-10
      }

      _correctAnswer = _rows! * _cols!;
    });

    // Speak the order
    _speak(_isHebrew
        ? 'הזמנה חדשה: לוח שוקולד $_rows על $_cols'
        : 'New order: $_rows by $_cols chocolate bar');

    // Start building after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _buildChocolate();
      }
    });
  }

  void _buildChocolate() {
    setState(() {
      _isBuilding = true;
      _builtSquares = 0;
    });

    // Build squares one by one
    Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (!mounted || _builtSquares >= _correctAnswer) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _isBuilding = false;
          });
          // Show question after building is complete
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _showQuestionDialog();
            }
          });
        }
        return;
      }

      setState(() {
        _builtSquares++;
      });
    });
  }

  void _showQuestionDialog() {
    _generateAnswerOptions();
    setState(() {
      _showQuestion = true;
    });
  }

  void _generateAnswerOptions() {
    final options = <int>{_correctAnswer};

    while (options.length < 4) {
      int wrongAnswer;
      if (_random.nextBool()) {
        wrongAnswer = _correctAnswer + _random.nextInt(8) + 1;
      } else {
        wrongAnswer = max(1, _correctAnswer - _random.nextInt(8) - 1);
      }
      if (wrongAnswer > 0 && wrongAnswer != _correctAnswer) {
        options.add(wrongAnswer);
      }
    }

    setState(() {
      _answerOptions = options.toList()..shuffle();
    });
  }

  void _checkAnswer(int answer) {
    final isCorrect = answer == _correctAnswer;

    setState(() {
      _selectedAnswer = answer;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      _speak(_isHebrew ? 'נכון! מעולה!' : 'Correct! Excellent!');
      setState(() {
        _score++;
        _coins += _level * 10;
      });

      // Pack the chocolate and move to next order
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _animationController.forward().then((_) {
            _animationController.reverse();
            setState(() {
              _level++;
            });
            _generateOrder();
          });
        }
      });
    } else {
      _speak(_isHebrew ? 'לא נכון, נסה שוב' : 'Wrong, try again');
      // Reset after wrong answer
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && _isCorrect == false) {
          setState(() {
            _selectedAnswer = null;
            _isCorrect = null;
          });
        }
      });
    }
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
            colors: [Colors.brown.shade50, Colors.orange.shade50],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              if (!_gameStarted)
                _buildStartScreen(responsive)
              else
                _buildGameScreen(responsive),
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
                      '🍫',
                      style: TextStyle(fontSize: responsive.iconSize(80)),
                    ),
                    SizedBox(height: responsive.spacing(12)),
                    Text(
                      _isHebrew ? 'מפעל השוקולד' : 'Chocolate Factory',
                      style: TextStyle(
                        fontSize: responsive.titleSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown.shade700,
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
                  color: Colors.brown.shade600,
                  isHebrew: _isHebrew,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: responsive.spacing(20)),

        // Instructions
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.spacing(32)),
          child: Container(
            padding: EdgeInsets.all(responsive.spacing(20)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.brown.shade300, width: 3),
            ),
            child: Column(
              children: [
                Text(
                  _isHebrew ? 'איך משחקים?' : 'How to Play?',
                  style: TextStyle(
                    fontSize: responsive.fontSize(22),
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade700,
                  ),
                ),
                SizedBox(height: responsive.spacing(12)),
                _buildInstructionItem(
                  responsive,
                  '1️⃣',
                  _isHebrew ? 'קבל הזמנה ללוח שוקולד' : 'Get a chocolate order',
                ),
                _buildInstructionItem(
                  responsive,
                  '2️⃣',
                  _isHebrew ? 'צפה איך הלוח נבנה' : 'Watch it being built',
                ),
                _buildInstructionItem(
                  responsive,
                  '3️⃣',
                  _isHebrew ? 'ספור כמה משבצות יש' : 'Count the squares',
                ),
                _buildInstructionItem(
                  responsive,
                  '4️⃣',
                  _isHebrew ? 'ארוז ושלח את ההזמנה!' : 'Pack and ship!',
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Start button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
          child: KidButton(
            text: _isHebrew ? 'התחל לעבוד! 🏭' : 'Start Working! 🏭',
            icon: Icons.play_arrow,
            onPressed: _startGame,
            color: Colors.brown.shade600,
            height: 70,
          ),
        ),

        SizedBox(height: responsive.spacing(20)),
      ],
    );
  }

  Widget _buildInstructionItem(
      ResponsiveHelper responsive, String emoji, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: responsive.spacing(8)),
      child: Row(
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: responsive.iconSize(28)),
          ),
          SizedBox(width: responsive.spacing(12)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: responsive.fontSize(16),
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen(ResponsiveHelper responsive) {
    return Column(
      children: [
        // Header with score and coins
        Container(
          padding: EdgeInsets.all(responsive.spacing(12)),
          decoration: BoxDecoration(
            color: Colors.brown.shade600,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatBadge(responsive, '📊', '$_level',
                  _isHebrew ? 'רמה' : 'Level'),
              _buildStatBadge(responsive, '✅', '$_score',
                  _isHebrew ? 'הזמנות' : 'Orders'),
              _buildStatBadge(
                  responsive, '🪙', '$_coins', _isHebrew ? 'מטבעות' : 'Coins'),
            ],
          ),
        ),

        SizedBox(height: responsive.spacing(20)),

        // Order info
        if (!_showQuestion)
          Container(
            margin: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
            padding: EdgeInsets.all(responsive.spacing(16)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.brown.shade300, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '📋 ',
                  style: TextStyle(fontSize: responsive.iconSize(32)),
                ),
                Text(
                  _isHebrew
                      ? 'הזמנה: לוח $_rows ✖️ $_cols'
                      : 'Order: $_rows ✖️ $_cols bar',
                  style: TextStyle(
                    fontSize: responsive.fontSize(24),
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade700,
                  ),
                ),
              ],
            ),
          ),

        SizedBox(height: responsive.spacing(20)),

        // Chocolate bar
        Expanded(
          child: Center(
            child: _buildChocolateBar(responsive),
          ),
        ),

        // Question dialog overlay
        if (_showQuestion) _buildQuestionOverlay(responsive),

        SizedBox(height: responsive.spacing(20)),
      ],
    );
  }

  Widget _buildStatBadge(
      ResponsiveHelper responsive, String icon, String value, String label) {
    return Column(
      children: [
        Text(
          icon,
          style: TextStyle(fontSize: responsive.iconSize(28)),
        ),
        SizedBox(height: responsive.spacing(4)),
        Text(
          value,
          style: TextStyle(
            fontSize: responsive.fontSize(20),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.fontSize(12),
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildChocolateBar(ResponsiveHelper responsive) {
    if (_rows == null || _cols == null) return const SizedBox();

    final size = MediaQuery.of(context).size;
    final availableWidth = size.width - 100;
    final availableHeight = size.height - 400;

    double squareSize = min(
      availableWidth / _cols!,
      availableHeight / _rows!,
    ).clamp(20.0, 60.0);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.brown.shade800,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int row = 0; row < _rows!; row++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int col = 0; col < _cols!; col++)
                  _buildChocolateSquare(row, col, squareSize),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildChocolateSquare(int row, int col, double size) {
    final index = row * _cols! + col;
    final isBuilt = index < _builtSquares;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: isBuilt
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.brown.shade400,
                  Colors.brown.shade600,
                ],
              )
            : null,
        color: isBuilt ? null : Colors.brown.shade200.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.brown.shade900,
          width: 1,
        ),
      ),
    );
  }

  Widget _buildQuestionOverlay(ResponsiveHelper responsive) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Container(
            margin: EdgeInsets.all(responsive.spacing(20)),
            padding: EdgeInsets.all(responsive.spacing(24)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isHebrew ? 'כמה משבצות שוקולד?' : 'How many squares?',
                  style: TextStyle(
                    fontSize: responsive.fontSize(26),
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: responsive.spacing(20)),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.5,
                  children: _answerOptions.map((option) {
                    final isSelected = _selectedAnswer == option;
                    Color getButtonColor() {
                      if (!isSelected) {
                        return Colors.brown.shade400;
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
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: getButtonColor().withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '$option',
                            style: TextStyle(
                              fontSize: responsive.fontSize(28),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (_isCorrect != null) ...[
                  SizedBox(height: responsive.spacing(16)),
                  Text(
                    _isCorrect!
                        ? '🎉 ${_isHebrew ? "מעולה! הלוח נארז!" : "Great! Packing!"}'
                        : '❌ ${_isHebrew ? "נסה שוב" : "Try again"}',
                    style: TextStyle(
                      fontSize: responsive.fontSize(20),
                      fontWeight: FontWeight.bold,
                      color: _isCorrect! ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
