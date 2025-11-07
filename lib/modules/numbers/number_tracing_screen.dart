import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import '../../utils/responsive_helper.dart';
import '../../widgets/kid_button.dart';

/// מסך תרגול כתיבת מספרים
class NumberTracingScreen extends StatefulWidget {
  const NumberTracingScreen({super.key});

  @override
  State<NumberTracingScreen> createState() => _NumberTracingScreenState();
}

class _NumberTracingScreenState extends State<NumberTracingScreen> {
  final FlutterTts _flutterTts = FlutterTts();

  int _currentLevel = 0;
  bool _isHebrew = true;
  bool _showSuccess = false;
  List<Offset> drawnPoints = [];
  Size _canvasSize = Size.zero;

  // רמות המשחק - כל רמה עם קושי שונה
  final List<Map<String, dynamic>> _levels = [
    // Easy - digits 1-3
    {'number': '1', 'difficulty': 'easy', 'color': Colors.blue, 'value': 1},
    {'number': '2', 'difficulty': 'easy', 'color': Colors.green, 'value': 2},
    {'number': '3', 'difficulty': 'easy', 'color': Colors.red, 'value': 3},

    // Medium - digits 4-6
    {'number': '4', 'difficulty': 'medium', 'color': Colors.purple, 'value': 4},
    {'number': '5', 'difficulty': 'medium', 'color': Colors.orange, 'value': 5},
    {'number': '6', 'difficulty': 'medium', 'color': Colors.pink, 'value': 6},

    // Hard - digits 7-9
    {'number': '7', 'difficulty': 'hard', 'color': Colors.teal, 'value': 7},
    {'number': '8', 'difficulty': 'hard', 'color': Colors.indigo, 'value': 8},
    {'number': '9', 'difficulty': 'hard', 'color': Colors.cyan, 'value': 9},
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
    final number = level['number'] as String;
    final text = _isHebrew ? 'כתוב את המספר $number' : 'Write the number $number';
    final lang = _isHebrew ? 'he-IL' : 'en-US';

    await _flutterTts.setLanguage(lang);
    await _flutterTts.speak(text);
  }

  void _checkIfComplete() {
    if (_canvasSize == Size.zero || drawnPoints.isEmpty) return;

    // Check if enough drawing was done
    final validPoints = drawnPoints.where((p) => p.dx >= 0).length;

    if (validPoints > 40 && !_showSuccess) {
      setState(() {
        _showSuccess = true;
      });
      _speak(_isHebrew ? 'כל הכבוד! כתבת יפה!' : 'Well done! You wrote it nicely!');
    }
  }

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
      });
      _speakInstruction();
    } else {
      _speak(_isHebrew ? 'סיימת את כל המספרים! מעולה!' : 'You completed all numbers! Excellent!');
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    }
  }

  void _clearDrawing() {
    setState(() {
      drawnPoints.clear();
      _showSuccess = false;
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
                        _isHebrew ? 'תרגול כתיבת מספרים' : 'Number Tracing',
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
                      '${_isHebrew ? 'כתוב את המספר' : 'Write the number'} ${level['number']}',
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
                            // Guide number (based on difficulty)
                            CustomPaint(
                              painter: GuideNumberPainter(
                                level['number'] as String,
                                difficulty,
                                _canvasSize,
                                level['color'] as Color,
                              ),
                              size: Size.infinite,
                            ),
                            // Drawing layer
                            GestureDetector(
                              onPanStart: (details) {
                                setState(() {
                                  drawnPoints.add(details.localPosition);
                                });
                              },
                              onPanUpdate: (details) {
                                setState(() {
                                  drawnPoints.add(details.localPosition);
                                });
                              },
                              onPanEnd: (details) {
                                setState(() {
                                  drawnPoints.add(const Offset(-1, -1)); // Separator
                                });
                                _checkIfComplete();
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
                                        _isHebrew ? 'מצוין!' : 'Excellent!',
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
                child: Row(
                  children: [
                    if (!_showSuccess)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: KidButton(
                            text: _isHebrew ? 'נקה 🗑️' : 'Clear 🗑️',
                            icon: Icons.delete,
                            onPressed: _clearDrawing,
                            color: Colors.orange,
                            height: 60,
                          ),
                        ),
                      ),
                    if (_showSuccess)
                      Expanded(
                        child: KidButton(
                          text: _isHebrew ? 'הבא ➡️' : 'Next ➡️',
                          icon: Icons.arrow_forward,
                          onPressed: _nextLevel,
                          color: Colors.green,
                          height: 60,
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

/// ציור מספר המדריך (תלוי ברמת הקושי)
class GuideNumberPainter extends CustomPainter {
  final String number;
  final String difficulty;
  final Size canvasSize;
  final Color color;

  GuideNumberPainter(this.number, this.difficulty, this.canvasSize, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (difficulty == 'hard') {
      // No guide for hard difficulty
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final fontSize = min(size.width, size.height) * 0.7;

    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: difficulty == 'easy' ? color.withOpacity(0.3) : color.withOpacity(0.15),
    );

    final textSpan = TextSpan(text: number, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final offset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );

    if (difficulty == 'easy') {
      // Draw solid guide number
      textPainter.paint(canvas, offset);
    } else if (difficulty == 'medium') {
      // Draw dotted outline
      textPainter.paint(canvas, offset);

      // Draw dots around the number
      final paint = Paint()
        ..color = color.withOpacity(0.5)
        ..strokeWidth = 6.0
        ..style = PaintingStyle.fill;

      // Draw a few guide dots
      final numDots = 12;
      final numberRect = Rect.fromCenter(
        center: center,
        width: textPainter.width,
        height: textPainter.height,
      );

      for (int i = 0; i < numDots; i++) {
        final angle = (i * 2 * pi / numDots);
        final x = center.dx + (numberRect.width / 2.5) * cos(angle);
        final y = center.dy + (numberRect.height / 2.5) * sin(angle);
        canvas.drawCircle(Offset(x, y), 4, paint);
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
