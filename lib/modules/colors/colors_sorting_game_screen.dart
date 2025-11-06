import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../../providers/app_provider.dart';
import '../../widgets/kid_button.dart';
import '../../widgets/reward_animation.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// משחק מיון צבעים - Drag & Drop
/// מתאים לגילאי 2-6, מפתח זיהוי צבעים וקואורדינציה
class ColorsSortingGameScreen extends StatefulWidget {
  const ColorsSortingGameScreen({super.key});

  @override
  State<ColorsSortingGameScreen> createState() => _ColorsSortingGameScreenState();
}

class _ColorsSortingGameScreenState extends State<ColorsSortingGameScreen>
    with TickerProviderStateMixin {

  // רמות קושי
  static const int EASY = 3;     // 3 צבעים - גילאי 2-3
  static const int MEDIUM = 5;   // 5 צבעים - גילאי 3-4
  static const int HARD = 6;     // 6 צבעים - גילאי 4-6

  int _difficulty = EASY;
  List<ColorItem> _items = [];
  List<ColorBasket> _baskets = [];
  int _correctSorts = 0;
  int _totalAttempts = 0;
  int _totalItems = 0;
  Timer? _gameTimer;
  int _elapsedSeconds = 0;
  bool _gameStarted = false;
  bool _gameCompleted = false;
  bool _showReward = false;
  bool _isInitialized = false;

  // אנימציות
  late AnimationController _successController;
  late AnimationController _errorController;
  late AnimationController _celebrationController;

  // צבעים זמינים
  final List<Map<String, dynamic>> _availableColors = [
    {'key': 'colorRed', 'color': Colors.red, 'name': 'אדום'},
    {'key': 'colorBlue', 'color': Colors.blue, 'name': 'כחול'},
    {'key': 'colorYellow', 'color': Colors.yellow.shade700, 'name': 'צהוב'},
    {'key': 'colorGreen', 'color': Colors.green, 'name': 'ירוק'},
    {'key': 'colorOrange', 'color': Colors.orange, 'name': 'כתום'},
    {'key': 'colorPurple', 'color': Colors.purple, 'name': 'סגול'},
  ];

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
    _successController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _errorController = AnimationController(
      duration: const Duration(milliseconds: 400),
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
    _correctSorts = 0;
    _totalAttempts = 0;
    _elapsedSeconds = 0;
    _gameTimer?.cancel();

    // בחירת צבעים לפי רמת קושי
    final selectedColors = _availableColors.take(_difficulty).toList();

    // יצירת סלים
    _baskets = selectedColors
        .map((color) => ColorBasket(
              colorKey: color['key'] as String,
              color: color['color'] as Color,
              name: color['name'] as String,
            ))
        .toList();

    // יצירת פריטים לגרירה
    _items = [];
    final itemsPerColor = _difficulty == EASY ? 3 : _difficulty == MEDIUM ? 3 : 4;

    for (var colorData in selectedColors) {
      for (int i = 0; i < itemsPerColor; i++) {
        _items.add(ColorItem(
          id: '${colorData['key']}_$i',
          colorKey: colorData['key'] as String,
          color: colorData['color'] as Color,
          name: colorData['name'] as String,
        ));
      }
    }

    // ערבוב הפריטים
    _items.shuffle(Random());
    _totalItems = _items.length;

    setState(() {});
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _onItemDropped(ColorItem item, ColorBasket basket) {
    if (!_gameStarted) {
      _startGame();
    }

    setState(() {
      _totalAttempts++;
    });

    final appProvider = context.read<AppProvider>();

    if (item.colorKey == basket.colorKey) {
      // תשובה נכונה!
      _handleCorrectDrop(item, basket, appProvider);
    } else {
      // תשובה שגויה
      _handleIncorrectDrop(item, appProvider);
    }
  }

  void _handleCorrectDrop(ColorItem item, ColorBasket basket, AppProvider appProvider) {
    // הסרת הפריט מהרשימה
    setState(() {
      _items.removeWhere((i) => i.id == item.id);
      _correctSorts++;
    });

    // אנימציית הצלחה
    _successController.forward().then((_) {
      _successController.reverse();
    });

    // קול ניצחון
    appProvider.speak(_getColorName(item.colorKey));

    // בדיקה אם סיימנו
    if (_items.isEmpty) {
      _handleGameComplete();
    }
  }

  void _handleIncorrectDrop(ColorItem item, AppProvider appProvider) {
    // אנימציית טעות
    _errorController.forward().then((_) {
      _errorController.reverse();
    });

    // רעד של הפריט
    setState(() {
      item.shake = true;
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        item.shake = false;
      });
    });
  }

  void _handleGameComplete() {
    _gameTimer?.cancel();
    setState(() {
      _gameCompleted = true;
      _showReward = true;
    });

    final stars = _calculateStars();
    final appProvider = context.read<AppProvider>();

    for (int i = 0; i < stars; i++) {
      appProvider.addStar('colors');
    }

    _celebrationController.forward();

    final l10n = AppLocalizations.of(context)!;
    Future.delayed(const Duration(milliseconds: 500), () {
      appProvider.speak(l10n.awesome);
    });
  }

  int _calculateStars() {
    if (_totalAttempts == 0) return 0;
    final accuracy = _correctSorts / _totalAttempts;

    if (accuracy >= 0.95) return 3;
    if (accuracy >= 0.85) return 2;
    return 1;
  }

  String _getColorName(String colorKey) {
    final l10n = AppLocalizations.of(context)!;
    switch (colorKey) {
      case 'colorRed': return l10n.colorRed;
      case 'colorBlue': return l10n.colorBlue;
      case 'colorYellow': return l10n.colorYellow;
      case 'colorGreen': return l10n.colorGreen;
      case 'colorOrange': return l10n.colorOrange;
      case 'colorPurple': return l10n.colorPurple;
      default: return '';
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _successController.dispose();
    _errorController.dispose();
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
        title: Text(isHebrew ? 'מיון צבעים 🎨' : 'Color Sorting 🎨'),
        centerTitle: true,
        backgroundColor: Colors.pink,
        actions: [
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
              Colors.pink.shade50,
              Colors.purple.shade50,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // פאנל סטטיסטיקות
              _buildStatsPanel(l10n, isHebrew),

              const SizedBox(height: 8),

              // בחירת קושי
              if (!_gameStarted) _buildDifficultySelector(l10n, isHebrew),
              if (!_gameStarted) const SizedBox(height: 8),

              // אזור פריטים לגרירה
              Expanded(
                child: _buildItemsArea(),
              ),

              const SizedBox(height: 8),

              // סלים בתחתית
              _buildBasketsArea(),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      floatingActionButton: _showReward ? const RewardAnimation() : null,
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
            color: Colors.pink.shade200,
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
            icon: Icons.check_circle,
            label: isHebrew ? 'נכונים' : 'Correct',
            value: '$_correctSorts',
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.flag,
            label: isHebrew ? 'נותרו' : 'Left',
            value: '${_items.length}',
            color: Colors.blue,
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
              color: Colors.pink.shade700,
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

  Widget _buildItemsArea() {
    if (_items.isEmpty && _gameCompleted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            Text(
              Localizations.localeOf(context).languageCode == 'he'
                  ? 'כל הכבוד! סיימת!'
                  : 'Well Done! Completed!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.pink.shade700,
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // חישוב גודל פריט לפי מקום זמין
        final itemsPerRow = _difficulty == EASY ? 3 : _difficulty == MEDIUM ? 4 : 5;
        final spacing = 8.0;
        final padding = 12.0;

        final availableWidth = constraints.maxWidth - (padding * 2);
        final totalSpacing = (itemsPerRow - 1) * spacing;
        final itemSize = (availableWidth - totalSpacing) / itemsPerRow;

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            alignment: WrapAlignment.center,
            children: _items.map((item) {
              return _buildDraggableItem(item, itemSize);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildDraggableItem(ColorItem item, double size) {
    return Draggable<ColorItem>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.2,
          child: _buildItemWidget(item, size, isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildItemWidget(item, size),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        transform: item.shake
            ? (Matrix4.identity()
              ..translate(
                sin(_errorController.value * pi * 4) * 10,
                0.0,
              ))
            : Matrix4.identity(),
        child: _buildItemWidget(item, size),
      ),
    );
  }

  Widget _buildItemWidget(ColorItem item, double size, {bool isDragging = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: item.color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(isDragging ? 0.6 : 0.4),
            blurRadius: isDragging ? 12 : 8,
            offset: Offset(0, isDragging ? 6 : 4),
          ),
        ],
      ),
    );
  }

  Widget _buildBasketsArea() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final basketWidth = (constraints.maxWidth - (_baskets.length - 1) * 8) / _baskets.length;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _baskets.map((basket) {
              return _buildBasket(basket, basketWidth);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildBasket(ColorBasket basket, double width) {
    return DragTarget<ColorItem>(
      onWillAccept: (item) => item != null,
      onAccept: (item) {
        _onItemDropped(item, basket);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width.clamp(60.0, 100.0),
          height: 100,
          decoration: BoxDecoration(
            color: isHovering ? basket.color.withOpacity(0.7) : basket.color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: basket.color,
              width: isHovering ? 4 : 3,
            ),
            boxShadow: [
              BoxShadow(
                color: basket.color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.shopping_basket,
                  size: 40,
                  color: basket.color.withOpacity(0.7),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// מודל לפריט צבעוני
class ColorItem {
  final String id;
  final String colorKey;
  final Color color;
  final String name;
  bool shake;

  ColorItem({
    required this.id,
    required this.colorKey,
    required this.color,
    required this.name,
    this.shake = false,
  });
}

/// מודל לסל צבעים
class ColorBasket {
  final String colorKey;
  final Color color;
  final String name;

  ColorBasket({
    required this.colorKey,
    required this.color,
    required this.name,
  });
}
