import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import '../../utils/responsive_helper.dart';
import '../../widgets/kid_button.dart';

/// מסך ציור צורות - תרגול ציור צורות בסיסיות
class ShapeTracingScreen extends StatefulWidget {
  const ShapeTracingScreen({super.key});

  @override
  State<ShapeTracingScreen> createState() => _ShapeTracingScreenState();
}

class _ShapeTracingScreenState extends State<ShapeTracingScreen> {
  final FlutterTts _flutterTts = FlutterTts();

  int _currentLevel = 0;
  bool _isHebrew = true;
  bool _showSuccess = false;
  List<Offset> drawnPoints = [];
  Size _canvasSize = Size.zero;
  int? _activePointerId; // Track the active finger for single-touch drawing

  // רמות המשחק - כל רמה עם קושי שונה
  final List<Map<String, dynamic>> _levels = [
    // Easy levels - with guide lines
    {'shape': 'circle', 'difficulty': 'easy', 'nameHe': 'עיגול', 'nameEn': 'Circle', 'color': Colors.blue},
    {'shape': 'square', 'difficulty': 'easy', 'nameHe': 'ריבוע', 'nameEn': 'Square', 'color': Colors.red},
    {'shape': 'triangle', 'difficulty': 'easy', 'nameHe': 'משולש', 'nameEn': 'Triangle', 'color': Colors.green},

    // Medium levels - with dots
    {'shape': 'circle', 'difficulty': 'medium', 'nameHe': 'עיגול', 'nameEn': 'Circle', 'color': Colors.blue},
    {'shape': 'square', 'difficulty': 'medium', 'nameHe': 'ריבוע', 'nameEn': 'Square', 'color': Colors.red},
    {'shape': 'triangle', 'difficulty': 'medium', 'nameHe': 'משולש', 'nameEn': 'Triangle', 'color': Colors.green},

    // Hard levels - no guides
    {'shape': 'star', 'difficulty': 'hard', 'nameHe': 'כוכב', 'nameEn': 'Star', 'color': Colors.yellow},
    {'shape': 'heart', 'difficulty': 'hard', 'nameHe': 'לב', 'nameEn': 'Heart', 'color': Colors.pink},
    {'shape': 'diamond', 'difficulty': 'hard', 'nameHe': 'יהלום', 'nameEn': 'Diamond', 'color': Colors.purple},
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isHebrew = Localizations.localeOf(context).languageCode == 'he';
      });
      _speakInstruction();
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speakInstruction() async {
    final level = _levels[_currentLevel];
    final shapeName = _isHebrew ? level['nameHe']! : level['nameEn']!;
    final text = _isHebrew ? 'צייר $shapeName' : 'Draw a $shapeName';
    final lang = _isHebrew ? 'he-IL' : 'en-US';

    await _flutterTts.setLanguage(lang);
    await _flutterTts.speak(text as String);
  }

  void _checkIfComplete() {
    if (_canvasSize == Size.zero || drawnPoints.isEmpty) return;

    final level = _levels[_currentLevel];
    final shape = level['shape'] as String;

    // Check if enough drawing was done
    final validPoints = drawnPoints.where((p) => p.dx >= 0).length;

    bool isComplete = false;

    switch (shape) {
      case 'circle':
        isComplete = _checkCircle(validPoints);
        break;
      case 'square':
        isComplete = _checkSquare(validPoints);
        break;
      case 'triangle':
        isComplete = _checkTriangle(validPoints);
        break;
      case 'star':
        isComplete = _checkStar(validPoints);
        break;
      case 'heart':
        isComplete = _checkHeart(validPoints);
        break;
      case 'diamond':
        isComplete = _checkDiamond(validPoints);
        break;
    }

    if (isComplete && !_showSuccess) {
      setState(() {
        _showSuccess = true;
      });
      // Removed auto-advance - user must click Next button like in numbers/letters
    }
  }

  bool _checkCircle(int points) => points > 60;
  bool _checkSquare(int points) => points > 50;
  bool _checkTriangle(int points) => points > 40;
  bool _checkStar(int points) => points > 70;
  bool _checkHeart(int points) => points > 65;
  bool _checkDiamond(int points) => points > 50;

  Future<void> _speak(String text) async {
    final lang = _isHebrew ? 'he-IL' : 'en-US';
    await _flutterTts.setLanguage(lang);
    await _flutterTts.speak(text);
  }

  void _nextLevel() {
    if (_currentLevel < _levels.length - 1) {
      setState(() {
        _currentLevel++;
        drawnPoints.clear();
        _showSuccess = false;
        _activePointerId = null; // Reset active pointer
      });
      _speakInstruction();
    } else {
      // All levels completed - return to previous screen
      Navigator.pop(context);
    }
  }

  void _clearDrawing() {
    setState(() {
      drawnPoints.clear();
      _showSuccess = false;
      _activePointerId = null; // Reset active pointer
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    _isHebrew = Localizations.localeOf(context).languageCode == 'he';
    final level = _levels[_currentLevel];
    final difficulty = level['difficulty'] as String;

    String difficultyText = '';
    if (difficulty == 'easy') {
      difficultyText = _isHebrew ? 'קל' : 'Easy';
    } else if (difficulty == 'medium') {
      difficultyText = _isHebrew ? 'בינוני' : 'Medium';
    } else {
      difficultyText = _isHebrew ? 'קשה' : 'Hard';
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.shade50,
              Colors.yellow.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(responsive.spacing(12)),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isHebrew ? Icons.arrow_forward : Icons.arrow_back,
                        color: Colors.orange.shade700,
                        size: 32,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        _isHebrew ? 'ציור צורות' : 'Shape Tracing',
                        style: TextStyle(
                          fontSize: responsive.titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text(
                      '${_currentLevel + 1}/${_levels.length}',
                      style: TextStyle(
                        fontSize: responsive.fontSize(18),
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),

              // Instructions
              Container(
                margin: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (level['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      '${_isHebrew ? 'צייר' : 'Draw a'} ${_isHebrew ? level['nameHe']! : level['nameEn']!}',
                      style: TextStyle(
                        fontSize: responsive.fontSize(20),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      difficultyText,
                      style: TextStyle(
                        fontSize: responsive.fontSize(14),
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: responsive.spacing(16)),

              // Drawing Area
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

                        return Stack(
                          children: [
                            // Guide shape (based on difficulty)
                            CustomPaint(
                              painter: GuideShapePainter(
                                level['shape'] as String,
                                difficulty,
                                _canvasSize,
                                level['color'] as Color,
                              ),
                              size: Size.infinite,
                            ),
                            // Drawing layer - Single touch only
                            Listener(
                              onPointerDown: (details) {
                                // Only start drawing if no finger is currently active
                                if (_activePointerId == null) {
                                  setState(() {
                                    _activePointerId = details.pointer;
                                    drawnPoints.add(details.localPosition);
                                  });
                                }
                              },
                              onPointerMove: (details) {
                                // Only draw if this is the active finger
                                if (_activePointerId == details.pointer) {
                                  setState(() {
                                    drawnPoints.add(details.localPosition);
                                  });
                                }
                              },
                              onPointerUp: (details) {
                                // Only end drawing if this is the active finger
                                if (_activePointerId == details.pointer) {
                                  setState(() {
                                    drawnPoints.add(const Offset(-1, -1)); // Separator
                                    _activePointerId = null;
                                  });
                                  _checkIfComplete();
                                }
                              },
                              child: CustomPaint(
                                painter: DrawingPainter(
                                  drawnPoints,
                                  level['color'] as Color,
                                ),
                                size: Size.infinite,
                              ),
                            ),
                            // Success overlay
                            if (_showSuccess)
                              Container(
                                color: Colors.green.withOpacity(0.3),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 100,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _isHebrew ? 'יפה!' : 'Great!',
                                        style: TextStyle(
                                          fontSize: responsive.fontSize(32),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: responsive.spacing(16)),

              // Buttons - Always show Clear and Next (like numbers/letters)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: KidButton(
                          text: _isHebrew ? 'נקה 🗑️' : 'Clear 🗑️',
                          icon: Icons.delete,
                          onPressed: _clearDrawing,
                          color: Colors.orange,
                          height: 60,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: KidButton(
                          text: _isHebrew ? 'הבא ➡️' : 'Next ➡️',
                          icon: Icons.arrow_forward,
                          onPressed: _nextLevel,
                          color: Colors.green,
                          height: 60,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: responsive.spacing(16)),
            ],
          ),
        ),
      ),
    );
  }
}

/// ציור צורת המדריך (תלוי ברמת הקושי)
class GuideShapePainter extends CustomPainter {
  final String shape;
  final String difficulty;
  final Size canvasSize;
  final Color color;

  GuideShapePainter(this.shape, this.difficulty, this.canvasSize, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final shapeSize = min(size.width, size.height) * 0.6;

    Paint paint;
    if (difficulty == 'easy') {
      // Dashed guide lines
      paint = Paint()
        ..color = color.withOpacity(0.4)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;
    } else if (difficulty == 'medium') {
      // Dotted guide
      paint = Paint()
        ..color = color.withOpacity(0.5)
        ..strokeWidth = 8.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
    } else {
      // No guide, just return
      return;
    }

    switch (shape) {
      case 'circle':
        _drawCircleGuide(canvas, center, shapeSize / 2, paint, difficulty);
        break;
      case 'square':
        _drawSquareGuide(canvas, center, shapeSize, paint, difficulty);
        break;
      case 'triangle':
        _drawTriangleGuide(canvas, center, shapeSize, paint, difficulty);
        break;
      case 'star':
        _drawStarGuide(canvas, center, shapeSize / 2, paint, difficulty);
        break;
      case 'heart':
        _drawHeartGuide(canvas, center, shapeSize, paint, difficulty);
        break;
      case 'diamond':
        _drawDiamondGuide(canvas, center, shapeSize, paint, difficulty);
        break;
    }
  }

  void _drawCircleGuide(Canvas canvas, Offset center, double radius, Paint paint, String difficulty) {
    if (difficulty == 'easy') {
      _drawDashedCircle(canvas, center, radius, paint);
    } else {
      _drawDottedCircle(canvas, center, radius, paint);
    }
  }

  void _drawSquareGuide(Canvas canvas, Offset center, double size, Paint paint, String difficulty) {
    final rect = Rect.fromCenter(center: center, width: size, height: size);
    if (difficulty == 'easy') {
      _drawDashedRect(canvas, rect, paint);
    } else {
      _drawDottedRect(canvas, rect, paint);
    }
  }

  void _drawTriangleGuide(Canvas canvas, Offset center, double size, Paint paint, String difficulty) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size / 2);
    path.lineTo(center.dx - size / 2, center.dy + size / 2);
    path.lineTo(center.dx + size / 2, center.dy + size / 2);
    path.close();

    if (difficulty == 'easy') {
      _drawDashedPath(canvas, path, paint);
    } else {
      _drawDottedPath(canvas, path, paint, 20);
    }
  }

  void _drawStarGuide(Canvas canvas, Offset center, double radius, Paint paint, String difficulty) {
    final path = _createStarPath(center, radius);
    if (difficulty == 'easy') {
      _drawDashedPath(canvas, path, paint);
    } else {
      _drawDottedPath(canvas, path, paint, 30);
    }
  }

  void _drawHeartGuide(Canvas canvas, Offset center, double size, Paint paint, String difficulty) {
    final path = _createHeartPath(center, size);
    if (difficulty == 'easy') {
      _drawDashedPath(canvas, path, paint);
    } else {
      _drawDottedPath(canvas, path, paint, 25);
    }
  }

  void _drawDiamondGuide(Canvas canvas, Offset center, double size, Paint paint, String difficulty) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size / 2);
    path.lineTo(center.dx + size / 2, center.dy);
    path.lineTo(center.dx, center.dy + size / 2);
    path.lineTo(center.dx - size / 2, center.dy);
    path.close();

    if (difficulty == 'easy') {
      _drawDashedPath(canvas, path, paint);
    } else {
      _drawDottedPath(canvas, path, paint, 20);
    }
  }

  Path _createStarPath(Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * pi / 5) - pi / 2;
      final r = i % 2 == 0 ? radius : radius * 0.4;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  Path _createHeartPath(Offset center, double size) {
    final path = Path();
    final scale = size / 200;
    path.moveTo(center.dx, center.dy + 60 * scale);

    path.cubicTo(
      center.dx - 40 * scale, center.dy + 30 * scale,
      center.dx - 60 * scale, center.dy - 10 * scale,
      center.dx - 60 * scale, center.dy - 40 * scale,
    );
    path.cubicTo(
      center.dx - 60 * scale, center.dy - 60 * scale,
      center.dx - 40 * scale, center.dy - 70 * scale,
      center.dx, center.dy - 60 * scale,
    );
    path.cubicTo(
      center.dx + 40 * scale, center.dy - 70 * scale,
      center.dx + 60 * scale, center.dy - 60 * scale,
      center.dx + 60 * scale, center.dy - 40 * scale,
    );
    path.cubicTo(
      center.dx + 60 * scale, center.dy - 10 * scale,
      center.dx + 40 * scale, center.dy + 30 * scale,
      center.dx, center.dy + 60 * scale,
    );

    return path;
  }

  void _drawDashedCircle(Canvas canvas, Offset center, double radius, Paint paint) {
    const dashLength = 10.0;
    const gapLength = 5.0;
    const totalCircumference = 2 * pi;

    double currentAngle = 0;
    while (currentAngle < totalCircumference) {
      final x1 = center.dx + radius * cos(currentAngle);
      final y1 = center.dy + radius * sin(currentAngle);

      final dashAngle = dashLength / radius;
      final endAngle = min(currentAngle + dashAngle, totalCircumference);

      final x2 = center.dx + radius * cos(endAngle);
      final y2 = center.dy + radius * sin(endAngle);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);

      currentAngle = endAngle + (gapLength / radius);
    }
  }

  void _drawDottedCircle(Canvas canvas, Offset center, double radius, Paint paint) {
    const numDots = 24;
    for (int i = 0; i < numDots; i++) {
      final angle = (i * 2 * pi / numDots);
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      canvas.drawCircle(Offset(x, y), 4, paint);
    }
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    _drawDashedLine(canvas, rect.topLeft, rect.topRight, paint);
    _drawDashedLine(canvas, rect.topRight, rect.bottomRight, paint);
    _drawDashedLine(canvas, rect.bottomRight, rect.bottomLeft, paint);
    _drawDashedLine(canvas, rect.bottomLeft, rect.topLeft, paint);
  }

  void _drawDottedRect(Canvas canvas, Rect rect, Paint paint) {
    const dotsPerSide = 8;
    // Top
    for (int i = 0; i <= dotsPerSide; i++) {
      final x = rect.left + (rect.width * i / dotsPerSide);
      canvas.drawCircle(Offset(x, rect.top), 4, paint);
    }
    // Right
    for (int i = 0; i <= dotsPerSide; i++) {
      final y = rect.top + (rect.height * i / dotsPerSide);
      canvas.drawCircle(Offset(rect.right, y), 4, paint);
    }
    // Bottom
    for (int i = 0; i <= dotsPerSide; i++) {
      final x = rect.right - (rect.width * i / dotsPerSide);
      canvas.drawCircle(Offset(x, rect.bottom), 4, paint);
    }
    // Left
    for (int i = 0; i <= dotsPerSide; i++) {
      final y = rect.bottom - (rect.height * i / dotsPerSide);
      canvas.drawCircle(Offset(rect.left, y), 4, paint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLength = 10.0;
    const gapLength = 5.0;

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = sqrt(dx * dx + dy * dy);
    final ux = dx / length;
    final uy = dy / length;

    double currentLength = 0;
    while (currentLength < length) {
      final p1 = Offset(
        start.dx + ux * currentLength,
        start.dy + uy * currentLength,
      );

      final dashEnd = min(currentLength + dashLength, length);
      final p2 = Offset(
        start.dx + ux * dashEnd,
        start.dy + uy * dashEnd,
      );

      canvas.drawLine(p1, p2, paint);
      currentLength = dashEnd + gapLength;
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final pathMetrics = path.computeMetrics();
    const dashLength = 10.0;
    const gapLength = 5.0;

    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final dashEnd = min(distance + dashLength, metric.length);
        final segment = metric.extractPath(distance, dashEnd);
        canvas.drawPath(segment, paint);
        distance = dashEnd + gapLength;
      }
    }
  }

  void _drawDottedPath(Canvas canvas, Path path, Paint paint, int numDots) {
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      for (int i = 0; i < numDots; i++) {
        final distance = metric.length * i / numDots;
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 4, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset> points;
  final Color color;

  DrawingPainter(this.points, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i].dx >= 0 && points[i + 1].dx >= 0) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
