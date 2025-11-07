import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';

/// מסך חידון תווים מוזיקליים
class NotesQuizScreen extends StatefulWidget {
  const NotesQuizScreen({super.key});

  @override
  State<NotesQuizScreen> createState() => _NotesQuizScreenState();
}

class _NotesQuizScreenState extends State<NotesQuizScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();

  final List<Map<String, dynamic>> _allNotes = [
    {'nameHe': 'דו', 'nameEn': 'Do', 'letter': 'C', 'color': Colors.red, 'ttsHe': 'דוֹ'},
    {'nameHe': 'רה', 'nameEn': 'Re', 'letter': 'D', 'color': Colors.orange, 'ttsHe': 'רֶה'},
    {'nameHe': 'מי', 'nameEn': 'Mi', 'letter': 'E', 'color': Colors.yellow, 'ttsHe': 'מִי'},
    {'nameHe': 'פה', 'nameEn': 'Fa', 'letter': 'F', 'color': Colors.green, 'ttsHe': 'פָה'},
    {'nameHe': 'סול', 'nameEn': 'Sol', 'letter': 'G', 'color': Colors.blue, 'ttsHe': 'סוֹל'},
    {'nameHe': 'לה', 'nameEn': 'La', 'letter': 'A', 'color': Colors.purple, 'ttsHe': 'לָה'},
    {'nameHe': 'סי', 'nameEn': 'Si', 'letter': 'B', 'color': Colors.pink, 'ttsHe': 'סִי'},
  ];

  int _currentQuestion = 0;
  int _score = 0;
  bool _answered = false;
  int? _selectedAnswer;
  bool? _isCorrect;
  bool _isHebrew = true;

  late Map<String, dynamic> _correctNote;
  late List<Map<String, dynamic>> _options;
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
    // Pick correct note
    _correctNote = _allNotes[_random.nextInt(_allNotes.length)];

    // Pick 3 wrong answers
    final wrongOptions = List<Map<String, dynamic>>.from(_allNotes)
      ..remove(_correctNote)
      ..shuffle(_random);

    // Create 4 options
    _options = [
      _correctNote,
      wrongOptions[0],
      wrongOptions[1],
      wrongOptions[2],
    ]..shuffle(_random);

    // Find correct answer index
    _correctAnswerIndex = _options.indexOf(_correctNote);
  }

  Future<void> _speakQuestion() async {
    final noteName = _isHebrew ? _correctNote['ttsHe']! : _correctNote['nameEn']!;
    final question = _isHebrew ? 'איפה $noteName?' : 'Where is $noteName?';
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
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_currentQuestion < 9) {
        setState(() {
          _currentQuestion++;
          _answered = false;
          _selectedAnswer = null;
          _isCorrect = null;
        });
        _generateQuestion();
        _speakQuestion();
      } else {
        _showResults();
      }
    });
  }

  void _showResults() {
    final percentage = (_score / 10 * 100).round();
    String message = '';
    String emoji = '';

    if (percentage >= 80) {
      message = _isHebrew ? 'מעולה! אתה מכיר את התווים!' : 'Excellent! You know the notes!';
      emoji = '🎵';
    } else if (percentage >= 60) {
      message = _isHebrew ? 'טוב מאוד! המשך ללמוד!' : 'Very good! Keep learning!';
      emoji = '🎼';
    } else {
      message = _isHebrew ? 'נסה שוב! תרגול עושה את השלמות!' : 'Try again! Practice makes perfect!';
      emoji = '🎶';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          _isHebrew ? 'סיימת!' : 'Finished!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: 80),
            ),
            SizedBox(height: 16),
            Text(
              '$_score/10',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentQuestion = 0;
                _score = 0;
                _answered = false;
                _selectedAnswer = null;
                _isCorrect = null;
              });
              _generateQuestion();
            },
            child: Text(_isHebrew ? 'שחק שוב' : 'Play Again', style: TextStyle(fontSize: 18)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(_isHebrew ? 'חזור לתפריט' : 'Back to Menu', style: TextStyle(fontSize: 18)),
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
              Colors.blue.shade50,
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
                        color: Colors.blue.shade700,
                        size: 32,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        _isHebrew ? 'חידון תווים' : 'Notes Quiz',
                        style: TextStyle(
                          fontSize: responsive.titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
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
                      '${_isHebrew ? 'שאלה' : 'Question'} ${_currentQuestion + 1}/10',
                      style: TextStyle(
                        fontSize: responsive.fontSize(18),
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
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
                        color: Colors.blue.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    _isHebrew
                        ? 'איפה ${_correctNote['nameHe']}?'
                        : 'Where is ${_correctNote['nameEn']}?',
                    style: TextStyle(
                      fontSize: responsive.fontSize(24),
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
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

              // Repeat question button
              Padding(
                padding: const EdgeInsets.all(16),
                child: KidButton(
                  text: _isHebrew ? 'שמע שוב את השאלה 🔊' : 'Hear Question Again 🔊',
                  icon: Icons.volume_up,
                  onPressed: _speakQuestion,
                  color: Colors.green,
                  height: 60,
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

    Color borderColor = Colors.blue.shade200;
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
            // Colored circle with note letter
            Flexible(
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: option['color'],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: option['color'].withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    option['letter']!,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                _isHebrew ? option['nameHe']! : option['nameEn']!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.lerp(option['color'], Colors.black, 0.4)!,
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
