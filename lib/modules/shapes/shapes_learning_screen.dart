import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';
import 'package:learning_fun/generated/app_localizations.dart';
import 'dart:math' as math;

/// מסך למידת צורות - מציג צורה אחת בכל פעם
class ShapesLearningScreen extends StatefulWidget {
  const ShapesLearningScreen({super.key});

  @override
  State<ShapesLearningScreen> createState() => _ShapesLearningScreenState();
}

class _ShapesLearningScreenState extends State<ShapesLearningScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;

  // רשימת הצורות
  final List<Map<String, dynamic>> _shapes = [
    {'key': 'shapeCircle', 'type': ShapeType.circle, 'color': Colors.red},
    {'key': 'shapeSquare', 'type': ShapeType.square, 'color': Colors.blue},
    {'key': 'shapeTriangle', 'type': ShapeType.triangle, 'color': Colors.green},
    {'key': 'shapeRectangle', 'type': ShapeType.rectangle, 'color': Colors.orange},
    {'key': 'shapeStar', 'type': ShapeType.star, 'color': Colors.purple},
    {'key': 'shapeHeart', 'type': ShapeType.heart, 'color': Colors.pink},
    {'key': 'shapeDiamond', 'type': ShapeType.diamond, 'color': Colors.teal},
    {'key': 'shapeOval', 'type': ShapeType.oval, 'color': Colors.amber},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animationController.forward();

    // דבר את הצורה בהתחלה
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentShape();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _speakCurrentShape() {
    final appProvider = context.read<AppProvider>();
    final l10n = AppLocalizations.of(context)!;

    // קבל את שם הצורה בשפה הנוכחית
    final shapeName = _getShapeName(l10n);
    appProvider.speak(shapeName);
  }

  String _getShapeName(AppLocalizations l10n) {
    final key = _shapes[_currentIndex]['key'] as String;
    switch (key) {
      case 'shapeCircle': return l10n.shapeCircle;
      case 'shapeSquare': return l10n.shapeSquare;
      case 'shapeTriangle': return l10n.shapeTriangle;
      case 'shapeRectangle': return l10n.shapeRectangle;
      case 'shapeStar': return l10n.shapeStar;
      case 'shapeHeart': return l10n.shapeHeart;
      case 'shapeDiamond': return l10n.shapeDiamond;
      case 'shapeOval': return l10n.shapeOval;
      default: return '';
    }
  }

  void _goToNext() {
    if (_currentIndex < _shapes.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _animationController.reset();
      _animationController.forward();
      _speakCurrentShape();
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _animationController.reset();
      _animationController.forward();
      _speakCurrentShape();
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final l10n = AppLocalizations.of(context)!;
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';
    final currentShape = _shapes[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.learnMode),
        centerTitle: true,
        backgroundColor: Colors.purple,
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
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: responsive.screenHeight - responsive.safePadding.top - responsive.safePadding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(height: responsive.verticalSpacing),

                  // הצורה הגדולה
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.elasticOut,
                    ),
                    child: GestureDetector(
                      onTap: _speakCurrentShape,
                      child: Container(
                        width: responsive.width(60),
                        height: responsive.width(60),
                        child: CustomPaint(
                          painter: ShapePainter(
                            shapeType: currentShape['type'],
                            color: currentShape['color'],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: responsive.verticalSpacing * 2),

                  // שם הצורה
                  FadeTransition(
                    opacity: _animationController,
                    child: Text(
                      _getShapeName(l10n),
                      style: TextStyle(
                        fontSize: responsive.titleSize,
                        fontWeight: FontWeight.bold,
                        color: currentShape['color'].shade700,
                      ),
                    ),
                  ),

                  SizedBox(height: responsive.verticalSpacing * 2),

                  // כפתורי ניווט
                  Padding(
                    padding: responsive.safePadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        KidButton(
                          text: l10n.back,
                          onPressed: _goToPrevious,
                          enabled: _currentIndex > 0,
                          color: Colors.blue.shade400,
                          width: responsive.width(25),
                        ),
                        KidButton(
                          text: isHebrew ? 'הקשב 🔊' : 'Listen 🔊',
                          onPressed: _speakCurrentShape,
                          color: Colors.green.shade400,
                          width: responsive.width(25),
                        ),
                        KidButton(
                          text: l10n.next,
                          onPressed: _goToNext,
                          enabled: _currentIndex < _shapes.length - 1,
                          color: Colors.blue.shade400,
                          width: responsive.width(25),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: responsive.verticalSpacing),

                  // אינדיקטור התקדמות
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _shapes.length,
                      (index) => Container(
                        width: responsive.iconSize(12),
                        height: responsive.iconSize(12),
                        margin: EdgeInsets.symmetric(horizontal: responsive.spacing(4)),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _currentIndex
                              ? Colors.purple.shade600
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: responsive.verticalSpacing),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// סוגי הצורות השונים
enum ShapeType {
  circle,
  square,
  triangle,
  rectangle,
  star,
  heart,
  diamond,
  oval,
}

/// Painter לציור הצורות השונות
class ShapePainter extends CustomPainter {
  final ShapeType shapeType;
  final MaterialColor color;

  ShapePainter({required this.shapeType, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.shade500
      ..style = PaintingStyle.fill;

    switch (shapeType) {
      case ShapeType.circle:
        _drawCircle(canvas, size, paint);
        break;
      case ShapeType.square:
        _drawSquare(canvas, size, paint);
        break;
      case ShapeType.triangle:
        _drawTriangle(canvas, size, paint);
        break;
      case ShapeType.rectangle:
        _drawRectangle(canvas, size, paint);
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
      case ShapeType.oval:
        _drawOval(canvas, size, paint);
        break;
    }
  }

  void _drawCircle(Canvas canvas, Size size, Paint paint) {
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
  }

  void _drawSquare(Canvas canvas, Size size, Paint paint) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);
  }

  void _drawTriangle(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawRectangle(Canvas canvas, Size size, Paint paint) {
    final rect = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.2,
      size.width * 0.8,
      size.height * 0.6,
    );
    canvas.drawRect(rect, paint);
  }

  void _drawStar(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius / 2.5;

    for (int i = 0; i < 10; i++) {
      final angle = (i * math.pi / 5) - math.pi / 2;
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);

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

    path.cubicTo(
      width / 2, height * 0.25,
      width * 0.4, height * 0.1,
      width * 0.25, height * 0.2,
    );

    path.cubicTo(
      width * 0.1, height * 0.3,
      width * 0.1, height * 0.55,
      width / 2, height * 0.85,
    );

    path.cubicTo(
      width * 0.9, height * 0.55,
      width * 0.9, height * 0.3,
      width * 0.75, height * 0.2,
    );

    path.cubicTo(
      width * 0.6, height * 0.1,
      width / 2, height * 0.25,
      width / 2, height * 0.35,
    );

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

  void _drawOval(Canvas canvas, Size size, Paint paint) {
    final rect = Rect.fromLTWH(
      size.width * 0.1,
      0,
      size.width * 0.8,
      size.height,
    );
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
