import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import '../../utils/responsive_helper.dart';
import '../../widgets/kid_button.dart';
import '../../widgets/kid_back_button.dart';

/// מסך תרגול כתיבת אותיות - גרסה משופרת
class LetterTracingScreen extends StatefulWidget {
  const LetterTracingScreen({super.key});

  @override
  State<LetterTracingScreen> createState() => _LetterTracingScreenState();
}

class _LetterTracingScreenState extends State<LetterTracingScreen> {
  final FlutterTts _flutterTts = FlutterTts();

  bool _isHebrew = true;
  String _selectedDifficulty = ''; // 'easy', 'medium', 'hard'
  String? _selectedLetter; // null means show grid
  List<Offset> drawnPoints = [];
  Size _canvasSize = Size.zero;
  bool _showCheck = false; // Show the letter temporarily when Check button is pressed
  int? _activePointerId; // Track the active finger for single-touch drawing

  // All Hebrew letters
  final List<String> _hebrewLetters = [
    'א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ז', 'ח', 'ט', 'י', 'כ',
    'ל', 'מ', 'נ', 'ס', 'ע', 'פ', 'צ', 'ק', 'ר', 'ש', 'ת'
  ];

  // All English letters
  final List<String> _englishLetters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
  ];

  final List<Color> _colors = [
    Colors.blue, Colors.green, Colors.red, Colors.orange, Colors.purple,
    Colors.pink, Colors.teal, Colors.indigo, Colors.cyan, Colors.amber,
  ];

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

  Future<void> _speakInstruction(String letter) async {
    final text = _isHebrew ? 'כתוב את האות $letter' : 'Write the letter $letter';
    final lang = _isHebrew ? 'he-IL' : 'en-US';

    await _flutterTts.setLanguage(lang);
    await _flutterTts.speak(text);
  }

  void _goToNextLetter() {
    final letters = _isHebrew ? _hebrewLetters : _englishLetters;
    final currentIndex = letters.indexOf(_selectedLetter!);

    if (currentIndex < letters.length - 1) {
      final nextLetter = letters[currentIndex + 1];
      setState(() {
        _selectedLetter = nextLetter;
        drawnPoints.clear();
        _showCheck = false;
        _activePointerId = null; // Reset active pointer
      });
      _speakInstruction(nextLetter);
    } else {
      // Completed all letters - go back to grid
      setState(() {
        _selectedLetter = null;
        drawnPoints.clear();
        _showCheck = false;
        _activePointerId = null; // Reset active pointer
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

    if (_selectedDifficulty.isEmpty) {
      return _buildDifficultySelector(responsive);
    } else if (_selectedLetter == null) {
      return _buildLetterGrid(responsive);
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
            colors: [Colors.blue.shade50, Colors.purple.shade50],
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
                        _isHebrew ? 'תרגול כתיבת אותיות' : 'Letter Tracing',
                        style: TextStyle(
                          fontSize: responsive.titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
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
              color: Colors.blue.shade600,
              isHebrew: _isHebrew,
            ),
          ),
        ],
        ),
      ),
      ),
    );
  }

  Widget _buildLetterGrid(ResponsiveHelper responsive) {
    final letters = _isHebrew ? _hebrewLetters : _englishLetters;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isHebrew ? 'בחר אות' : 'Choose a Letter'),
        centerTitle: true,
        backgroundColor: Colors.blue,
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
            colors: [Colors.blue.shade50, Colors.purple.shade50],
          ),
        ),
        child: SafeArea(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.spacing(20),
              vertical: responsive.spacing(8),
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: responsive.spacing(10),
              mainAxisSpacing: responsive.spacing(10),
              childAspectRatio: 1.1,
            ),
            itemCount: letters.length,
            itemBuilder: (context, index) {
              final letter = letters[index];
              final color = _colors[index % _colors.length];

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedLetter = letter;
                  });
                  _speakInstruction(letter);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: responsive.fontSize(32),
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontFamily: _isHebrew ? 'Rubik' : null,
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
    final letters = _isHebrew ? _hebrewLetters : _englishLetters;
    final letterIndex = letters.indexOf(_selectedLetter!);
    final color = _colors[letterIndex % _colors.length];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.purple.shade50],
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
                          '${_isHebrew ? 'כתוב את האות' : 'Write the letter'} $_selectedLetter',
                          style: TextStyle(
                            fontSize: responsive.titleSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
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
                          color: Colors.blue.shade700,
                          size: 32,
                        ),
                        onPressed: () => setState(() {
                          _selectedLetter = null;
                          drawnPoints.clear();
                          _showCheck = false;
                          _activePointerId = null;
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
                        color: Colors.blue.withOpacity(0.3),
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
                            // Guide letter (ALWAYS shown)
                            CustomPaint(
                              painter: GuideLetterPainter(
                                _selectedLetter!,
                                _selectedDifficulty,
                                _canvasSize,
                                color,
                                _isHebrew,
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
                                    drawnPoints.add(const Offset(-1, -1));
                                    _activePointerId = null;
                                  });
                                }
                              },
                              child: CustomPaint(
                                painter: DrawingPainter(drawnPoints, color),
                                size: Size.infinite,
                              ),
                            ),
                            // Check overlay - shows the letter when Check button is pressed
                            if (_showCheck)
                              CustomPaint(
                                painter: CheckLetterPainter(
                                  _selectedLetter!,
                                  _canvasSize,
                                  color,
                                  _isHebrew,
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
                                onPressed: _goToNextLetter,
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
                                    onPressed: _goToNextLetter,
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

/// ציור אות המדריך - מציג לפי רמת קושי
class GuideLetterPainter extends CustomPainter {
  final String letter;
  final String difficulty;
  final Size canvasSize;
  final Color color;
  final bool isHebrew;

  GuideLetterPainter(this.letter, this.difficulty, this.canvasSize, this.color, this.isHebrew);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final fontSize = min(size.width, size.height) * 0.7;

    if (difficulty == 'easy') {
      // Easy: Clear transparent letter
      final textStyle = TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color.withOpacity(0.35),
        fontFamily: isHebrew ? 'Rubik' : null,
      );

      final textSpan = TextSpan(text: letter, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: isHebrew ? TextDirection.rtl : TextDirection.ltr,
      );

      textPainter.layout();

      final offset = Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      );

      textPainter.paint(canvas, offset);
    } else if (difficulty == 'medium') {
      // Medium: Draw the letter outline as dots following its shape
      final textStyle = TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..color = color,
      );

      final textSpan = TextSpan(text: letter, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: isHebrew ? TextDirection.rtl : TextDirection.ltr,
      );

      textPainter.layout();

      final offset = Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      );

      // Create dots by drawing the outline multiple times with circular clips
      // This creates a dotted pattern that follows the letter's shape
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      // Draw dots in a grid pattern that intersects with the letter
      final dotSpacing = 20.0; // Large gap between dots
      final dotRadius = 4.0;

      for (double y = -20.0; y < textPainter.height + 20; y += dotSpacing) {
        for (double x = -20.0; x < textPainter.width + 20; x += dotSpacing) {
          // For each potential dot position, check if it's near the letter outline
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

/// ציור האות בבדיקה - מציג את האות המלאה לזמן קצר
class CheckLetterPainter extends CustomPainter {
  final String letter;
  final Size canvasSize;
  final Color color;
  final bool isHebrew;

  CheckLetterPainter(this.letter, this.canvasSize, this.color, this.isHebrew);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final fontSize = min(size.width, size.height) * 0.7;

    // Draw semi-transparent overlay
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white.withOpacity(0.7),
    );

    // Draw the letter
    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color.withOpacity(0.8),
      fontFamily: isHebrew ? 'Rubik' : null,
    );

    final textSpan = TextSpan(text: letter, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: isHebrew ? TextDirection.rtl : TextDirection.ltr,
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
