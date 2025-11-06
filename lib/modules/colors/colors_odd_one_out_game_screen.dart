import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../providers/app_provider.dart';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// משחק מציאת הצבע המשונה - זיהוי ויזואלי של הצבע השונה
class ColorsOddOneOutGameScreen extends StatefulWidget {
  const ColorsOddOneOutGameScreen({super.key});

  @override
  State<ColorsOddOneOutGameScreen> createState() => _ColorsOddOneOutGameScreenState();
}

class _ColorsOddOneOutGameScreenState extends State<ColorsOddOneOutGameScreen>
    with SingleTickerProviderStateMixin {
  bool _isInitialized = false;
  bool _isHebrew = true;

  // Game state
  int _difficultyLevel = 1; // 1=Easy (6 circles), 2=Medium (9 circles), 3=Hard (12 circles)
  bool _gameStarted = false;
  int _score = 0;
  int _totalQuestions = 0;
  int _correctAnswers = 0;

  // Current round
  late Color _mainColor;
  late Color _oddColor;
  late int _oddIndex;
  late int _totalCircles;
  List<bool> _tapped = [];

  // Animation
  late AnimationController _animationController;
  bool _showCelebration = false;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isHebrew = Localizations.localeOf(context).languageCode == 'he';
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startGame(int difficulty) {
    setState(() {
      _difficultyLevel = difficulty;
      _gameStarted = true;
      _score = 0;
      _totalQuestions = 0;
      _correctAnswers = 0;
      _generateRound();
    });
  }

  void _generateRound() {
    final random = Random();

    // Determine number of circles based on difficulty
    switch (_difficultyLevel) {
      case 1:
        _totalCircles = 6;
        break;
      case 2:
        _totalCircles = 9;
        break;
      case 3:
        _totalCircles = 12;
        break;
      default:
        _totalCircles = 6;
    }

    // Generate colors based on difficulty
    if (_difficultyLevel == 1) {
      // Easy: very different colors
      _mainColor = _getRandomColor(random);
      _oddColor = _getDifferentColor(_mainColor, random);
    } else if (_difficultyLevel == 2) {
      // Medium: somewhat similar colors
      _mainColor = _getRandomColor(random);
      _oddColor = _getSimilarColor(_mainColor, random, similarity: 0.5);
    } else {
      // Hard: very similar colors (shades)
      _mainColor = _getRandomColor(random);
      _oddColor = _getSimilarColor(_mainColor, random, similarity: 0.8);
    }

    // Pick random position for odd color
    _oddIndex = random.nextInt(_totalCircles);

    // Initialize tapped state
    _tapped = List.filled(_totalCircles, false);

    setState(() {
      _totalQuestions++;
      _showCelebration = false;
      _selectedIndex = null;
    });

    // Speak instructions
    _speakInstructions();
  }

  Color _getRandomColor(Random random) {
    final colors = [
      Colors.red.shade600,
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.yellow.shade700,
      Colors.purple.shade600,
      Colors.orange.shade600,
      Colors.pink.shade600,
      Colors.teal.shade600,
      Colors.brown.shade600,
      Colors.indigo.shade600,
    ];
    return colors[random.nextInt(colors.length)];
  }

  Color _getDifferentColor(Color baseColor, Random random) {
    Color newColor;
    do {
      newColor = _getRandomColor(random);
    } while (_colorsAreSimilar(baseColor, newColor));
    return newColor;
  }

  Color _getSimilarColor(Color baseColor, Random random, {double similarity = 0.5}) {
    // Create a similar color by adjusting RGB values slightly
    final variance = (255 * (1 - similarity)).toInt();

    int adjustValue(int value) {
      final adjustment = random.nextInt(variance * 2) - variance;
      return (value + adjustment).clamp(0, 255);
    }

    return Color.fromARGB(
      255,
      adjustValue(baseColor.red),
      adjustValue(baseColor.green),
      adjustValue(baseColor.blue),
    );
  }

  bool _colorsAreSimilar(Color c1, Color c2) {
    final rDiff = (c1.red - c2.red).abs();
    final gDiff = (c1.green - c2.green).abs();
    final bDiff = (c1.blue - c2.blue).abs();
    final totalDiff = rDiff + gDiff + bDiff;
    return totalDiff < 150; // Threshold for similarity
  }

  void _speakInstructions() {
    final appProvider = context.read<AppProvider>();
    final instruction = _isHebrew
        ? 'מצא את הצבע השונה'
        : 'Find the different color';
    appProvider.speak(instruction);
  }

  void _checkAnswer(int index) {
    if (_showCelebration || _selectedIndex != null) return;

    final appProvider = context.read<AppProvider>();
    final isCorrect = index == _oddIndex;

    setState(() {
      _selectedIndex = index;
      _tapped[index] = true;
    });

    if (isCorrect) {
      setState(() {
        _correctAnswers++;
        _score += 10;
        _showCelebration = true;
      });

      _animationController.forward(from: 0);

      appProvider.speak(_isHebrew ? 'כל הכבוד!' : 'Great job!');

      // Wait and move to next round
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          if (_totalQuestions < 10) {
            _generateRound();
          } else {
            _showGameOver();
          }
        }
      });
    } else {
      // Wrong answer
      appProvider.speak(_isHebrew ? 'נסה שוב' : 'Try again');

      // Reset selection after brief delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _selectedIndex = null;
            _tapped[index] = false;
          });
        }
      });
    }
  }

  void _showGameOver() {
    final l10n = AppLocalizations.of(context)!;
    final percentage = (_correctAnswers / _totalQuestions * 100).round();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          _isHebrew ? '🎉 כל הכבוד! 🎉' : '🎉 Great Job! 🎉',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isHebrew
                  ? 'סיימת את המשחק!'
                  : 'You completed the game!',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              _isHebrew
                  ? 'תשובות נכונות: $_correctAnswers/$_totalQuestions'
                  : 'Correct answers: $_correctAnswers/$_totalQuestions',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: percentage >= 70 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _isHebrew ? 'ניקוד: $_score' : 'Score: $_score',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _gameStarted = false;
              });
            },
            child: Text(_isHebrew ? 'חזרה לתפריט' : 'Back to Menu'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startGame(_difficultyLevel);
            },
            child: Text(_isHebrew ? 'שחק שוב' : 'Play Again'),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      _gameStarted = false;
      _score = 0;
      _totalQuestions = 0;
      _correctAnswers = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final responsive = ResponsiveHelper(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isHebrew ? 'מצא את השונה 🔍' : 'Find the Odd One 🔍'),
        centerTitle: true,
        backgroundColor: Colors.pink,
        actions: [
          if (_gameStarted)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetGame,
              tooltip: _isHebrew ? 'התחל מחדש' : 'Restart',
            ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.pink.shade50,
              Colors.purple.shade50,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: _gameStarted ? _buildGameView(responsive, l10n) : _buildDifficultySelector(responsive, l10n),
        ),
      ),
    );
  }

  Widget _buildDifficultySelector(ResponsiveHelper responsive, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isHebrew ? '🔍 בחר רמת קושי 🔍' : '🔍 Choose Difficulty 🔍',
            style: TextStyle(
              fontSize: responsive.fontSize(32),
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade700,
            ),
          ),
          SizedBox(height: responsive.spacing(40)),

          Padding(
            padding: responsive.safePadding,
            child: KidButton(
              text: _isHebrew ? 'קל (6 עיגולים) ⭐' : 'Easy (6 circles) ⭐',
              icon: Icons.sentiment_very_satisfied,
              onPressed: () => _startGame(1),
              color: Colors.green.shade400,
              width: responsive.width(80),
              height: responsive.buttonHeight,
            ),
          ),
          SizedBox(height: responsive.verticalSpacing),

          Padding(
            padding: responsive.safePadding,
            child: KidButton(
              text: _isHebrew ? 'בינוני (9 עיגולים) ⭐⭐' : 'Medium (9 circles) ⭐⭐',
              icon: Icons.sentiment_satisfied,
              onPressed: () => _startGame(2),
              color: Colors.orange.shade400,
              width: responsive.width(80),
              height: responsive.buttonHeight,
            ),
          ),
          SizedBox(height: responsive.verticalSpacing),

          Padding(
            padding: responsive.safePadding,
            child: KidButton(
              text: _isHebrew ? 'קשה (12 עיגולים) ⭐⭐⭐' : 'Hard (12 circles) ⭐⭐⭐',
              icon: Icons.emoji_events,
              onPressed: () => _startGame(3),
              color: Colors.red.shade400,
              width: responsive.width(80),
              height: responsive.buttonHeight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameView(ResponsiveHelper responsive, AppLocalizations l10n) {
    return Column(
      children: [
        // Stats panel
        _buildStatsPanel(responsive),
        const SizedBox(height: 12),

        // Instructions
        _buildInstructions(responsive),
        const SizedBox(height: 16),

        // Color grid (Expanded to fill available space)
        Expanded(
          child: _buildColorGrid(responsive),
        ),

        // Bottom buttons
        _buildBottomButtons(responsive),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildStatsPanel(ResponsiveHelper responsive) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pink.shade200, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('⭐', '$_score', responsive),
          _buildStatItem('✅', '$_correctAnswers/$_totalQuestions', responsive),
          _buildStatItem('❓', '${10 - _totalQuestions}', responsive),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, ResponsiveHelper responsive) {
    return Row(
      children: [
        Text(emoji, style: TextStyle(fontSize: responsive.fontSize(24))),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: responsive.fontSize(20),
            fontWeight: FontWeight.bold,
            color: Colors.pink.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions(ResponsiveHelper responsive) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pink.shade200, width: 2),
      ),
      child: Center(
        child: Text(
          _isHebrew
              ? 'מצא את הצבע השונה! 🔍'
              : 'Find the different color! 🔍',
          style: TextStyle(
            fontSize: responsive.fontSize(24),
            fontWeight: FontWeight.bold,
            color: Colors.pink.shade700,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildColorGrid(ResponsiveHelper responsive) {
    // Determine grid layout
    int crossAxisCount;
    switch (_difficultyLevel) {
      case 1:
        crossAxisCount = 3; // 3x2 grid for 6 circles
        break;
      case 2:
        crossAxisCount = 3; // 3x3 grid for 9 circles
        break;
      case 3:
        crossAxisCount = 4; // 4x3 grid for 12 circles
        break;
      default:
        crossAxisCount = 3;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        itemCount: _totalCircles,
        itemBuilder: (context, index) {
          return _buildColorCircle(index, responsive);
        },
      ),
    );
  }

  Widget _buildColorCircle(int index, ResponsiveHelper responsive) {
    final isOdd = index == _oddIndex;
    final color = isOdd ? _oddColor : _mainColor;
    final isSelected = _selectedIndex == index;
    final isCorrectlySelected = isSelected && isOdd;
    final isWronglySelected = isSelected && !isOdd;

    return GestureDetector(
      onTap: () => _checkAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: isCorrectlySelected
                ? Colors.green.shade700
                : isWronglySelected
                    ? Colors.red.shade700
                    : Colors.white,
            width: isSelected ? 6 : 3,
          ),
          boxShadow: [
            BoxShadow(
              color: isCorrectlySelected
                  ? Colors.green.shade200
                  : isWronglySelected
                      ? Colors.red.shade200
                      : color.withOpacity(0.5),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isCorrectlySelected && _showCelebration
            ? ScaleTransition(
                scale: Tween<double>(begin: 1.0, end: 1.2).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.elasticOut,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '🎉',
                    style: TextStyle(fontSize: 48),
                  ),
                ),
              )
            : isWronglySelected
                ? const Center(
                    child: Text(
                      '❌',
                      style: TextStyle(fontSize: 36),
                    ),
                  )
                : null,
      ),
    );
  }

  Widget _buildBottomButtons(ResponsiveHelper responsive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: KidButton(
              text: _isHebrew ? 'הקשב 🔊' : 'Listen 🔊',
              onPressed: _speakInstructions,
              color: Colors.green.shade400,
              height: 60,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: KidButton(
              text: _isHebrew ? 'דלג ⏭️' : 'Skip ⏭️',
              onPressed: () {
                if (_totalQuestions < 10) {
                  _generateRound();
                } else {
                  _showGameOver();
                }
              },
              color: Colors.orange.shade400,
              height: 60,
            ),
          ),
        ],
      ),
    );
  }
}
