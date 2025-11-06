import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../../providers/app_provider.dart';
import '../../widgets/kid_button.dart';
import '../../widgets/reward_animation.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// משחק בניית צורות - Shape Building Puzzle
/// מתאים לגילאי 3-6, מפתח זיהוי צורות וקואורדינציה מרחבית
class ShapesBuildingGameScreen extends StatefulWidget {
  const ShapesBuildingGameScreen({super.key});

  @override
  State<ShapesBuildingGameScreen> createState() => _ShapesBuildingGameScreenState();
}

class _ShapesBuildingGameScreenState extends State<ShapesBuildingGameScreen>
    with TickerProviderStateMixin {

  // רמות קושי
  static const int EASY = 1;     // 4 צורות - בית פשוט
  static const int MEDIUM = 2;   // 6 צורות - רכב
  static const int HARD = 3;     // 8 צורות - עץ + שמש

  int _difficulty = EASY;
  List<PuzzleShape> _availableShapes = [];
  List<ShapeSlot> _slots = [];
  int _placedShapes = 0;
  int _totalAttempts = 0;
  Timer? _gameTimer;
  int _elapsedSeconds = 0;
  bool _gameStarted = false;
  bool _gameCompleted = false;
  bool _showReward = false;
  bool _isInitialized = false;

  // אנימציות
  late AnimationController _snapController;
  late AnimationController _errorController;
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
    _snapController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _errorController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
    _placedShapes = 0;
    _totalAttempts = 0;
    _elapsedSeconds = 0;
    _gameTimer?.cancel();

    // בחירת תבנית לפי קושי
    if (_difficulty == EASY) {
      _buildHousePattern();
    } else if (_difficulty == MEDIUM) {
      _buildCarPattern();
    } else {
      _buildTreePattern();
    }

    setState(() {});
  }

  void _buildHousePattern() {
    // בית פשוט: משולש (גג) + ריבוע (גוף) + ריבוע קטן (חלון) + מלבן (דלת)
    _slots = [
      ShapeSlot(
        id: 'roof',
        shapeType: ShapeType.triangle,
        position: const Offset(0.5, 0.2),
        size: 80,
        color: Colors.red,
        name: 'משולש',
      ),
      ShapeSlot(
        id: 'body',
        shapeType: ShapeType.square,
        position: const Offset(0.5, 0.5),
        size: 100,
        color: Colors.brown,
        name: 'ריבוע',
      ),
      ShapeSlot(
        id: 'window',
        shapeType: ShapeType.square,
        position: const Offset(0.35, 0.45),
        size: 30,
        color: Colors.blue,
        name: 'ריבוע קטן',
      ),
      ShapeSlot(
        id: 'door',
        shapeType: ShapeType.rectangle,
        position: const Offset(0.65, 0.6),
        size: 50,
        color: Colors.orange,
        name: 'מלבן',
      ),
    ];

    _availableShapes = _slots.map((slot) {
      return PuzzleShape(
        id: slot.id,
        shapeType: slot.shapeType,
        color: slot.color,
        size: slot.size,
        name: slot.name,
      );
    }).toList();

    _availableShapes.shuffle(Random());
  }

  void _buildCarPattern() {
    // רכב: מלבן (גוף) + מלבן (חלון) + 2 עיגולים (גלגלים) + משולש (פנס) + ריבוע (דלת)
    _slots = [
      ShapeSlot(
        id: 'body',
        shapeType: ShapeType.rectangle,
        position: const Offset(0.5, 0.5),
        size: 120,
        color: Colors.blue,
        name: 'מלבן גדול',
      ),
      ShapeSlot(
        id: 'window',
        shapeType: ShapeType.rectangle,
        position: const Offset(0.4, 0.4),
        size: 50,
        color: Colors.lightBlue,
        name: 'מלבן קטן',
      ),
      ShapeSlot(
        id: 'wheel1',
        shapeType: ShapeType.circle,
        position: const Offset(0.35, 0.65),
        size: 40,
        color: Colors.black,
        name: 'עיגול',
      ),
      ShapeSlot(
        id: 'wheel2',
        shapeType: ShapeType.circle,
        position: const Offset(0.65, 0.65),
        size: 40,
        color: Colors.black,
        name: 'עיגול',
      ),
      ShapeSlot(
        id: 'light',
        shapeType: ShapeType.triangle,
        position: const Offset(0.7, 0.5),
        size: 25,
        color: Colors.yellow,
        name: 'משולש',
      ),
      ShapeSlot(
        id: 'door',
        shapeType: ShapeType.square,
        position: const Offset(0.5, 0.5),
        size: 35,
        color: Colors.grey,
        name: 'ריבוע',
      ),
    ];

    _availableShapes = _slots.map((slot) {
      return PuzzleShape(
        id: slot.id,
        shapeType: slot.shapeType,
        color: slot.color,
        size: slot.size,
        name: slot.name,
      );
    }).toList();

    _availableShapes.shuffle(Random());
  }

  void _buildTreePattern() {
    // עץ מורכב: משולש (עלווה x3) + מלבן (גזע) + עיגול (שמש) + כוכב + לב + מעויין
    _slots = [
      ShapeSlot(
        id: 'leaves1',
        shapeType: ShapeType.triangle,
        position: const Offset(0.5, 0.25),
        size: 70,
        color: Colors.green,
        name: 'משולש',
      ),
      ShapeSlot(
        id: 'leaves2',
        shapeType: ShapeType.triangle,
        position: const Offset(0.5, 0.35),
        size: 70,
        color: Colors.green.shade700,
        name: 'משולש',
      ),
      ShapeSlot(
        id: 'leaves3',
        shapeType: ShapeType.triangle,
        position: const Offset(0.5, 0.45),
        size: 70,
        color: Colors.green.shade600,
        name: 'משולש',
      ),
      ShapeSlot(
        id: 'trunk',
        shapeType: ShapeType.rectangle,
        position: const Offset(0.5, 0.65),
        size: 50,
        color: Colors.brown,
        name: 'מלבן',
      ),
      ShapeSlot(
        id: 'sun',
        shapeType: ShapeType.circle,
        position: const Offset(0.15, 0.15),
        size: 45,
        color: Colors.yellow,
        name: 'עיגול',
      ),
      ShapeSlot(
        id: 'star',
        shapeType: ShapeType.star,
        position: const Offset(0.85, 0.2),
        size: 35,
        color: Colors.orange,
        name: 'כוכב',
      ),
      ShapeSlot(
        id: 'heart',
        shapeType: ShapeType.heart,
        position: const Offset(0.3, 0.5),
        size: 30,
        color: Colors.pink,
        name: 'לב',
      ),
      ShapeSlot(
        id: 'diamond',
        shapeType: ShapeType.diamond,
        position: const Offset(0.7, 0.5),
        size: 30,
        color: Colors.purple,
        name: 'מעויין',
      ),
    ];

    _availableShapes = _slots.map((slot) {
      return PuzzleShape(
        id: slot.id,
        shapeType: slot.shapeType,
        color: slot.color,
        size: slot.size,
        name: slot.name,
      );
    }).toList();

    _availableShapes.shuffle(Random());
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

  void _onShapeDropped(PuzzleShape shape, ShapeSlot slot) {
    if (!_gameStarted) {
      _startGame();
    }

    setState(() {
      _totalAttempts++;
    });

    final appProvider = context.read<AppProvider>();

    if (shape.id == slot.id) {
      // צורה נכונה במקום נכון!
      _handleCorrectPlacement(shape, slot, appProvider);
    } else {
      // צורה לא נכונה
      _handleIncorrectPlacement(shape, appProvider);
    }
  }

  void _handleCorrectPlacement(PuzzleShape shape, ShapeSlot slot, AppProvider appProvider) {
    setState(() {
      _availableShapes.removeWhere((s) => s.id == shape.id);
      _slots.firstWhere((s) => s.id == slot.id).isPlaced = true;
      _placedShapes++;
    });

    // אנימציית snap
    _snapController.forward().then((_) {
      _snapController.reverse();
    });

    // קול הצלחה
    appProvider.speak(_getShapeName(shape.shapeType));

    // בדיקה אם סיימנו
    if (_availableShapes.isEmpty) {
      _handleGameComplete();
    }
  }

  void _handleIncorrectPlacement(PuzzleShape shape, AppProvider appProvider) {
    // אנימציית טעות
    _errorController.forward().then((_) {
      _errorController.reverse();
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
      appProvider.addStar('shapes');
    }

    _celebrationController.forward();

    final l10n = AppLocalizations.of(context)!;
    Future.delayed(const Duration(milliseconds: 500), () {
      appProvider.speak(l10n.awesome);
    });
  }

  int _calculateStars() {
    if (_totalAttempts == 0) return 0;
    final accuracy = _placedShapes / _totalAttempts;

    if (accuracy >= 0.95) return 3;
    if (accuracy >= 0.85) return 2;
    return 1;
  }

  String _getShapeName(ShapeType shapeType) {
    final l10n = AppLocalizations.of(context)!;
    switch (shapeType) {
      case ShapeType.circle: return l10n.shapeCircle;
      case ShapeType.square: return l10n.shapeSquare;
      case ShapeType.triangle: return l10n.shapeTriangle;
      case ShapeType.rectangle: return l10n.shapeRectangle;
      case ShapeType.star: return l10n.shapeStar;
      case ShapeType.heart: return l10n.shapeHeart;
      case ShapeType.diamond: return l10n.shapeDiamond;
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
    _snapController.dispose();
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
        title: Text(isHebrew ? 'בניית צורות 🏗️' : 'Shape Building 🏗️'),
        centerTitle: true,
        backgroundColor: Colors.purple,
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
              Colors.purple.shade50,
              Colors.pink.shade50,
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

              // אזור התבנית (canvas לבניה)
              Expanded(
                child: _buildBuildingArea(),
              ),

              const SizedBox(height: 8),

              // צורות זמינות בתחתית
              _buildShapesArea(),

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
            color: Colors.purple.shade200,
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
            label: isHebrew ? 'הוצבו' : 'Placed',
            value: '$_placedShapes',
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.extension,
            label: isHebrew ? 'נותרו' : 'Left',
            value: '${_availableShapes.length}',
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
              color: Colors.purple.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDifficultyButton(
                label: isHebrew ? 'קל - בית' : 'Easy - House',
                emoji: '🏠',
                difficulty: EASY,
                color: Colors.green,
              ),
              _buildDifficultyButton(
                label: isHebrew ? 'בינוני - רכב' : 'Medium - Car',
                emoji: '🚗',
                difficulty: MEDIUM,
                color: Colors.orange,
              ),
              _buildDifficultyButton(
                label: isHebrew ? 'קשה - עץ' : 'Hard - Tree',
                emoji: '🌳',
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
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuildingArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.shade200, width: 3),
      ),
      child: _availableShapes.isEmpty && _gameCompleted
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 80)),
                  const SizedBox(height: 16),
                  Text(
                    Localizations.localeOf(context).languageCode == 'he'
                        ? '!כל הכבוד'
                        : 'Well Done!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: _slots.map((slot) {
                    return _buildShapeSlot(slot, constraints);
                  }).toList(),
                );
              },
            ),
    );
  }

  Widget _buildShapeSlot(ShapeSlot slot, BoxConstraints constraints) {
    final left = slot.position.dx * constraints.maxWidth - (slot.size / 2);
    final top = slot.position.dy * constraints.maxHeight - (slot.size / 2);

    return Positioned(
      left: left,
      top: top,
      child: DragTarget<PuzzleShape>(
        onWillAccept: (shape) => shape != null && !slot.isPlaced,
        onAccept: (shape) {
          _onShapeDropped(shape, slot);
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;

          if (slot.isPlaced) {
            // צורה שכבר הוצבה
            return _buildShape(
              slot.shapeType,
              slot.color,
              slot.size,
              isPlaced: true,
            );
          } else {
            // חור ריק
            return Container(
              width: slot.size,
              height: slot.size,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isHovering ? slot.color : slot.color.withOpacity(0.3),
                  width: isHovering ? 3 : 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: slot.shapeType == ShapeType.circle
                    ? BorderRadius.circular(slot.size / 2)
                    : BorderRadius.circular(8),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildShapesArea() {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200, width: 2),
      ),
      child: _availableShapes.isEmpty
          ? const SizedBox.shrink()
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _availableShapes.map((shape) {
                return _buildDraggableShape(shape);
              }).toList(),
            ),
    );
  }

  Widget _buildDraggableShape(PuzzleShape shape) {
    return Draggable<PuzzleShape>(
      data: shape,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.2,
          child: _buildShape(shape.shapeType, shape.color, shape.size),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildShape(shape.shapeType, shape.color, shape.size),
      ),
      child: _buildShape(shape.shapeType, shape.color, shape.size),
    );
  }

  Widget _buildShape(ShapeType shapeType, Color color, double size, {bool isPlaced = false}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: ShapePainter(
          shapeType: shapeType,
          color: color,
          isPlaced: isPlaced,
        ),
      ),
    );
  }
}

/// סוגי צורות
enum ShapeType {
  circle,
  square,
  triangle,
  rectangle,
  star,
  heart,
  diamond,
}

/// מודל לצורה בפאזל
class PuzzleShape {
  final String id;
  final ShapeType shapeType;
  final Color color;
  final double size;
  final String name;

  PuzzleShape({
    required this.id,
    required this.shapeType,
    required this.color,
    required this.size,
    required this.name,
  });
}

/// מודל למקום בתבנית
class ShapeSlot {
  final String id;
  final ShapeType shapeType;
  final Offset position; // 0.0-1.0 (יחסי למסך)
  final double size;
  final Color color;
  final String name;
  bool isPlaced;

  ShapeSlot({
    required this.id,
    required this.shapeType,
    required this.position,
    required this.size,
    required this.color,
    required this.name,
    this.isPlaced = false,
  });
}

/// Painter לציור צורות
class ShapePainter extends CustomPainter {
  final ShapeType shapeType;
  final Color color;
  final bool isPlaced;

  ShapePainter({
    required this.shapeType,
    required this.color,
    this.isPlaced = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (shapeType) {
      case ShapeType.circle:
        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          size.width / 2,
          paint,
        );
        break;
      case ShapeType.square:
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height),
          paint,
        );
        break;
      case ShapeType.triangle:
        final path = Path();
        path.moveTo(size.width / 2, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        path.close();
        canvas.drawPath(path, paint);
        break;
      case ShapeType.rectangle:
        canvas.drawRect(
          Rect.fromLTWH(
            size.width * 0.1,
            size.height * 0.2,
            size.width * 0.8,
            size.height * 0.6,
          ),
          paint,
        );
        break;
      case ShapeType.star:
        _drawStar(canvas, size, paint);
        break;
      case ShapeType.heart:
        _drawHeart(canvas, size, paint);
        break;
      case ShapeType.diamond:
        _drawDiamond(canvas, size, paint);
        break;
    }
  }

  void _drawStar(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius / 2.5;

    for (int i = 0; i < 10; i++) {
      final angle = (i * pi / 5) - pi / 2;
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    path.moveTo(width / 2, height * 0.35);
    path.cubicTo(width / 2, height * 0.25, width * 0.4, height * 0.1, width * 0.25, height * 0.2);
    path.cubicTo(width * 0.1, height * 0.3, width * 0.1, height * 0.55, width / 2, height * 0.85);
    path.cubicTo(width * 0.9, height * 0.55, width * 0.9, height * 0.3, width * 0.75, height * 0.2);
    path.cubicTo(width * 0.6, height * 0.1, width / 2, height * 0.25, width / 2, height * 0.35);
    canvas.drawPath(path, paint);
  }

  void _drawDiamond(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
