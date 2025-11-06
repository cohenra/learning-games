import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../../providers/app_provider.dart';
import '../../widgets/kid_button.dart';
import '../../widgets/reward_animation.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// משחק זיכרון לאותיות - Memory Game
/// מתאים לגילאי 3-6, מפתח זיכרון עבודה וזיהוי אותיות
class LettersMemoryGameScreen extends StatefulWidget {
  const LettersMemoryGameScreen({super.key});

  @override
  State<LettersMemoryGameScreen> createState() => _LettersMemoryGameScreenState();
}

class _LettersMemoryGameScreenState extends State<LettersMemoryGameScreen>
    with TickerProviderStateMixin {

  // רמות קושי
  static const int EASY = 4;    // 4 זוגות - גילאי 3-4
  static const int MEDIUM = 6;  // 6 זוגות - גילאי 4-5
  static const int HARD = 8;    // 8 זוגות - גילאי 5-6

  int _difficulty = EASY;
  List<MemoryCard> _cards = [];
  List<int> _flippedIndices = [];
  bool _canFlip = true;
  int _moves = 0;
  int _matchedPairs = 0;
  Timer? _gameTimer;
  int _elapsedSeconds = 0;
  bool _gameStarted = false;
  bool _gameCompleted = false;
  bool _showReward = false;
  bool _isInitialized = false;

  // אנימציות
  late AnimationController _flipController;
  late AnimationController _matchController;
  late AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeGame();
      _isInitialized = true;
    }
  }

  void _initializeAnimations() {
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _matchController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  void _initializeGame() {
    _gameStarted = false;
    _gameCompleted = false;
    _showReward = false;
    _moves = 0;
    _matchedPairs = 0;
    _elapsedSeconds = 0;
    _flippedIndices.clear();
    _gameTimer?.cancel();

    final isHebrew = Localizations.localeOf(context).languageCode == 'he';
    final letters = _getLettersForDifficulty(isHebrew);

    // יצירת זוגות כרטיסים
    _cards = [];
    for (int i = 0; i < letters.length; i++) {
      _cards.add(MemoryCard(
        id: i * 2,
        letter: letters[i]['letter']!,
        color: letters[i]['color'] as Color,
        isFlipped: false,
        isMatched: false,
      ));
      _cards.add(MemoryCard(
        id: i * 2 + 1,
        letter: letters[i]['letter']!,
        color: letters[i]['color'] as Color,
        isFlipped: false,
        isMatched: false,
      ));
    }

    // ערבוב הכרטיסים
    _cards.shuffle(Random());

    setState(() {});
  }

  List<Map<String, dynamic>> _getLettersForDifficulty(bool isHebrew) {
    if (isHebrew) {
      final allLetters = [
        {'letter': 'א', 'color': Colors.red},
        {'letter': 'ב', 'color': Colors.blue},
        {'letter': 'ג', 'color': Colors.green},
        {'letter': 'ד', 'color': Colors.orange},
        {'letter': 'ה', 'color': Colors.purple},
        {'letter': 'ו', 'color': Colors.pink},
        {'letter': 'ז', 'color': Colors.teal},
        {'letter': 'ח', 'color': Colors.amber},
      ];
      return allLetters.take(_difficulty).toList();
    } else {
      final allLetters = [
        {'letter': 'A', 'color': Colors.red},
        {'letter': 'B', 'color': Colors.blue},
        {'letter': 'C', 'color': Colors.green},
        {'letter': 'D', 'color': Colors.orange},
        {'letter': 'E', 'color': Colors.purple},
        {'letter': 'F', 'color': Colors.pink},
        {'letter': 'G', 'color': Colors.teal},
        {'letter': 'H', 'color': Colors.amber},
      ];
      return allLetters.take(_difficulty).toList();
    }
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
    });

    // התחלת טיימר
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _onCardTap(int index) {
    // בדיקות: האם אפשר להפוך כרטיס
    if (!_canFlip) return;
    if (_cards[index].isFlipped) return;
    if (_cards[index].isMatched) return;
    if (_flippedIndices.length >= 2) return;

    // התחלת משחק במהלך הראשון
    if (!_gameStarted) {
      _startGame();
    }

    setState(() {
      _cards[index].isFlipped = true;
      _flippedIndices.add(index);
    });

    // הגייה של האות
    final appProvider = context.read<AppProvider>();
    appProvider.speak(_cards[index].letter);

    // בדיקה אם הפכנו 2 כרטיסים
    if (_flippedIndices.length == 2) {
      _moves++;
      _canFlip = false;

      final firstCard = _cards[_flippedIndices[0]];
      final secondCard = _cards[_flippedIndices[1]];

      // בדיקה אם זה זוג תואם
      if (firstCard.letter == secondCard.letter) {
        _handleMatch();
      } else {
        _handleMismatch();
      }
    }
  }

  void _handleMatch() {
    // אנימציית התאמה
    _matchController.forward().then((_) {
      _matchController.reverse();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _cards[_flippedIndices[0]].isMatched = true;
        _cards[_flippedIndices[1]].isMatched = true;
        _matchedPairs++;
        _flippedIndices.clear();
        _canFlip = true;
      });

      // בדיקה אם השחקן ניצח
      if (_matchedPairs == _difficulty) {
        _handleGameComplete();
      }
    });
  }

  void _handleMismatch() {
    Future.delayed(const Duration(milliseconds: 1200), () {
      setState(() {
        _cards[_flippedIndices[0]].isFlipped = false;
        _cards[_flippedIndices[1]].isFlipped = false;
        _flippedIndices.clear();
        _canFlip = true;
      });
    });
  }

  void _handleGameComplete() {
    _gameTimer?.cancel();
    setState(() {
      _gameCompleted = true;
      _showReward = true;
    });

    // חישוב כוכבים (1-3) לפי ביצועים
    final stars = _calculateStars();

    // שמירת כוכבים
    final appProvider = context.read<AppProvider>();
    for (int i = 0; i < stars; i++) {
      appProvider.addStar('letters');
    }

    // אנימציית חגיגה
    _celebrationController.forward();

    // הגייה של ברכה
    final l10n = AppLocalizations.of(context)!;
    Future.delayed(const Duration(milliseconds: 500), () {
      appProvider.speak(l10n.awesome);
    });
  }

  int _calculateStars() {
    // חישוב כוכבים לפי מספר מהלכים וזמן
    final perfectMoves = _difficulty; // מספר מהלכים מושלם
    final goodMoves = _difficulty + 3;

    if (_moves <= perfectMoves) {
      return 3; // מושלם!
    } else if (_moves <= goodMoves) {
      return 2; // טוב מאוד
    } else {
      return 1; // סיים את המשחק
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _flipController.dispose();
    _matchController.dispose();
    _celebrationController.dispose();
    _gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';

    return Scaffold(
      appBar: AppBar(
        title: Text(isHebrew ? 'משחק זיכרון 🎮' : 'Memory Game 🎮'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          // כפתור איפוס
          IconButton(
            icon: const Icon(Icons.refresh, size: 32),
            onPressed: () {
              setState(() {
                _initializeGame();
              });
            },
            tooltip: isHebrew ? 'משחק חדש' : 'New Game',
          ),
        ],
      ),
      body: Container(
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
          child: Column(
            children: [
              // פאנל סטטיסטיקות
              _buildStatsPanel(l10n, isHebrew),

              const SizedBox(height: 8),

              // בחירת קושי (לפני תחילת המשחק)
              if (!_gameStarted) _buildDifficultySelector(l10n, isHebrew),

              if (!_gameStarted) const SizedBox(height: 8),

              // לוח המשחק
              Expanded(
                child: _buildGameBoard(),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      // אנימציית פרס
      floatingActionButton: _showReward
          ? const RewardAnimation()
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildStatsPanel(AppLocalizations l10n, bool isHebrew) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.timer,
            label: isHebrew ? 'זמן' : 'Time',
            value: _formatTime(_elapsedSeconds),
            color: Colors.orange,
          ),
          _buildStatItem(
            icon: Icons.touch_app,
            label: isHebrew ? 'מהלכים' : 'Moves',
            value: _moves.toString(),
            color: Colors.blue,
          ),
          _buildStatItem(
            icon: Icons.emoji_events,
            label: isHebrew ? 'זוגות' : 'Pairs',
            value: '$_matchedPairs / $_difficulty',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultySelector(AppLocalizations l10n, bool isHebrew) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isHebrew ? 'בחר רמת קושי:' : 'Choose Difficulty:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDifficultyButton(
                label: isHebrew ? 'קל' : 'Easy',
                emoji: '😊',
                difficulty: EASY,
                color: Colors.green,
              ),
              _buildDifficultyButton(
                label: isHebrew ? 'בינוני' : 'Medium',
                emoji: '🤔',
                difficulty: MEDIUM,
                color: Colors.orange,
              ),
              _buildDifficultyButton(
                label: isHebrew ? 'קשה' : 'Hard',
                emoji: '🧠',
                difficulty: HARD,
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton({
    required String label,
    required String emoji,
    required int difficulty,
    required Color color,
  }) {
    final isSelected = _difficulty == difficulty;

    return GestureDetector(
      onTap: () {
        setState(() {
          _difficulty = difficulty;
          _initializeGame();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameBoard() {
    // חישוב דינמי של מספר עמודות לפי מספר כרטיסים
    // EASY: 8 כרטיסים = 2x4 גריד
    // MEDIUM: 12 כרטיסים = 3x4 גריד
    // HARD: 16 כרטיסים = 4x4 גריד
    int crossAxisCount;
    if (_cards.length <= 8) {
      crossAxisCount = 4; // 2 שורות של 4
    } else if (_cards.length <= 12) {
      crossAxisCount = 4; // 3 שורות של 4
    } else {
      crossAxisCount = 4; // 4 שורות של 4
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // חישוב גובה זמין לכרטיסים
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;

        // חישוב מספר שורות
        final rowCount = (_cards.length / crossAxisCount).ceil();

        // חישוב גובה מקסימלי לכרטיס (עם מרווחים)
        final totalSpacing = (rowCount - 1) * 10 + 24; // spacing + padding
        final maxCardHeight = (availableHeight - totalSpacing) / rowCount;

        // חישוב רוחב מקסימלי לכרטיס
        final totalHorizontalSpacing = (crossAxisCount - 1) * 10 + 24; // spacing + padding
        final maxCardWidth = (availableWidth - totalHorizontalSpacing) / crossAxisCount;

        // חישוב aspect ratio שמתאים למסך
        // נשתמש ביחס שמבטיח שהכרטיסים נכנסים במסך
        final calculatedAspectRatio = maxCardWidth / maxCardHeight;

        return Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: calculatedAspectRatio.clamp(0.6, 1.0),
            physics: const NeverScrollableScrollPhysics(), // ❌ אין גלילה!
            shrinkWrap: true,
            children: List.generate(
              _cards.length,
              (index) => _buildMemoryCard(index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMemoryCard(int index) {
    final card = _cards[index];
    final isFlipped = card.isFlipped || card.isMatched;
    final isMatched = card.isMatched;

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: isFlipped ? 180 : 0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          final isFrontVisible = value > 90;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(value * pi / 180),
            child: isFrontVisible
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildCardFront(card, isMatched),
                  )
                : _buildCardBack(),
          );
        },
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade600,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade300,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.question_mark,
          size: 48,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildCardFront(MemoryCard card, bool isMatched) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(
          color: isMatched ? Colors.green : card.color,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: (isMatched ? Colors.green : card.color).withOpacity(0.4),
            blurRadius: isMatched ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              card.letter,
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: card.color,
              ),
            ),
          ),
          if (isMatched)
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 32,
              ),
            ),
        ],
      ),
    );
  }
}

/// מודל לכרטיס זיכרון
class MemoryCard {
  final int id;
  final String letter;
  final Color color;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.letter,
    required this.color,
    this.isFlipped = false,
    this.isMatched = false,
  });
}
