import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';

/// מסך חידון כלי נגינה
class InstrumentsQuizScreen extends StatefulWidget {
  const InstrumentsQuizScreen({super.key});

  @override
  State<InstrumentsQuizScreen> createState() => _InstrumentsQuizScreenState();
}

class _InstrumentsQuizScreenState extends State<InstrumentsQuizScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();

  final List<Map<String, String>> _allInstruments = [
    {'emoji': '🎸', 'nameHe': 'גיטרה', 'nameEn': 'Guitar'},
    {'emoji': '🎹', 'nameHe': 'פסנתר', 'nameEn': 'Piano'},
    {'emoji': '🥁', 'nameHe': 'תוף', 'nameEn': 'Drum'},
    {'emoji': '🎺', 'nameHe': 'חצוצרה', 'nameEn': 'Trumpet'},
    {'emoji': '🎻', 'nameHe': 'כינור', 'nameEn': 'Violin'},
    {'emoji': '🎷', 'nameHe': 'סקסופון', 'nameEn': 'Saxophone'},
    {'emoji': '🪕', 'nameHe': 'בנג\'ו', 'nameEn': 'Banjo'},
    {'emoji': '🪗', 'nameHe': 'אקורדיון', 'nameEn': 'Accordion'},
    {'emoji': '🎤', 'nameHe': 'מיקרופון', 'nameEn': 'Microphone'},
    {'emoji': '🪘', 'nameHe': 'תוף עם מקלות', 'nameEn': 'Drum with Sticks'},
    {'emoji': '🎼', 'nameHe': 'תווים', 'nameEn': 'Musical Notes'},
    {'emoji': '🔔', 'nameHe': 'פעמון', 'nameEn': 'Bell'},
  ];

  int _currentQuestion = 0;
  int _score = 0;
  int _correctAnswers = 0;
  bool _answered = false;
  int? _selectedAnswer;
  bool? _isCorrect;
  bool _isHebrew = true;

  late Map<String, String> _correctInstrument;
  late List<Map<String, String>> _options;
  late int _correctAnswerIndex;

  @override
  void initState() {
    super.initState();
    _initTts();
    _generateQuestion(); // Generate first question immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isHebrew = Localizations.localeOf(context).languageCode == 'he';
      });
      _speakQuestion(); // Speak after getting language
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setPitch(1.0);
  }

  void _generateQuestion() {
    // Pick correct instrument
    _correctInstrument = _allInstruments[_random.nextInt(_allInstruments.length)];

    // Pick 3 wrong answers
    final wrongOptions = List<Map<String, String>>.from(_allInstruments)
      ..remove(_correctInstrument)
      ..shuffle(_random);

    // Create 4 options
    _options = [
      _correctInstrument,
      wrongOptions[0],
      wrongOptions[1],
      wrongOptions[2],
    ]..shuffle(_random);

    // Find correct answer index
    _correctAnswerIndex = _options.indexOf(_correctInstrument);
  }

  Future<void> _speakQuestion() async {
    final instrumentName = _isHebrew
        ? _correctInstrument['nameHe']!
        : _correctInstrument['nameEn']!;
    final question = _isHebrew
        ? 'איפה $instrumentName?'
        : 'Where is $instrumentName?';
    final lang = _isHebrew ? 'he-IL' : 'en-US';

    await _flutterTts.setLanguage(lang);
    await _flutterTts.speak(question);
  }

  void _checkAnswer(int index) {
    if (_answered) return;

    setState(() {
      _answered = true;
      _selectedAnswer = index;
      _isCorrect = index == _correctAnswerIndex;
      if (_isCorrect!) {
        _score++;
        _correctAnswers++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        _currentQuestion++;
        _answered = false;
        _selectedAnswer = null;
        _isCorrect = null;
      });
      _generateQuestion();
      _speakQuestion();
    });
  }

  void _showFinalScore() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          _isHebrew ? '🎉 כל הכבוד! 🎉' : '🎉 Well Done! 🎉',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isHebrew ? 'סיימת את החידון!' : 'You finished the quiz!',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              _isHebrew ? 'תשובות נכונות:' : 'Correct answers:',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              '$_correctAnswers',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _isHebrew ? 'כוכבים:' : 'Stars:',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              '⭐ $_score',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(_isHebrew ? 'חזרה לתפריט' : 'Back to Menu'),
          ),
        ],
      ),
    );
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
              Colors.orange.shade50,
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
                        _isHebrew ? 'חידון כלי נגינה' : 'Instruments Quiz',
                        style: TextStyle(
                          fontSize: responsive.titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
              ),

              // Progress and score
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isHebrew ? 'שאלה ${_currentQuestion + 1}' : 'Question ${_currentQuestion + 1}',
                      style: TextStyle(
                        fontSize: responsive.fontSize(18),
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                    Text(
                      '${_isHebrew ? 'ניקוד' : 'Score'}: $_score',
                      style: TextStyle(
                        fontSize: responsive.fontSize(18),
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: responsive.spacing(20)),

              // Question
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                child: Container(
                  padding: EdgeInsets.all(responsive.spacing(20)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    _isHebrew
                        ? 'איפה ${_correctInstrument['nameHe']}?'
                        : 'Where is ${_correctInstrument['nameEn']}?',
                    style: TextStyle(
                      fontSize: responsive.fontSize(24),
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Options
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final availableHeight = constraints.maxHeight;
                    final availableWidth = constraints.maxWidth;

                    const padding = 20.0;
                    const spacing = 20.0;

                    // 4 items in 2x2 grid
                    final rowCount = 2;

                    // Calculate card dimensions
                    final totalVerticalSpacing = spacing + (padding * 2);
                    final cardHeight = (availableHeight - totalVerticalSpacing) / rowCount;

                    final totalHorizontalSpacing = spacing + (padding * 2);
                    final cardWidth = (availableWidth - totalHorizontalSpacing) / 2;

                    final aspectRatio = cardWidth / cardHeight;

                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(padding),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        childAspectRatio: aspectRatio,
                      ),
                      itemCount: _options.length,
                      itemBuilder: (context, index) {
                        return _buildOptionCard(index);
                      },
                    );
                  },
                ),
              ),

              // Buttons - Hear again and Finish
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: KidButton(
                          text: _isHebrew ? 'שמע שוב 🔊' : 'Hear Again 🔊',
                          icon: Icons.volume_up,
                          onPressed: _speakQuestion,
                          color: Colors.green,
                          height: 60,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: KidButton(
                          text: _isHebrew ? 'סיום 🏁' : 'Finish 🏁',
                          icon: Icons.check_circle,
                          onPressed: _showFinalScore,
                          color: Colors.red,
                          height: 60,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(int index) {
    final option = _options[index];
    final isSelected = _selectedAnswer == index;
    final isCorrectOption = index == _correctAnswerIndex;

    Color borderColor = Colors.purple.shade200;
    Color backgroundColor = Colors.white;

    if (_answered && isSelected) {
      if (_isCorrect!) {
        borderColor = Colors.green;
        backgroundColor = Colors.green.shade50;
      } else {
        borderColor = Colors.red;
        backgroundColor = Colors.red.shade50;
      }
    } else if (_answered && isCorrectOption) {
      borderColor = Colors.green;
      backgroundColor = Colors.green.shade50;
    }

    return GestureDetector(
      onTap: () => _checkAnswer(index),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              flex: 3,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  option['emoji']!,
                  style: const TextStyle(fontSize: 60),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              flex: 1,
              child: Text(
                _isHebrew ? option['nameHe']! : option['nameEn']!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected && _isCorrect!)
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(Icons.check_circle, color: Colors.green, size: 28),
                ),
              ),
            if (isSelected && !_isCorrect!)
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(Icons.cancel, color: Colors.red, size: 28),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
