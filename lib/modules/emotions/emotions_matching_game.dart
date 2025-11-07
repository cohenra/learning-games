import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';

class EmotionsMatchingGame extends StatefulWidget {
  const EmotionsMatchingGame({super.key});

  @override
  State<EmotionsMatchingGame> createState() => _EmotionsMatchingGameState();
}

class _EmotionsMatchingGameState extends State<EmotionsMatchingGame> {
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();

  final List<Map<String, String>> _allItems = [
    {'emoji': '😊', 'nameHe': 'שמח', 'nameEn': 'Happy'},
    {'emoji': '😢', 'nameHe': 'עצוב', 'nameEn': 'Sad'},
    {'emoji': '😠', 'nameHe': 'כועס', 'nameEn': 'Angry'},
    {'emoji': '😨', 'nameHe': 'מפוחד', 'nameEn': 'Scared'},
    {'emoji': '😴', 'nameHe': 'עייף', 'nameEn': 'Tired'},
    {'emoji': '🤗', 'nameHe': 'מאוהב', 'nameEn': 'Loving'},
    {'emoji': '😮', 'nameHe': 'מופתע', 'nameEn': 'Surprised'},
    {'emoji': '🤔', 'nameHe': 'חושב', 'nameEn': 'Thinking'},
  ];

  List<Map<String, dynamic>> _options = [];
  late Map<String, String> _correctItem;
  int? _selectedIndex;
  bool _answered = false;
  bool? _isCorrect;
  int _score = 0;
  int _currentQuestion = 0;
  final int _totalQuestions = 10;
  bool _isHebrew = true;

  @override
  void initState() {
    super.initState();
    _initTts();
    _generateQuestion();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _isHebrew = Localizations.localeOf(context).languageCode == 'he');
      _speakQuestion();
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setPitch(1.0);
  }

  void _generateQuestion() {
    _correctItem = _allItems[_random.nextInt(_allItems.length)];
    List<Map<String, String>> wrongOptions = List.from(_allItems);
    wrongOptions.removeWhere((item) => item['emoji'] == _correctItem['emoji']);
    wrongOptions.shuffle(_random);
    final selectedWrong = wrongOptions.take(3).toList();
    _options = [_correctItem, ...selectedWrong].map((item) => Map<String, dynamic>.from(item)).toList();
    _options.shuffle(_random);
    _selectedIndex = null;
    _answered = false;
    _isCorrect = null;
  }

  Future<void> _speakQuestion() async {
    final lang = _isHebrew ? 'he-IL' : 'en-US';
    await _flutterTts.setLanguage(lang);
    await _flutterTts.speak(_isHebrew ? _correctItem['nameHe']! : _correctItem['nameEn']!);
  }

  void _checkAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedIndex = index;
      _answered = true;
      _isCorrect = _options[index]['emoji'] == _correctItem['emoji'];
      if (_isCorrect!) _score += 10;
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_currentQuestion < _totalQuestions - 1) {
        setState(() => _currentQuestion++);
        _generateQuestion();
        _speakQuestion();
      } else {
        _showResults();
      }
    });
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_isHebrew ? 'כל הכבוד!' : 'Well Done!', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_isHebrew ? 'הניקוד שלך: $_score/${_totalQuestions * 10}' : 'Your Score: $_score/${_totalQuestions * 10}', style: const TextStyle(fontSize: 24), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Text(_score >= 70 ? (_isHebrew ? '🎉 מעולה!' : '🎉 Excellent!') : (_isHebrew ? '💪 נסה שוב!' : '💪 Try Again!'), style: const TextStyle(fontSize: 32), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); setState(() { _score = 0; _currentQuestion = 0; _generateQuestion(); _speakQuestion(); }); }, child: Text(_isHebrew ? 'שחק שוב' : 'Play Again')),
          TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: Text(_isHebrew ? 'חזור' : 'Back')),
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
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.amber.shade100, Colors.amber.shade100])),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(responsive.spacing(12)),
                child: Row(
                  children: [
                    IconButton(icon: Icon(_isHebrew ? Icons.arrow_forward : Icons.arrow_back, color: Colors.amber.shade700, size: 32), onPressed: () => Navigator.pop(context)),
                    Expanded(child: Text(_isHebrew ? 'משחק התאמה' : 'Matching Game', style: TextStyle(fontSize: responsive.titleSize, fontWeight: FontWeight.bold, color: Colors.amber.shade700), textAlign: TextAlign.center)),
                    SizedBox(width: 48),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)), child: Text('${_isHebrew ? 'שאלה' : 'Question'} ${_currentQuestion + 1}/$_totalQuestions', style: TextStyle(fontSize: responsive.fontSize(18), fontWeight: FontWeight.bold, color: Colors.white))),
                    Container(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)), child: Text('${_isHebrew ? 'ניקוד' : 'Score'}: $_score', style: TextStyle(fontSize: responsive.fontSize(18), fontWeight: FontWeight.bold, color: Colors.white))),
                  ],
                ),
              ),
              SizedBox(height: responsive.spacing(20)),
              Container(
                margin: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]),
                child: Column(
                  children: [
                    Text(_isHebrew ? 'איפה ה...' : 'Where is the...', style: TextStyle(fontSize: responsive.fontSize(22), color: Colors.grey.shade700)),
                    const SizedBox(height: 8),
                    Text(_isHebrew ? _correctItem['nameHe']! : _correctItem['nameEn']!, style: TextStyle(fontSize: responsive.fontSize(32), fontWeight: FontWeight.bold, color: Colors.amber.shade700)),
                  ],
                ),
              ),
              SizedBox(height: responsive.spacing(20)),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final buttonHeight = ((constraints.maxHeight - 20) / 2).clamp(80.0, 150.0);
                    final aspectRatio = (constraints.maxWidth / 2 - 20) / buttonHeight;
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: aspectRatio),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _options.length,
                      itemBuilder: (context, index) {
                        final option = _options[index];
                        final isSelected = _selectedIndex == index;
                        final isCorrectOption = option['emoji'] == _correctItem['emoji'];
                        Color borderColor = Colors.amber.shade200;
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
                            decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor, width: 3), boxShadow: [BoxShadow(color: borderColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  flex: 3,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Text(
                                      option['emoji']!,
                                      style: const TextStyle(fontSize: 80),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Flexible(
                                  flex: 1,
                                  child: Text(
                                    _isHebrew ? option['nameHe']! : option['nameEn']!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber.shade700,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isSelected && _isCorrect!)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Icon(Icons.check_circle, color: Colors.green, size: 32),
                                  ),
                                if (isSelected && !_isCorrect!)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Icon(Icons.cancel, color: Colors.red, size: 32),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(padding: const EdgeInsets.all(16), child: KidButton(text: _isHebrew ? 'שמע שוב את השאלה 🔊' : 'Hear Question Again 🔊', icon: Icons.volume_up, onPressed: _speakQuestion, color: Colors.amber, height: 60)),
            ],
          ),
        ),
      ),
    );
  }
}
