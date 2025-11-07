import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';

class BodyPartsLearningScreen extends StatefulWidget {
  const BodyPartsLearningScreen({super.key});

  @override
  State<BodyPartsLearningScreen> createState() => _BodyPartsLearningScreenState();
}

class _BodyPartsLearningScreenState extends State<BodyPartsLearningScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  int _currentIndex = 0;

  final List<Map<String, String>> _items = [
    {'emoji': '👁️', 'nameHe': 'עין', 'nameEn': 'Eye', 'descHe': 'איבר הראייה', 'descEn': 'Organ of sight'},
    {'emoji': '👂', 'nameHe': 'אוזן', 'nameEn': 'Ear', 'descHe': 'איבר השמיעה', 'descEn': 'Organ of hearing'},
    {'emoji': '👃', 'nameHe': 'אף', 'nameEn': 'Nose', 'descHe': 'איבר הריח', 'descEn': 'Organ of smell'},
    {'emoji': '👄', 'nameHe': 'פה', 'nameEn': 'Mouth', 'descHe': 'לאכילה ולדיבור', 'descEn': 'For eating and talking'},
    {'emoji': '🦷', 'nameHe': 'שן', 'nameEn': 'Tooth', 'descHe': 'ללעוס אוכל', 'descEn': 'To chew food'},
    {'emoji': '👅', 'nameHe': 'לשון', 'nameEn': 'Tongue', 'descHe': 'לטעום ולדבר', 'descEn': 'To taste and speak'},
    {'emoji': '🫀', 'nameHe': 'לב', 'nameEn': 'Heart', 'descHe': 'שואב דם', 'descEn': 'Pumps blood'},
    {'emoji': '🫁', 'nameHe': 'ריאות', 'nameEn': 'Lungs', 'descHe': 'לנשימה', 'descEn': 'For breathing'},
    {'emoji': '✋', 'nameHe': 'יד', 'nameEn': 'Hand', 'descHe': 'לאחיזה ומגע', 'descEn': 'For gripping and touching'},
    {'emoji': '🦵', 'nameHe': 'רגל', 'nameEn': 'Leg', 'descHe': 'להליכה וריצה', 'descEn': 'For walking and running'},
    {'emoji': '🦶', 'nameHe': 'כף רגל', 'nameEn': 'Foot', 'descHe': 'לעמוד וללכת', 'descEn': 'To stand and walk'},
    {'emoji': '👃', 'nameHe': 'ראש', 'nameEn': 'Head', 'descHe': 'המוח נמצא בו', 'descEn': 'Contains the brain'},
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
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.pink.shade100, Colors.purple.shade100])),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(responsive.spacing(12)),
                child: Row(
                  children: [
                    IconButton(icon: Icon(_isHebrew ? Icons.arrow_forward : Icons.arrow_back, color: Colors.pink.shade700, size: 32), onPressed: () => Navigator.pop(context)),
                    Expanded(child: Text(_isHebrew ? 'זמן למידה' : 'Learning Time', style: TextStyle(fontSize: responsive.titleSize, fontWeight: FontWeight.bold, color: Colors.pink.shade700), textAlign: TextAlign.center)),
                    SizedBox(width: 48),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_items.length, (index) => Container(margin: const EdgeInsets.symmetric(horizontal: 2), width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: index == _currentIndex ? Colors.pink : Colors.pink.shade200))))),
              SizedBox(height: responsive.spacing(20)),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(currentItem['emoji']!, style: TextStyle(fontSize: responsive.fontSize(150))),
                      SizedBox(height: responsive.spacing(20)),
                      Text(_isHebrew ? currentItem['nameHe']! : currentItem['nameEn']!, style: TextStyle(fontSize: responsive.fontSize(36), fontWeight: FontWeight.bold, color: Colors.pink.shade800), textAlign: TextAlign.center),
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
                    Expanded(child: KidButton(text: _isHebrew ? 'שמע שוב' : 'Repeat', icon: Icons.volume_up, onPressed: _speakCurrent, color: Colors.pink, height: 60)),
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
