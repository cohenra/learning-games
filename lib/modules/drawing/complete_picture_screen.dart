import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import '../../utils/responsive_helper.dart';
import '../../widgets/kid_button.dart';

/// מסך השלמת תמונות - ציור חלקים חסרים
class CompletePictureScreen extends StatefulWidget {
  const CompletePictureScreen({super.key});

  @override
  State<CompletePictureScreen> createState() => _CompletePictureScreenState();
}

class _CompletePictureScreenState extends State<CompletePictureScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();

  int _currentLevel = 0;
  bool _isHebrew = true;
  bool _showSuccess = false;
  bool _showHint = false;
  List<Offset> drawnPoints = [];
  Size _canvasSize = Size.zero;
  int? _activePointerId; // Track the active finger for single-touch drawing

  // רשימת אתגרים - כל אתגר מכיל תיאור של מה צריך להשלים
  final List<Map<String, dynamic>> _challenges = [
    {
      'nameHe': 'שמש',
      'nameEn': 'Sun',
      'descriptionHe': 'צייר קרניים לשמש!',
      'descriptionEn': 'Draw rays for the sun!',
      'color': Colors.orange,
      'type': 'sun',
    },
    {
      'nameHe': 'פרח',
      'nameEn': 'Flower',
      'descriptionHe': 'צייר עלי כותרת לפרח!',
      'descriptionEn': 'Draw petals for the flower!',
      'color': Colors.pink,
      'type': 'flower',
    },
    {
      'nameHe': 'בית',
      'nameEn': 'House',
      'descriptionHe': 'צייר גג לבית!',
      'descriptionEn': 'Draw a roof for the house!',
      'color': Colors.red,
      'type': 'house',
    },
    {
      'nameHe': 'עץ',
      'nameEn': 'Tree',
      'descriptionHe': 'צייר עלים לעץ!',
      'descriptionEn': 'Draw leaves for the tree!',
      'color': Colors.green,
      'type': 'tree',
    },
    {
      'nameHe': 'דג',
      'nameEn': 'Fish',
      'descriptionHe': 'צייר סנפירים לדג!',
      'descriptionEn': 'Draw fins for the fish!',
      'color': Colors.blue,
      'type': 'fish',
    },
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
    final challenge = _challenges[_currentLevel];
    final text = _isHebrew ? challenge['descriptionHe']! : challenge['descriptionEn']!;
    final lang = _isHebrew ? 'he-IL' : 'en-US';

    await _flutterTts.setLanguage(lang);
    await _flutterTts.speak(text as String);
  }

  void _checkIfComplete() {
    if (_canvasSize == Size.zero || drawnPoints.isEmpty) return;

    final challenge = _challenges[_currentLevel];
    final type = challenge['type'] as String;

    bool isComplete = false;

    switch (type) {
      case 'sun':
        // בדיקה שציירו סביב המעגל (קרניים)
        isComplete = _checkSunRays();
        break;
      case 'flower':
        // בדיקה שציירו סביב המרכז (עלי כותרת)
        isComplete = _checkFlowerPetals();
        break;
      case 'house':
        // בדיקה שציירו למעלה (גג)
        isComplete = _checkHouseRoof();
        break;
      case 'tree':
        // בדיקה שציירו למעלה (עלים)
        isComplete = _checkTreeLeaves();
        break;
      case 'fish':
        // בדיקה שציירו בצדדים (סנפירים)
        isComplete = _checkFishFins();
        break;
    }

    if (isComplete && !_showSuccess) {
      setState(() {
        _showSuccess = true;
      });

      // Auto-advance to next level after 1.5 seconds
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted && _showSuccess) {
          _nextLevel();
        }
      });
    }
  }

  bool _checkSunRays() {
    // בדיקה שציירו לפחות ב-3 כיוונים שונים סביב המעגל
    final center = Offset(_canvasSize.width / 2, _canvasSize.height / 2);
    final radius = min(_canvasSize.width, _canvasSize.height) / 4;

    int sectorsDrawn = 0;
    List<bool> sectors = List.filled(8, false); // 8 sectors around circle

    for (var point in drawnPoints) {
      if (point.dx < 0) continue; // Skip separator

      final distance = (point - center).distance;
      if (distance > radius + 20) { // Outside the sun circle
        // Calculate angle
        final angle = atan2(point.dy - center.dy, point.dx - center.dx);
        final sectorIndex = ((angle + pi) / (2 * pi / 8)).floor() % 8;
        sectors[sectorIndex] = true;
      }
    }

    sectorsDrawn = sectors.where((s) => s).length;
    return sectorsDrawn >= 4; // Need at least 4 rays in different directions
  }

  bool _checkFlowerPetals() {
    // בדיקה שציירו סביב המרכז
    final center = Offset(_canvasSize.width / 2, _canvasSize.height / 2 + 40);
    final innerRadius = 30.0;
    final outerRadius = 80.0;

    int petalPoints = 0;
    for (var point in drawnPoints) {
      if (point.dx < 0) continue;

      final distance = (point - center).distance;
      if (distance > innerRadius && distance < outerRadius) {
        petalPoints++;
      }
    }

    return petalPoints > 40; // Need substantial drawing around center
  }

  bool _checkHouseRoof() {
    // בדיקה שציירו למעלה (גג משולש)
    final roofTop = _canvasSize.height * 0.25;
    final roofBottom = _canvasSize.height * 0.45;

    int roofPoints = 0;
    for (var point in drawnPoints) {
      if (point.dx < 0) continue;

      if (point.dy < roofBottom && point.dy > roofTop) {
        roofPoints++;
      }
    }

    return roofPoints > 30; // Need substantial drawing in roof area
  }

  bool _checkTreeLeaves() {
    // בדיקה שציירו למעלה (עלים)
    final leavesTop = _canvasSize.height * 0.2;
    final leavesBottom = _canvasSize.height * 0.5;

    int leafPoints = 0;
    for (var point in drawnPoints) {
      if (point.dx < 0) continue;

      if (point.dy < leavesBottom && point.dy > leavesTop) {
        leafPoints++;
      }
    }

    return leafPoints > 50; // Need substantial drawing in leaves area
  }

  bool _checkFishFins() {
    // בדיקה שציירו סנפירים למעלה ולמטה
    final center = Offset(_canvasSize.width / 2, _canvasSize.height / 2);
    final bodyHeight = 80.0;
    final bodyWidth = 150.0;

    int topFinPoints = 0;
    int bottomFinPoints = 0;

    for (var point in drawnPoints) {
      if (point.dx < 0) continue;

      // Check if point is near the fish body horizontally
      if ((point.dx - center.dx).abs() < bodyWidth / 2) {
        // Top fin - above the body
        if (point.dy < center.dy - bodyHeight / 4) {
          topFinPoints++;
        }
        // Bottom fin - below the body
        if (point.dy > center.dy + bodyHeight / 4) {
          bottomFinPoints++;
        }
      }
    }

    // Need drawing on both top and bottom for fins
    return (topFinPoints > 15 && bottomFinPoints > 15) || (topFinPoints + bottomFinPoints > 40);
  }

  Future<void> _speak(String text) async {
    final lang = _isHebrew ? 'he-IL' : 'en-US';
    await _flutterTts.setLanguage(lang);
    await _flutterTts.speak(text);
  }

  void _nextLevel() {
    if (_currentLevel < _challenges.length - 1) {
      setState(() {
        _currentLevel++;
        drawnPoints.clear();
        _showSuccess = false;
        _activePointerId = null; // Reset active pointer
      });
      _speakInstruction();
    } else {
      // כל הרמות הושלמו
      _speak(_isHebrew ? 'סיימת את כל הרמות! מדהים!' : 'You completed all levels! Amazing!');
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    }
  }

  void _clearDrawing() {
    setState(() {
      drawnPoints.clear();
      _showSuccess = false;
      _activePointerId = null; // Reset active pointer
    });
  }

  void _showHintTemporarily() {
    setState(() {
      _showHint = true;
    });

    // Hide hint after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showHint = false;
        });
      }
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
    final challenge = _challenges[_currentLevel];

    return Scaffold(
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
                        color: Colors.purple.shade700,
                        size: 32,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        _isHebrew ? 'השלמת תמונות' : 'Complete Pictures',
                        style: TextStyle(
                          fontSize: responsive.titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text(
                      '${_currentLevel + 1}/${_challenges.length}',
                      style: TextStyle(
                        fontSize: responsive.fontSize(18),
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
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
                  color: (challenge['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        _isHebrew ? challenge['descriptionHe']! : challenge['descriptionEn']!,
                        style: TextStyle(
                          fontSize: responsive.fontSize(18),
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                        textAlign: TextAlign.center,
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
                        color: Colors.purple.withOpacity(0.3),
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
                            // Base incomplete shape
                            CustomPaint(
                              painter: IncompletePicturePainter(
                                challenge['type'] as String,
                                _canvasSize,
                              ),
                              size: Size.infinite,
                            ),
                            // Hint layer (dashed outline)
                            if (_showHint)
                              CustomPaint(
                                painter: HintPainter(
                                  challenge['type'] as String,
                                  _canvasSize,
                                  challenge['color'] as Color,
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
                                painter: SimpleDrawingPainter(
                                  drawnPoints,
                                  challenge['color'] as Color,
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
                                        _isHebrew ? 'מעולה!' : 'Excellent!',
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

              // Buttons
              if (!_showSuccess)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: KidButton(
                            text: _isHebrew ? 'רמז 💡' : 'Hint 💡',
                            icon: Icons.lightbulb,
                            onPressed: _showHintTemporarily,
                            color: Colors.purple,
                            height: 60,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: KidButton(
                            text: _isHebrew ? 'נקה 🗑️' : 'Clear 🗑️',
                            icon: Icons.delete,
                            onPressed: _clearDrawing,
                            color: Colors.orange,
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

/// ציור התמונה החלקית (לא שלמה)
class IncompletePicturePainter extends CustomPainter {
  final String type;
  final Size canvasSize;

  IncompletePicturePainter(this.type, this.canvasSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.grey.shade700;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.grey.shade300;

    final center = Offset(size.width / 2, size.height / 2);

    switch (type) {
      case 'sun':
        _drawSunWithoutRays(canvas, center, paint, fillPaint);
        break;
      case 'flower':
        _drawFlowerWithoutPetals(canvas, center, paint, fillPaint);
        break;
      case 'house':
        _drawHouseWithoutRoof(canvas, center, paint, fillPaint);
        break;
      case 'tree':
        _drawTreeWithoutLeaves(canvas, center, paint, fillPaint);
        break;
      case 'fish':
        _drawFishWithoutFins(canvas, center, paint, fillPaint);
        break;
    }
  }

  void _drawSunWithoutRays(Canvas canvas, Offset center, Paint stroke, Paint fill) {
    final radius = min(canvasSize.width, canvasSize.height) / 4;
    canvas.drawCircle(center, radius, fill);
    canvas.drawCircle(center, radius, stroke);

    // Draw face
    final eyeOffset = radius / 3;
    canvas.drawCircle(
      Offset(center.dx - eyeOffset / 2, center.dy - eyeOffset / 2),
      5,
      Paint()..color = Colors.black,
    );
    canvas.drawCircle(
      Offset(center.dx + eyeOffset / 2, center.dy - eyeOffset / 2),
      5,
      Paint()..color = Colors.black,
    );

    // Smile
    final smilePath = Path();
    smilePath.addArc(
      Rect.fromCenter(center: center, width: radius, height: radius),
      0.3,
      2.5,
    );
    canvas.drawPath(smilePath, stroke..strokeWidth = 3);
  }

  void _drawFlowerWithoutPetals(Canvas canvas, Offset center, Paint stroke, Paint fill) {
    // Stem
    final stemPath = Path();
    stemPath.moveTo(center.dx, center.dy + 40);
    stemPath.lineTo(center.dx, center.dy + 150);
    canvas.drawPath(stemPath, stroke..strokeWidth = 6..color = Colors.green.shade700);

    // Center circle only (no petals)
    final flowerCenter = Offset(center.dx, center.dy + 40);
    canvas.drawCircle(flowerCenter, 30, fill..color = Colors.yellow.shade700);
    canvas.drawCircle(flowerCenter, 30, stroke..color = Colors.grey.shade700);
  }

  void _drawHouseWithoutRoof(Canvas canvas, Offset center, Paint stroke, Paint fill) {
    // House body (square/rectangle)
    final houseRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + 20),
      width: min(canvasSize.width, canvasSize.height) * 0.5,
      height: min(canvasSize.width, canvasSize.height) * 0.4,
    );
    canvas.drawRect(houseRect, fill..color = Colors.brown.shade200);
    canvas.drawRect(houseRect, stroke);

    // Door
    final doorRect = Rect.fromCenter(
      center: Offset(center.dx, houseRect.bottom - 40),
      width: 40,
      height: 70,
    );
    canvas.drawRect(doorRect, Paint()..color = Colors.brown.shade700);

    // Window
    final windowRect = Rect.fromCenter(
      center: Offset(center.dx - 50, center.dy + 10),
      width: 35,
      height: 35,
    );
    canvas.drawRect(windowRect, Paint()..color = Colors.lightBlue.shade200);
    canvas.drawRect(windowRect, stroke);
  }

  void _drawTreeWithoutLeaves(Canvas canvas, Offset center, Paint stroke, Paint fill) {
    // Trunk
    final trunkRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + 50),
      width: 40,
      height: 120,
    );
    canvas.drawRect(trunkRect, fill..color = Colors.brown.shade600);
    canvas.drawRect(trunkRect, stroke);

    // Draw hint for where leaves should be
    stroke.style = PaintingStyle.stroke;
    stroke.strokeWidth = 2;
    stroke.color = Colors.grey.shade400;
    final hintPath = Path();
    hintPath.addOval(Rect.fromCenter(
      center: Offset(center.dx, center.dy - 20),
      width: 130,
      height: 100,
    ));
    canvas.drawPath(hintPath, stroke..style = PaintingStyle.stroke);
  }

  void _drawFishWithoutFins(Canvas canvas, Offset center, Paint stroke, Paint fill) {
    // Fish body (oval)
    final bodyRect = Rect.fromCenter(
      center: center,
      width: 150,
      height: 80,
    );
    canvas.drawOval(bodyRect, fill..color = Colors.blue.shade200);
    canvas.drawOval(bodyRect, stroke);

    // Eye
    canvas.drawCircle(
      Offset(center.dx + 40, center.dy - 10),
      8,
      Paint()..color = Colors.black,
    );

    // Tail
    final tailPath = Path();
    tailPath.moveTo(center.dx - 75, center.dy);
    tailPath.lineTo(center.dx - 110, center.dy - 30);
    tailPath.lineTo(center.dx - 110, center.dy + 30);
    tailPath.close();
    canvas.drawPath(tailPath, fill..color = Colors.blue.shade300);
    canvas.drawPath(tailPath, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class SimpleDrawingPainter extends CustomPainter {
  final List<Offset> points;
  final Color color;

  SimpleDrawingPainter(this.points, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 8.0
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

/// ציור רמזים - קווים מקווקווים להראות מה צריך לצייר
class HintPainter extends CustomPainter {
  final String type;
  final Size canvasSize;
  final Color color;

  HintPainter(this.type, this.canvasSize, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = color.withOpacity(0.7);

    // Create dashed path effect
    final dashWidth = 10.0;
    final dashSpace = 5.0;

    final center = Offset(size.width / 2, size.height / 2);

    switch (type) {
      case 'sun':
        _drawSunRaysHint(canvas, center, paint, dashWidth, dashSpace);
        break;
      case 'flower':
        _drawFlowerPetalsHint(canvas, center, paint, dashWidth, dashSpace);
        break;
      case 'house':
        _drawHouseRoofHint(canvas, center, paint, dashWidth, dashSpace);
        break;
      case 'tree':
        _drawTreeLeavesHint(canvas, center, paint, dashWidth, dashSpace);
        break;
      case 'fish':
        _drawFishFinsHint(canvas, center, paint, dashWidth, dashSpace);
        break;
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint, double dashWidth, double dashSpace) {
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);

    _drawDashedPath(canvas, path, paint, dashWidth, dashSpace);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint, double dashWidth, double dashSpace) {
    final metrics = path.computeMetrics();
    for (var metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final start = metric.getTangentForOffset(distance)!.position;
        distance += dashWidth;
        final end = metric.getTangentForOffset(distance.clamp(0, metric.length))!.position;
        canvas.drawLine(start, end, paint);
        distance += dashSpace;
      }
    }
  }

  void _drawSunRaysHint(Canvas canvas, Offset center, Paint paint, double dashWidth, double dashSpace) {
    final radius = min(canvasSize.width, canvasSize.height) / 4;
    final rayLength = radius * 0.6;

    // Draw 8 rays around the sun
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * pi / 8) - pi / 2; // Start from top
      final startX = center.dx + radius * cos(angle);
      final startY = center.dy + radius * sin(angle);
      final endX = center.dx + (radius + rayLength) * cos(angle);
      final endY = center.dy + (radius + rayLength) * sin(angle);

      _drawDashedLine(
        canvas,
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
        dashWidth,
        dashSpace,
      );
    }
  }

  void _drawFlowerPetalsHint(Canvas canvas, Offset center, Paint paint, double dashWidth, double dashSpace) {
    final flowerCenter = Offset(center.dx, center.dy + 40);
    final petalRadius = 35.0;
    final petalDistance = 45.0;

    // Draw 6 petals around center
    for (int i = 0; i < 6; i++) {
      final angle = (i * 2 * pi / 6);
      final petalCenterX = flowerCenter.dx + petalDistance * cos(angle);
      final petalCenterY = flowerCenter.dy + petalDistance * sin(angle);

      final path = Path();
      path.addOval(Rect.fromCenter(
        center: Offset(petalCenterX, petalCenterY),
        width: petalRadius * 2,
        height: petalRadius * 2,
      ));

      _drawDashedPath(canvas, path, paint, dashWidth, dashSpace);
    }
  }

  void _drawHouseRoofHint(Canvas canvas, Offset center, Paint paint, double dashWidth, double dashSpace) {
    final roofWidth = min(canvasSize.width, canvasSize.height) * 0.5;
    final roofHeight = roofWidth * 0.4;
    final roofTop = center.dy - 20;

    // Draw triangle roof
    final path = Path();
    path.moveTo(center.dx - roofWidth / 2, roofTop + roofHeight * 0.4);
    path.lineTo(center.dx, roofTop - roofHeight * 0.3);
    path.lineTo(center.dx + roofWidth / 2, roofTop + roofHeight * 0.4);
    path.close();

    _drawDashedPath(canvas, path, paint, dashWidth, dashSpace);
  }

  void _drawTreeLeavesHint(Canvas canvas, Offset center, Paint paint, double dashWidth, double dashSpace) {
    // Draw cloud-like leaves outline
    final path = Path();
    path.addOval(Rect.fromCenter(
      center: Offset(center.dx, center.dy - 20),
      width: 130,
      height: 100,
    ));

    _drawDashedPath(canvas, path, paint, dashWidth, dashSpace);
  }

  void _drawFishFinsHint(Canvas canvas, Offset center, Paint paint, double dashWidth, double dashSpace) {
    // Top fin
    final topFinPath = Path();
    topFinPath.moveTo(center.dx - 20, center.dy - 40);
    topFinPath.lineTo(center.dx, center.dy - 70);
    topFinPath.lineTo(center.dx + 20, center.dy - 40);
    topFinPath.close();
    _drawDashedPath(canvas, topFinPath, paint, dashWidth, dashSpace);

    // Bottom fin
    final bottomFinPath = Path();
    bottomFinPath.moveTo(center.dx - 20, center.dy + 40);
    bottomFinPath.lineTo(center.dx, center.dy + 70);
    bottomFinPath.lineTo(center.dx + 20, center.dy + 40);
    bottomFinPath.close();
    _drawDashedPath(canvas, bottomFinPath, paint, dashWidth, dashSpace);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
