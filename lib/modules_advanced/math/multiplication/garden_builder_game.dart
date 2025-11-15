import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/kid_button.dart';
import '../../../widgets/kid_back_button.dart';

/// משחק בונה הגינה - למד כפל על ידי שתילת פרחים
class GardenBuilderGame extends StatefulWidget {
  const GardenBuilderGame({super.key});

  @override
  State<GardenBuilderGame> createState() => _GardenBuilderGameState();
}

class _GardenBuilderGameState extends State<GardenBuilderGame> {
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();

  bool _isHebrew = true;
  bool _gameStarted = false;
  int _level = 1;
  int _score = 0;
  int _totalFlowers = 0;

  // Current garden
  int? _rows;
  int? _cols;
  int _correctAnswer = 0;

  // Planting state
  int _plantedFlowers = 0;
  bool _showQuestion = false;
  int? _selectedAnswer;
  bool? _isCorrect;
  List<int> _answerOptions = [];

  // Flower colors
  final List<Color> _flowerColors = [
    Colors.red.shade400,
    Colors.pink.shade400,
    Colors.purple.shade400,
    Colors.blue.shade400,
    Colors.yellow.shade600,
    Colors.orange.shade400,
  ];

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _flutterTts.stop();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _level = 1;
      _score = 0;
      _totalFlowers = 0;
    });
    _generateGarden();
  }

  void _generateGarden() {
    setState(() {
      _plantedFlowers = 0;
      _showQuestion = false;
      _selectedAnswer = null;
      _isCorrect = null;

      // Generate garden based on level
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

    // Speak the task
    _speak(_isHebrew
        ? 'שתול $_rows שורות עם $_cols פרחים בכל שורה'
        : 'Plant $_rows rows with $_cols flowers each');
  }

  void _plantFlower() {
    setState(() {
      _plantedFlowers++;
    });
  }

  void _removeFlower() {
    if (_plantedFlowers > 0) {
      setState(() {
        _plantedFlowers--;
      });
    }
  }

  void _checkPlanting() {
    if (_plantedFlowers == _correctAnswer) {
      // Correct! Show question
      _showQuestionDialog();
    } else if (_plantedFlowers < _correctAnswer) {
      // Too few
      _speak(_isHebrew ? 'חסרים פרחים!' : 'Too few flowers!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isHebrew
                ? 'אופס! שתלת רק $_plantedFlowers פרחים. צריך $_correctAnswer!'
                : 'Oops! You planted only $_plantedFlowers flowers. Need $_correctAnswer!',
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.orange.shade600,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Too many
      _speak(_isHebrew ? 'יותר מידי פרחים!' : 'Too many flowers!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isHebrew
                ? 'אופס! שתלת $_plantedFlowers פרחים. צריך רק $_correctAnswer!'
                : 'Oops! You planted $_plantedFlowers flowers. Need only $_correctAnswer!',
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
        _totalFlowers += _correctAnswer;
      });

      // Move to next garden
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _level++;
          });
          _generateGarden();
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
            colors: [Colors.green.shade50, Colors.blue.shade50],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              if (!_gameStarted)
                _buildStartScreen(responsive)
              else
                _buildGameScreen(responsive),

              // Question dialog overlay
              if (_showQuestion) _buildQuestionOverlay(responsive),
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
                      '🌻',
                      style: TextStyle(fontSize: responsive.iconSize(60)),
                    ),
                    SizedBox(height: responsive.spacing(8)),
                    Text(
                      _isHebrew ? 'בונה הגינה' : 'Garden Builder',
                      style: TextStyle(
                        fontSize: responsive.fontSize(28),
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
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
                  color: Colors.green.shade600,
                  isHebrew: _isHebrew,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: responsive.spacing(12)),

        // Instructions
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(responsive.spacing(16)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade300, width: 3),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _isHebrew ? 'איך משחקים?' : 'How to Play?',
                        style: TextStyle(
                          fontSize: responsive.fontSize(20),
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      SizedBox(height: responsive.spacing(8)),
                      _buildInstructionItem(
                        responsive,
                        '1️⃣',
                        _isHebrew ? 'קבל משימת גינון' : 'Get a gardening task',
                      ),
                      _buildInstructionItem(
                        responsive,
                        '2️⃣',
                        _isHebrew
                            ? 'לחץ על הגינה כדי לשתול פרחים'
                            : 'Tap the garden to plant flowers',
                      ),
                      _buildInstructionItem(
                        responsive,
                        '3️⃣',
                        _isHebrew ? 'לחץ "בדוק" כשסיימת' : 'Click "Check" when done',
                      ),
                      _buildInstructionItem(
                        responsive,
                        '4️⃣',
                        _isHebrew ? 'ענה על השאלה!' : 'Answer the question!',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Start button
        Padding(
          padding: EdgeInsets.all(responsive.spacing(16)),
          child: KidButton(
            text: _isHebrew ? 'התחל לגנן! 🌱' : 'Start Gardening! 🌱',
            icon: Icons.play_arrow,
            onPressed: _startGame,
            color: Colors.green.shade600,
            height: 70,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionItem(
      ResponsiveHelper responsive, String emoji, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: responsive.spacing(6)),
      child: Row(
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: responsive.iconSize(24)),
          ),
          SizedBox(width: responsive.spacing(8)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: responsive.fontSize(15),
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
        // Header with score, back button and flowers
        Container(
          padding: EdgeInsets.all(responsive.spacing(12)),
          decoration: BoxDecoration(
            color: Colors.green.shade600,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              KidBackButton(
                onPressed: () {
                  setState(() {
                    _gameStarted = false;
                  });
                },
                color: Colors.white,
                isHebrew: _isHebrew,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatBadge(responsive, '📊', '$_level',
                        _isHebrew ? 'רמה' : 'Level'),
                    _buildStatBadge(responsive, '✅', '$_score',
                        _isHebrew ? 'גינות' : 'Gardens'),
                    _buildStatBadge(responsive, '🌸', '$_totalFlowers',
                        _isHebrew ? 'פרחים' : 'Flowers'),
                  ],
                ),
              ),
              SizedBox(width: responsive.spacing(48)),
            ],
          ),
        ),

        SizedBox(height: responsive.spacing(12)),

        // Task info
        Container(
          margin: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
          padding: EdgeInsets.all(responsive.spacing(12)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade300, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🌱 ',
                style: TextStyle(fontSize: responsive.iconSize(28)),
              ),
              Text(
                _isHebrew
                    ? 'שתול: $_rows ✖️ $_cols פרחים'
                    : 'Plant: $_rows ✖️ $_cols flowers',
                style: TextStyle(
                  fontSize: responsive.fontSize(20),
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: responsive.spacing(12)),

        // Garden (clickable)
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: _plantFlower,
              child: _buildGarden(responsive),
            ),
          ),
        ),

        SizedBox(height: responsive.spacing(12)),

        // Add/Remove buttons and Check button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
          child: Row(
            children: [
              // Remove button
              Expanded(
                child: KidButton(
                  text: _isHebrew ? 'הסר 🗑️' : 'Remove 🗑️',
                  icon: Icons.remove_circle,
                  onPressed: _removeFlower,
                  color: Colors.red.shade600,
                  height: 60,
                ),
              ),
              SizedBox(width: responsive.spacing(12)),
              // Add button
              Expanded(
                child: KidButton(
                  text: _isHebrew ? 'הוסף ➕' : 'Add ➕',
                  icon: Icons.add_circle,
                  onPressed: _plantFlower,
                  color: Colors.blue.shade600,
                  height: 60,
                ),
              ),
              SizedBox(width: responsive.spacing(12)),
              // Check button
              Expanded(
                child: KidButton(
                  text: _isHebrew ? 'בדוק ✓' : 'Check ✓',
                  icon: Icons.check_circle,
                  onPressed: _checkPlanting,
                  color: Colors.green.shade600,
                  height: 60,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: responsive.spacing(12)),
      ],
    );
  }

  Widget _buildStatBadge(
      ResponsiveHelper responsive, String icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          icon,
          style: TextStyle(fontSize: responsive.iconSize(24)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: responsive.fontSize(18),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.fontSize(11),
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildGarden(ResponsiveHelper responsive) {
    if (_rows == null || _cols == null) return const SizedBox();

    final size = MediaQuery.of(context).size;
    final availableWidth = size.width - 80;
    final availableHeight = size.height - 450;

    double flowerSize = min(
      availableWidth / _cols!,
      availableHeight / _rows!,
    ).clamp(25.0, 70.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade300, width: 3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int row = 0; row < _rows!; row++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int col = 0; col < _cols!; col++)
                  _buildFlower(row, col, flowerSize),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFlower(int row, int col, double size) {
    final index = row * _cols! + col;
    final isPlanted = index < _plantedFlowers;
    final color = _flowerColors[index % _flowerColors.length];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      margin: const EdgeInsets.all(3),
      child: isPlanted
          ? Stack(
              alignment: Alignment.center,
              children: [
                // Stem
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: 3,
                    height: size * 0.4,
                    color: Colors.green.shade700,
                  ),
                ),
                // Flower
                Positioned(
                  top: 0,
                  child: Container(
                    width: size * 0.5,
                    height: size * 0.5,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: size * 0.2,
                        height: size * 0.2,
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade600,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                // Leaves
                Positioned(
                  left: 0,
                  bottom: size * 0.3,
                  child: Container(
                    width: size * 0.25,
                    height: size * 0.15,
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: size * 0.25,
                  child: Container(
                    width: size * 0.25,
                    height: size * 0.15,
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            )
          : Container(
              decoration: BoxDecoration(
                color: Colors.brown.shade300.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.brown.shade400,
                  width: 1,
                ),
              ),
            ),
    );
  }

  Widget _buildQuestionOverlay(ResponsiveHelper responsive) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: EdgeInsets.all(responsive.spacing(20)),
          padding: EdgeInsets.all(responsive.spacing(20)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      _isHebrew ? 'כמה פרחים שתלת?' : 'How many flowers?',
                      style: TextStyle(
                        fontSize: responsive.fontSize(22),
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    onPressed: () {
                      setState(() {
                        _showQuestion = false;
                        _selectedAnswer = null;
                        _isCorrect = null;
                      });
                    },
                    color: Colors.grey.shade700,
                  ),
                ],
              ),
              SizedBox(height: responsive.spacing(16)),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 3.0,
                children: _answerOptions.map((option) {
                  final isSelected = _selectedAnswer == option;
                  Color getButtonColor() {
                    if (!isSelected) {
                      return Colors.green.shade400;
                    }
                    return _isCorrect!
                        ? Colors.green.shade500
                        : Colors.red.shade500;
                  }

                  return GestureDetector(
                    onTap:
                        _isCorrect == null ? () => _checkAnswer(option) : null,
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
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '$option',
                              style: TextStyle(
                                fontSize: responsive.fontSize(24),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_isCorrect != null) ...[
                SizedBox(height: responsive.spacing(12)),
                Text(
                  _isCorrect!
                      ? '🎉 ${_isHebrew ? "מעולה!" : "Great!"}'
                      : '❌ ${_isHebrew ? "נסה שוב" : "Try again"}',
                  style: TextStyle(
                    fontSize: responsive.fontSize(18),
                    fontWeight: FontWeight.bold,
                    color: _isCorrect! ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
