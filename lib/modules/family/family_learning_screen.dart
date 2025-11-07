import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../widgets/kid_button.dart';
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
    {'emoji': '👨', 'nameHe': 'אבא', 'nameEn': 'Father'},
    {'emoji': '👩', 'nameHe': 'אמא', 'nameEn': 'Mother'},
    {'emoji': '👦', 'nameHe': 'אח', 'nameEn': 'Brother'},
    {'emoji': '👧', 'nameHe': 'אחות', 'nameEn': 'Sister'},
    {'emoji': '👴', 'nameHe': 'סבא', 'nameEn': 'Grandfather'},
    {'emoji': '👵', 'nameHe': 'סבתא', 'nameEn': 'Grandmother'},
    {'emoji': '🚌', 'nameHe': 'אוטובוס', 'nameEn': 'Bus', 'descHe': 'משפחה גדול להרבה אנשים', 'descEn': 'A large vehicle for many people'},
    {'emoji': '🚕', 'nameHe': 'מונית', 'nameEn': 'Taxi', 'descHe': 'מכונית צהובה שנוסעת תמורת תשלום', 'descEn': 'A yellow car for hire'},
    {'emoji': '🚙', 'nameHe': 'ג\'יפ', 'nameEn': 'SUV', 'descHe': 'רכב שטח גדול וחזק', 'descEn': 'A large and strong off-road vehicle'},
    {'emoji': '🚐', 'nameHe': 'מיניבוס', 'nameEn': 'Van', 'descHe': 'רכב קטן להסעת נוסעים', 'descEn': 'A small vehicle for transporting passengers'},
    {'emoji': '🏍️', 'nameHe': 'אופנוע', 'nameEn': 'Motorcycle', 'descHe': 'משפחה על שני גלגלים', 'descEn': 'A two-wheeled vehicle'},
    {'emoji': '🚲', 'nameHe': 'אופניים', 'nameEn': 'Bicycle', 'descHe': 'משפחה שמניעים ברגליים', 'descEn': 'A vehicle powered by pedaling'},
    {'emoji': '🛴', 'nameHe': 'קורקינט', 'nameEn': 'Scooter', 'descHe': 'לוח עם גלגלים לנסיעה', 'descEn': 'A board with wheels for riding'},
    {'emoji': '✈️', 'nameHe': 'מטוס', 'nameEn': 'Airplane', 'descHe': 'משפחה שטס באוויר', 'descEn': 'A vehicle that flies in the air'},
    {'emoji': '🚁', 'nameHe': 'מסוק', 'nameEn': 'Helicopter', 'descHe': 'משפחה עם להבים מסתובבים', 'descEn': 'A vehicle with rotating blades'},
    {'emoji': '🚂', 'nameHe': 'רכבת', 'nameEn': 'Train', 'descHe': 'משפחה על פסי רכבת', 'descEn': 'A vehicle on railway tracks'},
    {'emoji': '🚆', 'nameHe': 'רכבת קלה', 'nameEn': 'Light Rail', 'descHe': 'רכבת עירונית מהירה', 'descEn': 'A fast urban train'},
    {'emoji': '🚊', 'nameHe': 'חשמלית', 'nameEn': 'Tram', 'descHe': 'רכבת על פסים ברחובות', 'descEn': 'A train on tracks in the streets'},
    {'emoji': '⛵', 'nameHe': 'סירה', 'nameEn': 'Boat', 'descHe': 'כלי שיט קטן על המים', 'descEn': 'A small watercraft'},
    {'emoji': '🚢', 'nameHe': 'אנייה', 'nameEn': 'Ship', 'descHe': 'כלי שיט גדול על הים', 'descEn': 'A large watercraft on the sea'},
    {'emoji': '🚤', 'nameHe': 'סירת מנוע', 'nameEn': 'Speedboat', 'descHe': 'סירה מהירה עם מנוע', 'descEn': 'A fast boat with an engine'},
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
                child: Row(
                  children: [
                    IconButton(icon: Icon(_isHebrew ? Icons.arrow_forward : Icons.arrow_back, color: Colors.deepOrange.shade700, size: 32), onPressed: () => Navigator.pop(context)),
                    Expanded(child: Text(_isHebrew ? 'זמן למידה' : 'Learning Time', style: TextStyle(fontSize: responsive.titleSize, fontWeight: FontWeight.bold, color: Colors.deepOrange.shade700), textAlign: TextAlign.center)),
                    SizedBox(width: 48),
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
