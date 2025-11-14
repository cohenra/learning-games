import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
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

class _GardenBuilderGameState extends State<GardenBuilderGame>
    with TickerProviderStateMixin {
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

  // Animation state
  bool _isPlanting = false;
  int _plantedFlowers = 0;
  bool _showQuestion = false;
  int? _selectedAnswer;
  bool? _isCorrect;
  List<int> _answerOptions = [];

  // Bloom animation
  late AnimationController _bloomController;
  late Animation<double> _bloomAnimation;

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
    _bloomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bloomAnimation = CurvedAnimation(
      parent: _bloomController,
      curve: Curves.elasticOut,
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
    _bloomController.dispose();
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
      _isPlanting = false;
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

    // Start planting after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _plantFlowers();
      }
    });
  }

  void _plantFlowers() {
    setState(() {
      _isPlanting = true;
      _plantedFlowers = 0;
    });

    // Plant flowers one by one
    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted || _plantedFlowers >= _correctAnswer) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _isPlanting = false;
          });
          // Show question after planting is complete
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _showQuestionDialog();
            }
          });
        }
        return;
      }

      setState(() {
        _plantedFlowers++;
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
      _speak(_isHebrew ? 'נכון! הפרחים פורחים!' : 'Correct! The flowers bloom!');
      setState(() {
        _score++;
        _totalFlowers += _correctAnswer;
      });

      // Bloom animation
      _bloomController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            _bloomController.reverse();
            setState(() {
              _level++;
            });
            _generateGarden();
          }
        });
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
                      style: TextStyle(fontSize: responsive.iconSize(80)),
                    ),
                    SizedBox(height: responsive.spacing(12)),
                    Text(
                      _isHebrew ? 'בונה הגינה' : 'Garden Builder',
                      style: TextStyle(
                        fontSize: responsive.titleSize,
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

        SizedBox(height: responsive.spacing(20)),

        // Instructions
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.spacing(32)),
          child: Container(
            padding: EdgeInsets.all(responsive.spacing(20)),
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
                    fontSize: responsive.fontSize(22),
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                SizedBox(height: responsive.spacing(12)),
                _buildInstructionItem(
                  responsive,
                  '1️⃣',
                  _isHebrew ? 'קבל משימת גינון' : 'Get a gardening task',
                ),
                _buildInstructionItem(
                  responsive,
                  '2️⃣',
                  _isHebrew ? 'צפה בפרחים צומחים' : 'Watch flowers grow',
                ),
                _buildInstructionItem(
                  responsive,
                  '3️⃣',
                  _isHebrew ? 'ספור כמה פרחים שתלת' : 'Count the flowers',
                ),
                _buildInstructionItem(
                  responsive,
                  '4️⃣',
                  _isHebrew ? 'הפרחים יפרחו!' : 'Flowers bloom!',
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
            text: _isHebrew ? 'התחל לגנן! 🌱' : 'Start Gardening! 🌱',
            icon: Icons.play_arrow,
            onPressed: _startGame,
            color: Colors.green.shade600,
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
        // Header with score and flowers
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

        SizedBox(height: responsive.spacing(20)),

        // Task info
        if (!_showQuestion)
          Container(
            margin: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
            padding: EdgeInsets.all(responsive.spacing(16)),
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
                  style: TextStyle(fontSize: responsive.iconSize(32)),
                ),
                Text(
                  _isHebrew
                      ? 'שתול: $_rows ✖️ $_cols פרחים'
                      : 'Plant: $_rows ✖️ $_cols flowers',
                  style: TextStyle(
                    fontSize: responsive.fontSize(24),
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),

        SizedBox(height: responsive.spacing(20)),

        // Garden
        Expanded(
          child: Center(
            child: _buildGarden(responsive),
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

  Widget _buildGarden(ResponsiveHelper responsive) {
    if (_rows == null || _cols == null) return const SizedBox();

    final size = MediaQuery.of(context).size;
    final availableWidth = size.width - 80;
    final availableHeight = size.height - 400;

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
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      margin: const EdgeInsets.all(3),
      child: isPlanted
          ? ScaleTransition(
              scale: _isCorrect == true ? _bloomAnimation : const AlwaysStoppedAnimation(1.0),
              child: Stack(
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
              ),
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
                  _isHebrew ? 'כמה פרחים שתלת?' : 'How many flowers?',
                  style: TextStyle(
                    fontSize: responsive.fontSize(26),
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
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
                        return Colors.green.shade400;
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
                        ? '🎉 ${_isHebrew ? "מעולה! הפרחים פורחים!" : "Great! Blooming!"}'
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
