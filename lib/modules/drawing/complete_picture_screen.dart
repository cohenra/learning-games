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
  List<Offset> drawnPoints = [];

  // רשימת אתגרים - כל אתגר מכיל תיאור של מה צריך להשלים
  final List<Map<String, dynamic>> _challenges = [
    {
      'nameHe': 'שמש',
      'nameEn': 'Sun',
      'descriptionHe': 'צייר קרניים לשמש!',
      'descriptionEn': 'Draw rays for the sun!',
      'emoji': '☀️',
      'color': Colors.yellow,
      'checkComplete': (List<Offset> points) => points.length > 20,
    },
    {
      'nameHe': 'פרח',
      'nameEn': 'Flower',
      'descriptionHe': 'צייר עלי כותרת לפרח!',
      'descriptionEn': 'Draw petals for the flower!',
      'emoji': '🌸',
      'color': Colors.pink,
      'checkComplete': (List<Offset> points) => points.length > 30,
    },
    {
      'nameHe': 'בית',
      'nameEn': 'House',
      'descriptionHe': 'צייר גג לבית!',
      'descriptionEn': 'Draw a roof for the house!',
      'emoji': '🏠',
      'color': Colors.red,
      'checkComplete': (List<Offset> points) => points.length > 25,
    },
    {
      'nameHe': 'עץ',
      'nameEn': 'Tree',
      'descriptionHe': 'צייר עלים לעץ!',
      'descriptionEn': 'Draw leaves for the tree!',
      'emoji': '🌳',
      'color': Colors.green,
      'checkComplete': (List<Offset> points) => points.length > 35,
    },
    {
      'nameHe': 'דג',
      'nameEn': 'Fish',
      'descriptionHe': 'צייר סנפירים לדג!',
      'descriptionEn': 'Draw fins for the fish!',
      'emoji': '🐟',
      'color': Colors.blue,
      'checkComplete': (List<Offset> points) => points.length > 20,
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
    final challenge = _challenges[_currentLevel];
    final checkComplete = challenge['checkComplete'] as bool Function(List<Offset>);

    if (checkComplete(drawnPoints)) {
      setState(() {
        _showSuccess = true;
      });

      _speak(_isHebrew ? 'כל הכבוד! מעולה!' : 'Well done! Excellent!');
    }
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
                    Text(
                      challenge['emoji'] as String,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(width: 16),
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
                    child: Stack(
                      children: [
                        // Base shape (emoji in center)
                        Center(
                          child: Text(
                            challenge['emoji'] as String,
                            style: const TextStyle(fontSize: 150),
                          ),
                        ),
                        // Drawing layer
                        GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              drawnPoints.add(details.localPosition);
                            });
                            _checkIfComplete();
                          },
                          onPanEnd: (details) {
                            setState(() {
                              drawnPoints.add(const Offset(-1, -1)); // Separator
                            });
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
