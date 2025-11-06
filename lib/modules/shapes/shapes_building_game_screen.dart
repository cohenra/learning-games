import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../providers/app_provider.dart';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// משחק בניית צורות - פשוט ובעל הגיון
class ShapesBuildingGameScreen extends StatefulWidget {
  const ShapesBuildingGameScreen({super.key});

  @override
  State<ShapesBuildingGameScreen> createState() => _ShapesBuildingGameScreenState();
}

class _ShapesBuildingGameScreenState extends State<ShapesBuildingGameScreen>
    with SingleTickerProviderStateMixin {
  bool _isInitialized = false;
  bool _isHebrew = true;

  // Game state
  int _difficultyLevel = 1; // 1=Easy, 2=Medium, 3=Hard
  bool _gameStarted = false;
  int _score = 0;
  List<ShapeSlotModel> _slots = [];
  List<DraggableShapeModel> _availableShapes = [];

  // Animation
  late AnimationController _animationController;

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
      _generateLevel();
    });
  }

  void _generateLevel() {
    if (_difficultyLevel == 1) {
      _buildEasyPattern();
    } else if (_difficultyLevel == 2) {
      _buildMediumPattern();
    } else {
      _buildHardPattern();
    }
  }

  void _buildEasyPattern() {
    // בית פשוט: משולש גג + ריבוע גוף + ריבוע חלון + מלבן דלת
    _slots = [
      ShapeSlotModel(
        shapeType: ShapeType.triangle,
        position: const Offset(0.5, 0.25),
        size: 100,
        color: Colors.red.shade500,
        label: _isHebrew ? 'גג משולש' : 'Triangle Roof',
      ),
      ShapeSlotModel(
        shapeType: ShapeType.square,
        position: const Offset(0.5, 0.55),
        size: 120,
        color: Colors.orange.shade300,
        label: _isHebrew ? 'גוף הבית' : 'House Body',
      ),
      ShapeSlotModel(
        shapeType: ShapeType.square,
        position: const Offset(0.35, 0.5),
        size: 35,
        color: Colors.lightBlue.shade300,
        label: _isHebrew ? 'חלון' : 'Window',
      ),
      ShapeSlotModel(
        shapeType: ShapeType.rectangle,
        position: const Offset(0.65, 0.65),
        size: 55,
        color: Colors.brown.shade300,
        label: _isHebrew ? 'דלת' : 'Door',
      ),
    ];

    _availableShapes = _slots.map((slot) {
      return DraggableShapeModel(
        shapeType: slot.shapeType,
        size: slot.size,
        color: slot.color,
      );
    }).toList();

    _availableShapes.shuffle(Random());
    setState(() {});
  }

  void _buildMediumPattern() {
    // רכב: מלבן גוף + 2 עיגולים גלגלים + ריבוע חלון + משולש פנס
    _slots = [
      ShapeSlotModel(
        shapeType: ShapeType.rectangle,
        position: const Offset(0.5, 0.5),
        size: 140,
        color: Colors.blue.shade400,
        label: _isHebrew ? 'גוף הרכב' : 'Car Body',
      ),
      ShapeSlotModel(
        shapeType: ShapeType.circle,
        position: const Offset(0.35, 0.7),
        size: 45,
        color: Colors.black87,
        label: _isHebrew ? 'גלגל שמאלי' : 'Left Wheel',
      ),
      ShapeSlotModel(
        shapeType: ShapeType.circle,
        position: const Offset(0.65, 0.7),
        size: 45,
        color: Colors.black87,
        label: _isHebrew ? 'גלגל ימני' : 'Right Wheel',
      ),
      ShapeSlotModel(
        shapeType: ShapeType.square,
        position: const Offset(0.4, 0.45),
        size: 40,
        color: Colors.lightBlue.shade200,
        label: _isHebrew ? 'חלון' : 'Window',
      ),
      ShapeSlotModel(
        shapeType: ShapeType.triangle,
        position: const Offset(0.7, 0.5),
        size: 30,
        color: Colors.yellow.shade600,
        label: _isHebrew ? 'פנס' : 'Light',
      ),
    ];

    _availableShapes = _slots.map((slot) {
      return DraggableShapeModel(
        shapeType: slot.shapeType,
        size: slot.size,
        color: slot.color,
      );
    }).toList();

    _availableShapes.shuffle(Random());
    setState(() {});
  }

  void _buildHardPattern() {
    // עץ: 3 משולשים (עלווה) + מלבן (גזע) + עיגול (שמש) + כוכב
    _slots = [
      ShapeSlotModel(
        shapeType: ShapeType.triangle,
        position: const Offset(0.4, 0.25),
        size: 70,
        color: Colors.green.shade600,
        label: _isHebrew ? 'עלווה עליונה' : 'Top Leaves',
      ),
      ShapeSlotModel(
        shapeType: ShapeType.triangle,
        position: const Offset(0.4, 0.38),
        size: 80,
        color: Colors.green.shade700,
        label: _isHebrew ? 'עלווה אמצעית' : 'Middle Leaves',
      ),
      ShapeSlotModel(
        shapeType: ShapeType.triangle,
        position: const Offset(0.4, 0.52),
        size: 90,
        color: Colors.green.shade800,
        label: _isHebrew ? 'עלווה תחתונה' : 'Bottom Leaves',
      ),
      ShapeSlotModel(
        shapeType: ShapeType.rectangle,
        position: const Offset(0.4, 0.75),
        size: 60,
        color: Colors.brown.shade600,
        label: _isHebrew ? 'גזע' : 'Trunk',
      ),
      ShapeSlotModel(
        shapeType: ShapeType.circle,
        position: const Offset(0.75, 0.2),
        size: 50,
        color: Colors.yellow.shade600,
        label: _isHebrew ? 'שמש' : 'Sun',
      ),
      ShapeSlotModel(
        shapeType: ShapeType.star,
        position: const Offset(0.75, 0.45),
        size: 40,
        color: Colors.amber.shade400,
        label: _isHebrew ? 'כוכב' : 'Star',
      ),
    ];

    _availableShapes = _slots.map((slot) {
      return DraggableShapeModel(
        shapeType: slot.shapeType,
        size: slot.size,
        color: slot.color,
      );
    }).toList();

    _availableShapes.shuffle(Random());
    setState(() {});
  }

  void _checkDrop(DraggableShapeModel shape, ShapeSlotModel slot) {
    if (slot.isPlaced) return;

    final appProvider = context.read<AppProvider>();

    if (shape.shapeType == slot.shapeType) {
      // נכון!
      setState(() {
        slot.isPlaced = true;
        _availableShapes.remove(shape);
        _score += 10;
      });

      _animationController.forward(from: 0);
      appProvider.speak(_isHebrew ? 'כל הכבוד!' : 'Great job!');

      // בדיקה אם סיימנו
      if (_availableShapes.isEmpty) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _showCompletionDialog();
          }
        });
      }
    } else {
      // לא נכון
      appProvider.speak(_isHebrew ? 'נסה צורה אחרת' : 'Try another shape');
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          _isHebrew ? '🎉 מעולה! 🎉' : '🎉 Excellent! 🎉',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isHebrew ? 'השלמת את התבנית!' : 'You completed the pattern!',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              _isHebrew ? 'ניקוד: $_score' : 'Score: $_score',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final responsive = ResponsiveHelper(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isHebrew ? 'משחק בנייה 🏗️' : 'Building Game 🏗️'),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
          child: _gameStarted ? _buildGameView(responsive) : _buildDifficultySelector(responsive),
        ),
      ),
    );
  }

  Widget _buildDifficultySelector(ResponsiveHelper responsive) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isHebrew ? '🏗️ בחר רמת קושי 🏗️' : '🏗️ Choose Difficulty 🏗️',
            style: TextStyle(
              fontSize: responsive.fontSize(32),
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
          ),
          SizedBox(height: responsive.spacing(40)),

          Padding(
            padding: responsive.safePadding,
            child: KidButton(
              text: _isHebrew ? 'קל - בנה בית 🏠' : 'Easy - Build a House 🏠',
              icon: Icons.home,
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
              text: _isHebrew ? 'בינוני - בנה רכב 🚗' : 'Medium - Build a Car 🚗',
              icon: Icons.directions_car,
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
              text: _isHebrew ? 'קשה - בנה עץ 🌳' : 'Hard - Build a Tree 🌳',
              icon: Icons.park,
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

  Widget _buildGameView(ResponsiveHelper responsive) {
    return Column(
      children: [
        // Score panel
        _buildScorePanel(),
        const SizedBox(height: 12),

        // Building area
        Expanded(
          child: _buildBuildingArea(),
        ),

        // Available shapes
        _buildShapesArea(),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildScorePanel() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text(
            '$_score',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
          ),
          const SizedBox(width: 24),
          Text(
            _isHebrew ? 'נותרו: ${_availableShapes.length}' : 'Remaining: ${_availableShapes.length}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.purple.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.shade300, width: 3),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: _slots.map((slot) {
              return _buildSlot(slot, constraints);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildSlot(ShapeSlotModel slot, BoxConstraints constraints) {
    final left = slot.position.dx * constraints.maxWidth - (slot.size / 2);
    final top = slot.position.dy * constraints.maxHeight - (slot.size / 2);

    return Positioned(
      left: left,
      top: top,
      child: DragTarget<DraggableShapeModel>(
        onWillAccept: (shape) => shape != null && !slot.isPlaced,
        onAccept: (shape) => _checkDrop(shape, slot),
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;

          return Container(
            width: slot.size,
            height: slot.size,
            child: slot.isPlaced
                ? _buildShapeWidget(slot.shapeType, slot.size, slot.color, opacity: 1.0)
                : _buildShapeWidget(
                    slot.shapeType,
                    slot.size,
                    slot.color,
                    opacity: isHovering ? 0.5 : 0.2,
                    showBorder: true,
                  ),
          );
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
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200, width: 2),
      ),
      child: _availableShapes.isEmpty
          ? Center(
              child: Text(
                '✨',
                style: TextStyle(fontSize: 48),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _availableShapes.map((shape) {
                return _buildDraggableShape(shape);
              }).toList(),
            ),
    );
  }

  Widget _buildDraggableShape(DraggableShapeModel shape) {
    return Draggable<DraggableShapeModel>(
      data: shape,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.2,
          child: _buildShapeWidget(shape.shapeType, shape.size, shape.color),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildShapeWidget(shape.shapeType, shape.size, shape.color),
      ),
      child: _buildShapeWidget(shape.shapeType, shape.size, shape.color),
    );
  }

  Widget _buildShapeWidget(ShapeType type, double size, Color color, {double opacity = 1.0, bool showBorder = false}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: ShapePainter(
          shapeType: type,
          color: color.withOpacity(opacity),
          showBorder: showBorder,
        ),
      ),
    );
  }
}

// Models
enum ShapeType { circle, square, triangle, rectangle, star }

class ShapeSlotModel {
  final ShapeType shapeType;
  final Offset position;
  final double size;
  final Color color;
  final String label;
  bool isPlaced;

  ShapeSlotModel({
    required this.shapeType,
    required this.position,
    required this.size,
    required this.color,
    required this.label,
    this.isPlaced = false,
  });
}

class DraggableShapeModel {
  final ShapeType shapeType;
  final double size;
  final Color color;

  DraggableShapeModel({
    required this.shapeType,
    required this.size,
    required this.color,
  });
}

// Custom Painter
class ShapePainter extends CustomPainter {
  final ShapeType shapeType;
  final Color color;
  final bool showBorder;

  ShapePainter({
    required this.shapeType,
    required this.color,
    this.showBorder = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    switch (shapeType) {
      case ShapeType.circle:
        final center = Offset(size.width / 2, size.height / 2);
        final radius = size.width / 2;
        canvas.drawCircle(center, radius, paint);
        if (showBorder) {
          canvas.drawCircle(center, radius, borderPaint);
        }
        break;

      case ShapeType.square:
        final rect = Rect.fromLTWH(0, 0, size.width, size.height);
        canvas.drawRect(rect, paint);
        if (showBorder) {
          canvas.drawRect(rect, borderPaint);
        }
        break;

      case ShapeType.triangle:
        final path = Path();
        path.moveTo(size.width / 2, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        path.close();
        canvas.drawPath(path, paint);
        if (showBorder) {
          canvas.drawPath(path, borderPaint);
        }
        break;

      case ShapeType.rectangle:
        final rect = Rect.fromLTWH(
          size.width * 0.1,
          size.height * 0.25,
          size.width * 0.8,
          size.height * 0.5,
        );
        canvas.drawRect(rect, paint);
        if (showBorder) {
          canvas.drawRect(rect, borderPaint);
        }
        break;

      case ShapeType.star:
        _drawStar(canvas, size, paint);
        if (showBorder) {
          _drawStar(canvas, size, borderPaint);
        }
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
