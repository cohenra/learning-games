import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import '../../utils/responsive_helper.dart';
import '../../widgets/kid_button.dart';

/// מסך תרגול כתיבת מספרים - גרסה משופרת
class NumberTracingScreen extends StatefulWidget {
  const NumberTracingScreen({super.key});

  @override
  State<NumberTracingScreen> createState() => _NumberTracingScreenState();
}

class _NumberTracingScreenState extends State<NumberTracingScreen> {
  final FlutterTts _flutterTts = FlutterTts();

  bool _isHebrew = true;
  String _selectedDifficulty = ''; // 'easy', 'medium', 'hard'
  int? _selectedNumber; // null means show grid
  List<Offset> drawnPoints = [];
  Size _canvasSize = Size.zero;
  bool _showCheck = false; // Show the number temporarily when Check button is pressed

  // All numbers 0-10
  final List<int> _allNumbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  final Map<int, Color> _numberColors = {
    0: Colors.purple,
    1: Colors.blue,
    2: Colors.green,
    3: Colors.red,
    4: Colors.orange,
    5: Colors.pink,
    6: Colors.teal,
    7: Colors.indigo,
    8: Colors.cyan,
    9: Colors.amber,
    10: Colors.deepPurple,
  };

  @override
  void initState() {
    super.initState();
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isHebrew = Localizations.localeOf(context).languageCode == 'he';
      });
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speakInstruction(int number) async {
    final text = _isHebrew ? 'כתוב את המספר $number' : 'Write the number $number';
    final lang = _isHebrew ? 'he-IL' : 'en-US';

    await _flutterTts.setLanguage(lang);
    await _flutterTts.speak(text);
  }

  void _goToNextNumber() {
    final currentIndex = _allNumbers.indexOf(_selectedNumber!);

    if (currentIndex < _allNumbers.length - 1) {
      final nextNumber = _allNumbers[currentIndex + 1];
      setState(() {
        _selectedNumber = nextNumber;
        drawnPoints.clear();
        _showCheck = false;
      });
      _speakInstruction(nextNumber);
    } else {
      // Completed all numbers - go back to grid
      setState(() {
        _selectedNumber = null;
        drawnPoints.clear();
        _showCheck = false;
      });
    }
  }

  void _showCheckTemporarily() {
    setState(() {
      _showCheck = true;
    });

    // Hide check after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showCheck = false;
        });
      }
    });
  }

  Future<void> _speak(String text) async {
    final lang = _isHebrew ? 'he-IL' : 'en-US';
    await _flutterTts.setLanguage(lang);
    await _flutterTts.speak(text);
  }

  void _clearDrawing() {
    setState(() {
      drawnPoints.clear();
      _showCheck = false;
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

    if (_selectedDifficulty.isEmpty) {
      return _buildDifficultySelector(responsive);
    } else if (_selectedNumber == null) {
      return _buildNumberGrid(responsive);
    } else {
      return _buildTracingScreen(responsive);
    }
  }

  Widget _buildDifficultySelector(ResponsiveHelper responsive) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange.shade50, Colors.yellow.shade50],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '✍️',
                        style: TextStyle(fontSize: responsive.iconSize(80)),
                      ),
                      SizedBox(height: responsive.spacing(20)),
                      Text(
                        _isHebrew ? 'תרגול כתיבת מספרים' : 'Number Tracing',
                        style: TextStyle(
                          fontSize: responsive.titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: responsive.spacing(40)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                        child: KidButton(
                          text: _isHebrew ? 'קל - עם מדריך ברור ✨' : 'Easy - With Clear Guide ✨',
                          icon: Icons.star,
                          onPressed: () => setState(() => _selectedDifficulty = 'easy'),
                          color: Colors.green,
                          height: responsive.buttonHeight,
                        ),
                      ),
                      SizedBox(height: responsive.verticalSpacing),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                        child: KidButton(
                          text: _isHebrew ? 'בינוני - עם מדריך קל 💫' : 'Medium - With Light Guide 💫',
                          icon: Icons.star_half,
                          onPressed: () => setState(() => _selectedDifficulty = 'medium'),
                          color: Colors.orange,
                          height: responsive.buttonHeight,
                        ),
                      ),
                      SizedBox(height: responsive.verticalSpacing),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                        child: KidButton(
                          text: _isHebrew ? 'קשה - בלי מדריך 🌟' : 'Hard - Without Guide 🌟',
                          icon: Icons.star_border,
                          onPressed: () => setState(() => _selectedDifficulty = 'hard'),
                          color: Colors.red,
                          height: responsive.buttonHeight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          // Back button
          Positioned(
            top: 8,
            right: _isHebrew ? 8 : null,
            left: _isHebrew ? null : 8,
            child: KidBackButton(
              onPressed: () => Navigator.pop(context),
              color: Colors.orange.shade600,
              isHebrew: _isHebrew,
            ),
          ),
        ],
        ),
      ),
      ),
    );
  }

  Widget _buildNumberGrid(ResponsiveHelper responsive) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isHebrew ? 'בחר מספר' : 'Choose a Number'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _selectedDifficulty = ''),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange.shade50, Colors.yellow.shade50],
          ),
        ),
        child: SafeArea(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.spacing(20),
              vertical: responsive.spacing(8),
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: responsive.spacing(10),
              mainAxisSpacing: responsive.spacing(10),
              childAspectRatio: 1.1,
            ),
            itemCount: _allNumbers.length,
            itemBuilder: (context, index) {
              final number = _allNumbers[index];
              final color = _numberColors[number]!;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedNumber = number;
                  });
                  _speakInstruction(number);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: TextStyle(
                        fontSize: responsive.fontSize(36),
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTracingScreen(ResponsiveHelper responsive) {
    final number = _selectedNumber!;
    final color = _numberColors[number]!;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange.shade50, Colors.yellow.shade50],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(responsive.spacing(12)),
                child: Stack(
                  children: [
                    // Centered title
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: Text(
                          '${_isHebrew ? 'כתוב את המספר' : 'Write the number'} $number',
                          style: TextStyle(
                            fontSize: responsive.titleSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    // Back button positioned based on language
                    Positioned(
                      right: _isHebrew ? 0 : null,
                      left: _isHebrew ? null : 0,
                      child: IconButton(
                        icon: Icon(
                          _isHebrew ? Icons.arrow_forward : Icons.arrow_back,
                          color: Colors.orange.shade700,
                          size: 32,
                        ),
                        onPressed: () => setState(() {
                          _selectedNumber = null;
                          drawnPoints.clear();
                          _showCheck = false;
                        }),
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
                            // Guide number (ALWAYS shown - regardless of difficulty)
                            CustomPaint(
                              painter: GuideNumberPainter(
                                '$number',
                                _selectedDifficulty,
                                _canvasSize,
                                color,
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
                                  drawnPoints.add(const Offset(-1, -1));
                                });
                              },
                              child: CustomPaint(
                                painter: DrawingPainter(drawnPoints, color),
                                size: Size.infinite,
                              ),
                            ),
                            // Check overlay - shows the number when Check button is pressed
                            if (_showCheck)
                              CustomPaint(
                                painter: CheckNumberPainter(
                                  '$number',
                                  _canvasSize,
                                  color,
                                ),
                                size: Size.infinite,
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: responsive.spacing(16)),

              // Action buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
                child: _selectedDifficulty == 'easy'
                    ? Row(
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
                                onPressed: _goToNextNumber,
                                color: Colors.green,
                                height: 60,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          // Clear button row
                          KidButton(
                            text: _isHebrew ? 'נקה 🗑️' : 'Clear 🗑️',
                            icon: Icons.delete,
                            onPressed: _clearDrawing,
                            color: Colors.orange,
                            height: 60,
                          ),
                          const SizedBox(height: 12),
                          // Check and Next buttons row
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: KidButton(
                                    text: _isHebrew ? 'בדיקה 🔍' : 'Check 🔍',
                                    icon: Icons.visibility,
                                    onPressed: _showCheckTemporarily,
                                    color: Colors.purple,
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
                                    onPressed: _goToNextNumber,
                                    color: Colors.green,
                                    height: 60,
                                  ),
                                ),
                              ),
                            ],
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

/// ציור מספר המדריך - מציג לפי רמת קושי
class GuideNumberPainter extends CustomPainter {
  final String number;
  final String difficulty;
  final Size canvasSize;
  final Color color;

  GuideNumberPainter(this.number, this.difficulty, this.canvasSize, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final fontSize = min(size.width, size.height) * 0.7;

    if (difficulty == 'easy') {
      // Easy: Clear transparent number
      final textStyle = TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color.withOpacity(0.35),
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

      textPainter.paint(canvas, offset);
    } else if (difficulty == 'medium') {
      // Medium: Draw the number outline as dots following its shape
      final textStyle = TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..color = color,
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

      // Create dots by drawing the outline multiple times with circular clips
      // This creates a dotted pattern that follows the number's shape
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      // Draw dots in a grid pattern that intersects with the number
      final dotSpacing = 20.0; // Large gap between dots
      final dotRadius = 4.0;

      for (double y = -20.0; y < textPainter.height + 20; y += dotSpacing) {
        for (double x = -20.0; x < textPainter.width + 20; x += dotSpacing) {
          // For each potential dot position, check if it's near the number outline
          // We do this by drawing a small area and checking
          canvas.save();

          // Clip to a small circle
          final dotCenter = Offset(offset.dx + x, offset.dy + y);
          canvas.clipRect(Rect.fromCircle(center: dotCenter, radius: dotRadius + 2));

          // Draw the text outline - if it intersects with our circle, the dot will show
          textPainter.paint(canvas, offset);

          canvas.restore();
        }
      }
    }
    // Hard: No guide at all
  }

  Path _createTextPath(TextPainter textPainter) {
    // This is a simplified approach - just drawing a rectangular outline
    // For actual text outline, we would need more complex path extraction
    final path = Path();
    path.addRect(Rect.fromLTWH(0, 0, textPainter.width, textPainter.height));
    return path;
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint, double dashLength, double dashSpace) {
    final metrics = path.computeMetrics();
    for (var metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final start = metric.getTangentForOffset(distance)!.position;
        distance += dashLength;
        final end = metric.getTangentForOffset(distance.clamp(0, metric.length))!.position;
        canvas.drawLine(start, end, paint);
        distance += dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

/// ציור המספר בבדיקה - מציג את המספר המלא לזמן קצר
class CheckNumberPainter extends CustomPainter {
  final String number;
  final Size canvasSize;
  final Color color;

  CheckNumberPainter(this.number, this.canvasSize, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final fontSize = min(size.width, size.height) * 0.7;

    // Draw semi-transparent overlay
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white.withOpacity(0.7),
    );

    // Draw the number
    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color.withOpacity(0.8),
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

    textPainter.paint(canvas, offset);
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
