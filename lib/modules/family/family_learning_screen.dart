import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../widgets/kid_button.dart';
import '../../widgets/kid_back_button.dart';
import '../../utils/responsive_helper.dart';

class FamilyLearningScreen extends StatefulWidget {
  const FamilyLearningScreen({super.key});

  @override
  State<FamilyLearningScreen> createState() => _FamilyLearningScreenState();
}

class _FamilyLearningScreenState extends State<FamilyLearningScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  int _currentIndex = 0;

  final List<Map<String, String>> _items = [
    {'emoji': '👨', 'nameHe': 'אבא', 'nameEn': 'Father', 'descHe': 'ההורה הגבר', 'descEn': 'The male parent'},
    {'emoji': '👩', 'nameHe': 'אמא', 'nameEn': 'Mother', 'descHe': 'ההורה האישה', 'descEn': 'The female parent'},
    {'emoji': '👦', 'nameHe': 'אח', 'nameEn': 'Brother', 'descHe': 'הבן של אמא ואבא', 'descEn': 'The son of mom and dad'},
    {'emoji': '👧', 'nameHe': 'אחות', 'nameEn': 'Sister', 'descHe': 'הבת של אמא ואבא', 'descEn': 'The daughter of mom and dad'},
    {'emoji': '👴', 'nameHe': 'סבא', 'nameEn': 'Grandfather', 'descHe': 'אבא של אמא או אבא', 'descEn': 'Father of mom or dad'},
    {'emoji': '👵', 'nameHe': 'סבתא', 'nameEn': 'Grandmother', 'descHe': 'אמא של אמא או אבא', 'descEn': 'Mother of mom or dad'},
  ];

  bool _isHebrew = true;

  @override
  void initState() {
    super.initState();
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _isHebrew = Localizations.localeOf(context).languageCode == 'he');
      _speakCurrent();
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speakCurrent() async {
    final item = _items[_currentIndex];
    final lang = _isHebrew ? 'he-IL' : 'en-US';
    await _flutterTts.setLanguage(lang);
    await _flutterTts.speak(_isHebrew ? item['nameHe']! : item['nameEn']!);
  }

  void _goToNext() {
    if (_currentIndex < _items.length - 1) {
      setState(() => _currentIndex++);
      _speakCurrent();
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _speakCurrent();
    }
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
    final currentItem = _items[_currentIndex];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.deepOrange.shade100, Colors.deepOrange.shade100])),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(responsive.spacing(12)),
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: Text(
                          _isHebrew ? 'זמן למידה' : 'Learning Time',
                          style: TextStyle(
                            fontSize: responsive.titleSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Positioned(
                      right: _isHebrew ? 0 : null,
                      left: _isHebrew ? null : 0,
                      child: KidBackButton(
                        onPressed: () => Navigator.pop(context),
                        color: Colors.deepOrange.shade600,
                        isHebrew: _isHebrew,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_items.length, (index) => Container(margin: const EdgeInsets.symmetric(horizontal: 2), width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: index == _currentIndex ? Colors.deepOrange : Colors.deepOrange.shade200)))),
              ),
              SizedBox(height: responsive.spacing(20)),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(currentItem['emoji']!, style: TextStyle(fontSize: responsive.fontSize(150))),
                      SizedBox(height: responsive.spacing(20)),
                      Text(_isHebrew ? currentItem['nameHe']! : currentItem['nameEn']!, style: TextStyle(fontSize: responsive.fontSize(36), fontWeight: FontWeight.bold, color: Colors.deepOrange.shade800), textAlign: TextAlign.center),
                      SizedBox(height: responsive.spacing(12)),
                      Padding(padding: EdgeInsets.symmetric(horizontal: responsive.spacing(40)), child: Text(_isHebrew ? currentItem['descHe']! : currentItem['descEn']!, style: TextStyle(fontSize: responsive.fontSize(20), color: Colors.grey.shade700), textAlign: TextAlign.center)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(child: KidButton(text: _isHebrew ? 'הקודם' : 'Previous', icon: _isHebrew ? Icons.arrow_forward : Icons.arrow_back, onPressed: _currentIndex > 0 ? _goToPrevious : null, color: Colors.orange, height: 60)),
                    SizedBox(width: 12),
                    Expanded(child: KidButton(text: _isHebrew ? 'שמע שוב' : 'Repeat', icon: Icons.volume_up, onPressed: _speakCurrent, color: Colors.deepOrange, height: 60)),
                    SizedBox(width: 12),
                    Expanded(child: KidButton(text: _isHebrew ? 'הבא' : 'Next', icon: _isHebrew ? Icons.arrow_back : Icons.arrow_forward, onPressed: _currentIndex < _items.length - 1 ? _goToNext : null, color: Colors.green, height: 60)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
