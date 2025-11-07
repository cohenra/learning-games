import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import '../../utils/responsive_helper.dart';
import '../../widgets/kid_button.dart';

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
  bool _showSuccess = false;

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

  void _checkIfComplete() {
    if (_canvasSize == Size.zero || drawnPoints.isEmpty) return;

    // Easier completion check - just need 25 valid points
    final validPoints = drawnPoints.where((p) => p.dx >= 0).length;

    if (validPoints > 25 && !_showSuccess) {
      setState(() {
        _showSuccess = true;
      });
      _speak(_isHebrew ? 'כל הכבוד!' : 'Well done!');

      // Auto-advance to next letter after 1.5 seconds
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted && _showSuccess) {
          _goToNextLetter();
        }
      });
    }
  }

  void _goToNextLetter() {
    final letters = _isHebrew ? _hebrewLetters : _englishLetters;
    final currentIndex = letters.indexOf(_selectedLetter!);

    if (currentIndex < letters.length - 1) {
      final nextLetter = letters[currentIndex + 1];
      setState(() {
        _selectedLetter = nextLetter;
        drawnPoints.clear();
        _showSuccess = false;
      });
      _speakInstruction(nextLetter);
    } else {
      // Completed all letters - go back to grid
      _speak(_isHebrew ? 'סיימת את כל האותיות! מעולה!' : 'You completed all letters! Excellent!');
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _selectedLetter = null;
            drawnPoints.clear();
            _showSuccess = false;
          });
        }
      });
    }
  }

  Future<void> _speak(String text) async {
    final lang = _isHebrew ? 'he-IL' : 'en-US';
    await _flutterTts.setLanguage(lang);
    await _flutterTts.speak(text);
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                padding: responsive.safePadding,
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
                padding: responsive.safePadding,
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
                padding: responsive.safePadding,
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
            padding: EdgeInsets.all(responsive.spacing(16)),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: responsive.spacing(12),
              mainAxisSpacing: responsive.spacing(12),
              childAspectRatio: 1.0,
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
                        fontSize: responsive.fontSize(40),
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
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isHebrew ? Icons.arrow_forward : Icons.arrow_back,
                        color: Colors.blue.shade700,
                        size: 32,
                      ),
                      onPressed: () => setState(() {
                        _selectedLetter = null;
                        drawnPoints.clear();
                        _showSuccess = false;
                      }),
                    ),
                    Expanded(
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
                    const SizedBox(width: 48),
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
                                _checkIfComplete();
                              },
                              child: CustomPaint(
                                painter: DrawingPainter(drawnPoints, color),
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

              // Clear button (only when not showing success)
              if (!_showSuccess)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
                  child: KidButton(
                    text: _isHebrew ? 'נקה 🗑️' : 'Clear 🗑️',
                    icon: Icons.delete,
                    onPressed: _clearDrawing,
                    color: Colors.orange,
                    height: 60,
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

/// ציור אות המדריך - תמיד מציג את האות
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

    // Determine opacity based on difficulty
    double opacity;
    if (difficulty == 'easy') {
      opacity = 0.4; // Clear guide
    } else if (difficulty == 'medium') {
      opacity = 0.25; // Light guide
    } else {
      opacity = 0.15; // Faint guide (but still visible!)
    }

    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color.withOpacity(opacity),
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
