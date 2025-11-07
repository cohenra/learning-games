import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../providers/app_provider.dart';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// משחק התאמת אותיות לתמונות - התאמה בין אות לתמונה שמתחילה באותה אות
class LettersMatchingGameScreen extends StatefulWidget {
  const LettersMatchingGameScreen({super.key});

  @override
  State<LettersMatchingGameScreen> createState() => _LettersMatchingGameScreenState();
}

class _LettersMatchingGameScreenState extends State<LettersMatchingGameScreen>
    with SingleTickerProviderStateMixin {
  bool _isInitialized = false;
  bool _isHebrew = true;

  // Game state
  int _difficultyLevel = 1; // 1=Easy (3 options), 2=Medium (4 options), 3=Hard (6 options)
  bool _gameStarted = false;
  int _score = 0;
  int _totalQuestions = 0;
  int _correctAnswers = 0;

  // Current question
  late String _currentLetter;
  late String _correctAnswer;
  late List<LetterOption> _options;

  // Animation
  late AnimationController _animationController;
  bool _showCelebration = false;

  // Letter-to-word mappings
  final Map<String, LetterOption> _hebrewLetters = {
    'א': LetterOption(letter: 'א', emoji: '🍎', word: 'תפוח', wordEn: 'Apple'),
    'ב': LetterOption(letter: 'ב', emoji: '🏠', word: 'בית', wordEn: 'House'),
    'ג': LetterOption(letter: 'ג', emoji: '🍦', word: 'גלידה', wordEn: 'Ice Cream'),
    'ד': LetterOption(letter: 'ד', emoji: '🐟', word: 'דג', wordEn: 'Fish'),
    'ה': LetterOption(letter: 'ה', emoji: '🌄', word: 'הר', wordEn: 'Mountain'),
    'ו': LetterOption(letter: 'ו', emoji: '🌹', word: 'ורד', wordEn: 'Rose'),
    'ז': LetterOption(letter: 'ז', emoji: '🐺', word: 'זאב', wordEn: 'Wolf'),
    'ח': LetterOption(letter: 'ח', emoji: '🐱', word: 'חתול', wordEn: 'Cat'),
    'ט': LetterOption(letter: 'ט', emoji: '🦚', word: 'טווס', wordEn: 'Peacock'),
    'י': LetterOption(letter: 'י', emoji: '🦟', word: 'יתוש', wordEn: 'Mosquito'),
    'כ': LetterOption(letter: 'כ', emoji: '⚽', word: 'כדור', wordEn: 'Ball'),
    'ל': LetterOption(letter: 'ל', emoji: '🍞', word: 'לחם', wordEn: 'Bread'),
    'מ': LetterOption(letter: 'מ', emoji: '👑', word: 'מלך', wordEn: 'King'),
    'נ': LetterOption(letter: 'נ', emoji: '🕯️', word: 'נר', wordEn: 'Candle'),
    'ס': LetterOption(letter: 'ס', emoji: '🐴', word: 'סוס', wordEn: 'Horse'),
    'ע': LetterOption(letter: 'ע', emoji: '🌳', word: 'עץ', wordEn: 'Tree'),
    'פ': LetterOption(letter: 'פ', emoji: '🐘', word: 'פיל', wordEn: 'Elephant'),
    'צ': LetterOption(letter: 'צ', emoji: '🐢', word: 'צב', wordEn: 'Turtle'),
    'ק': LetterOption(letter: 'ק', emoji: '🐵', word: 'קוף', wordEn: 'Monkey'),
    'ר': LetterOption(letter: 'ר', emoji: '🚗', word: 'רכב', wordEn: 'Car'),
    'ש': LetterOption(letter: 'ש', emoji: '☀️', word: 'שמש', wordEn: 'Sun'),
    'ת': LetterOption(letter: 'ת', emoji: '🍓', word: 'תות', wordEn: 'Strawberry'),
  };

  final Map<String, LetterOption> _englishLetters = {
    'A': LetterOption(letter: 'A', emoji: '🍎', word: 'Apple', wordEn: 'Apple'),
    'B': LetterOption(letter: 'B', emoji: '🎈', word: 'Balloon', wordEn: 'Balloon'),
    'C': LetterOption(letter: 'C', emoji: '🐱', word: 'Cat', wordEn: 'Cat'),
    'D': LetterOption(letter: 'D', emoji: '🐕', word: 'Dog', wordEn: 'Dog'),
    'E': LetterOption(letter: 'E', emoji: '🐘', word: 'Elephant', wordEn: 'Elephant'),
    'F': LetterOption(letter: 'F', emoji: '🐟', word: 'Fish', wordEn: 'Fish'),
    'G': LetterOption(letter: 'G', emoji: '🎁', word: 'Gift', wordEn: 'Gift'),
    'H': LetterOption(letter: 'H', emoji: '🏠', word: 'House', wordEn: 'House'),
    'I': LetterOption(letter: 'I', emoji: '🍦', word: 'Ice Cream', wordEn: 'Ice Cream'),
    'J': LetterOption(letter: 'J', emoji: '🧃', word: 'Juice', wordEn: 'Juice'),
    'K': LetterOption(letter: 'K', emoji: '🔑', word: 'Key', wordEn: 'Key'),
    'L': LetterOption(letter: 'L', emoji: '🦁', word: 'Lion', wordEn: 'Lion'),
    'M': LetterOption(letter: 'M', emoji: '🐵', word: 'Monkey', wordEn: 'Monkey'),
    'N': LetterOption(letter: 'N', emoji: '🪹', word: 'Nest', wordEn: 'Nest'),
    'O': LetterOption(letter: 'O', emoji: '🍊', word: 'Orange', wordEn: 'Orange'),
    'P': LetterOption(letter: 'P', emoji: '🐼', word: 'Panda', wordEn: 'Panda'),
    'Q': LetterOption(letter: 'Q', emoji: '👸', word: 'Queen', wordEn: 'Queen'),
    'R': LetterOption(letter: 'R', emoji: '🌈', word: 'Rainbow', wordEn: 'Rainbow'),
    'S': LetterOption(letter: 'S', emoji: '☀️', word: 'Sun', wordEn: 'Sun'),
    'T': LetterOption(letter: 'T', emoji: '🐯', word: 'Tiger', wordEn: 'Tiger'),
    'U': LetterOption(letter: 'U', emoji: '☂️', word: 'Umbrella', wordEn: 'Umbrella'),
    'V': LetterOption(letter: 'V', emoji: '🎻', word: 'Violin', wordEn: 'Violin'),
    'W': LetterOption(letter: 'W', emoji: '🍉', word: 'Watermelon', wordEn: 'Watermelon'),
    'X': LetterOption(letter: 'X', emoji: '🎄', word: 'Xmas Tree', wordEn: 'Xmas Tree'),
    'Y': LetterOption(letter: 'Y', emoji: '🧶', word: 'Yarn', wordEn: 'Yarn'),
    'Z': LetterOption(letter: 'Z', emoji: '🦓', word: 'Zebra', wordEn: 'Zebra'),
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
      _generateQuestion();
    });
  }

  void _generateQuestion() {
    final availableLetters = _isHebrew
        ? _hebrewLetters.values.toList()
        : _englishLetters.values.toList();

    // Shuffle and pick letters for this round
    availableLetters.shuffle(Random());

    // Number of options based on difficulty
    int numOptions = _difficultyLevel == 1 ? 3 : (_difficultyLevel == 2 ? 4 : 6);

    // Ensure we have enough letters
    numOptions = min(numOptions, availableLetters.length);

    final selectedOptions = availableLetters.take(numOptions).toList();
    final correctOption = selectedOptions[Random().nextInt(selectedOptions.length)];

    setState(() {
      _currentLetter = correctOption.letter;
      _correctAnswer = correctOption.emoji;
      _options = selectedOptions;
      _options.shuffle(Random());
      _totalQuestions++;
      _showCelebration = false;
    });

    // Speak the letter
    _speakLetter();
  }

  void _speakLetter() {
    final appProvider = context.read<AppProvider>();
    final letterName = _isHebrew
        ? _hebrewLetters[_currentLetter]?.word ?? _currentLetter
        : _englishLetters[_currentLetter]?.word ?? _currentLetter;

    appProvider.speak('$_currentLetter');
  }

  void _checkAnswer(LetterOption selected) {
    final appProvider = context.read<AppProvider>();
    final isCorrect = selected.emoji == _correctAnswer;

    if (isCorrect) {
      setState(() {
        _correctAnswers++;
        _score += 10;
        _showCelebration = true;
      });

      _animationController.forward(from: 0);

      // Speak the word
      final word = _isHebrew ? selected.word : selected.wordEn;
      appProvider.speak(word);

      // Wait and move to next question
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          if (_totalQuestions < 10) {
            _generateQuestion();
          } else {
            _showGameOver();
          }
        }
      });
    } else {
      // Wrong answer - shake animation or feedback
      appProvider.speak(_isHebrew ? 'נסה שוב' : 'Try again');
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
        title: Text(_isHebrew ? 'משחק התאמה 🎯' : 'Matching Game 🎯'),
        centerTitle: true,
        backgroundColor: Colors.blue,
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
              Colors.blue.shade50,
              Colors.purple.shade50,
              Colors.pink.shade50,
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
            _isHebrew ? '🎯 בחר רמת קושי 🎯' : '🎯 Choose Difficulty 🎯',
            style: TextStyle(
              fontSize: responsive.fontSize(32),
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(height: responsive.spacing(40)),

          Padding(
            padding: responsive.safePadding,
            child: KidButton(
              text: _isHebrew ? 'קל (3 אפשרויות) ⭐' : 'Easy (3 options) ⭐',
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
              text: _isHebrew ? 'בינוני (4 אפשרויות) ⭐⭐' : 'Medium (4 options) ⭐⭐',
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
              text: _isHebrew ? 'קשה (6 אפשרויות) ⭐⭐⭐' : 'Hard (6 options) ⭐⭐⭐',
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
        const SizedBox(height: 8),

        // Current letter display
        _buildLetterDisplay(responsive),
        const SizedBox(height: 8),

        // Instruction text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _isHebrew
                ? 'בחר את התמונה שמתחילה באות $_currentLetter'
                : 'Choose the picture that starts with $_currentLetter',
            style: TextStyle(
              fontSize: responsive.fontSize(14),
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 8),

        // Options grid (Expanded to fill available space)
        Expanded(
          child: _buildOptionsGrid(responsive),
        ),

        // Bottom buttons
        _buildBottomButtons(responsive),
        const SizedBox(height: 8),
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
        border: Border.all(color: Colors.blue.shade200, width: 2),
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
            color: Colors.blue.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildLetterDisplay(ResponsiveHelper responsive) {
    return GestureDetector(
      onTap: _speakLetter,
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.purple.shade400],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade200,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: _showCelebration
              ? ScaleTransition(
                  scale: Tween<double>(begin: 0.5, end: 1.2).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.elasticOut,
                    ),
                  ),
                  child: Text(
                    '🎉 $_currentLetter 🎉',
                    style: TextStyle(
                      fontSize: responsive.fontSize(50),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
              : Text(
                  _currentLetter,
                  style: TextStyle(
                    fontSize: responsive.fontSize(50),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildOptionsGrid(ResponsiveHelper responsive) {
    // Determine grid layout based on difficulty
    int crossAxisCount = _difficultyLevel == 3 ? 3 : 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;

        // Calculate number of rows needed
        final rowCount = (_options.length / crossAxisCount).ceil();

        // Calculate spacing
        const padding = 12.0;
        const spacing = 12.0;

        final totalVerticalSpacing = (rowCount - 1) * spacing + (padding * 2);
        final cardHeight = (availableHeight - totalVerticalSpacing) / rowCount;

        final totalHorizontalSpacing = (crossAxisCount - 1) * spacing + (padding * 2);
        final cardWidth = (availableWidth - totalHorizontalSpacing) / crossAxisCount;

        // Calculate aspect ratio based on available space
        final aspectRatio = cardWidth / cardHeight;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: aspectRatio,
            ),
            itemCount: _options.length,
            itemBuilder: (context, index) {
              return _buildOptionCard(_options[index], responsive);
            },
          ),
        );
      },
    );
  }

  Widget _buildOptionCard(LetterOption option, ResponsiveHelper responsive) {
    return GestureDetector(
      onTap: () => _checkAnswer(option),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.shade200, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade100,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              option.emoji,
              style: TextStyle(fontSize: responsive.fontSize(60)),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _isHebrew ? option.word : option.wordEn,
                style: TextStyle(
                  fontSize: responsive.fontSize(16),
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
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
              onPressed: _speakLetter,
              color: Colors.green.shade400,
              height: 50,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: KidButton(
              text: _isHebrew ? 'דלג ⏭️' : 'Skip ⏭️',
              onPressed: () {
                if (_totalQuestions < 10) {
                  _generateQuestion();
                } else {
                  _showGameOver();
                }
              },
              color: Colors.orange.shade400,
              height: 50,
            ),
          ),
        ],
      ),
    );
  }
}

/// מחלקה המייצגת אפשרות של אות עם התמונה והמילה שלה
class LetterOption {
  final String letter;
  final String emoji;
  final String word; // Hebrew word
  final String wordEn; // English word

  LetterOption({
    required this.letter,
    required this.emoji,
    required this.word,
    required this.wordEn,
  });
}
