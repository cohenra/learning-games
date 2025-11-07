import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';

/// מסך זמן למידה של פירות וירקות
class FruitsVegetablesLearningScreen extends StatefulWidget {
  const FruitsVegetablesLearningScreen({super.key});

  @override
  State<FruitsVegetablesLearningScreen> createState() =>
      _FruitsVegetablesLearningScreenState();
}

class _FruitsVegetablesLearningScreenState
    extends State<FruitsVegetablesLearningScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  int _currentIndex = 0;

  final List<Map<String, String>> _items = [
    // Fruits
    {
      'emoji': '🍎',
      'nameHe': 'תפוח',
      'nameEn': 'Apple',
      'descHe': 'פרי מתוק ועסיסי באדום או ירוק',
      'descEn': 'A sweet, juicy fruit in red or green',
      'type': 'fruit',
    },
    {
      'emoji': '🍌',
      'nameHe': 'בננה',
      'nameEn': 'Banana',
      'descHe': 'פרי צהוב וארוך עם קליפה',
      'descEn': 'A yellow, long fruit with a peel',
      'type': 'fruit',
    },
    {
      'emoji': '🍊',
      'nameHe': 'תפוז',
      'nameEn': 'Orange',
      'descHe': 'פרי הדר עגול וכתום',
      'descEn': 'A round, orange citrus fruit',
      'type': 'fruit',
    },
    {
      'emoji': '🍇',
      'nameHe': 'ענבים',
      'nameEn': 'Grapes',
      'descHe': 'פירות קטנים וסגולים באשכול',
      'descEn': 'Small purple berries in a bunch',
      'type': 'fruit',
    },
    {
      'emoji': '🍓',
      'nameHe': 'תות',
      'nameEn': 'Strawberry',
      'descHe': 'פרי אדום עם זרעים בחוץ',
      'descEn': 'A red fruit with seeds on the outside',
      'type': 'fruit',
    },
    {
      'emoji': '🍉',
      'nameHe': 'אבטיח',
      'nameEn': 'Watermelon',
      'descHe': 'פרי גדול וירוק עם בשר אדום',
      'descEn': 'A large green fruit with red flesh',
      'type': 'fruit',
    },
    {
      'emoji': '🍑',
      'nameHe': 'אפרסק',
      'nameEn': 'Peach',
      'descHe': 'פרי עגול וקטיפתי בצבע כתום',
      'descEn': 'A round, fuzzy orange fruit',
      'type': 'fruit',
    },
    {
      'emoji': '🍋',
      'nameHe': 'לימון',
      'nameEn': 'Lemon',
      'descHe': 'פרי הדר צהוב וחמוץ',
      'descEn': 'A yellow, sour citrus fruit',
      'type': 'fruit',
    },
    // Vegetables
    {
      'emoji': '🥕',
      'nameHe': 'גזר',
      'nameEn': 'Carrot',
      'descHe': 'ירק כתום וארוך שגדל באדמה',
      'descEn': 'A long orange vegetable that grows in the ground',
      'type': 'vegetable',
    },
    {
      'emoji': '🥔',
      'nameHe': 'תפוח אדמה',
      'nameEn': 'Potato',
      'descHe': 'ירק חום שגדל מתחת לאדמה',
      'descEn': 'A brown vegetable that grows underground',
      'type': 'vegetable',
    },
    {
      'emoji': '🍅',
      'nameHe': 'עגבנייה',
      'nameEn': 'Tomato',
      'descHe': 'ירק אדום ועגול ועסיסי',
      'descEn': 'A red, round, juicy vegetable',
      'type': 'vegetable',
    },
    {
      'emoji': '🥒',
      'nameHe': 'מלפפון',
      'nameEn': 'Cucumber',
      'descHe': 'ירק ירוק וארוך עם קליפה',
      'descEn': 'A long green vegetable with skin',
      'type': 'vegetable',
    },
    {
      'emoji': '🌽',
      'nameHe': 'תירס',
      'nameEn': 'Corn',
      'descHe': 'ירק צהוב עם גרגירים על קלח',
      'descEn': 'A yellow vegetable with kernels on a cob',
      'type': 'vegetable',
    },
    {
      'emoji': '🥦',
      'nameHe': 'ברוקולי',
      'nameEn': 'Broccoli',
      'descHe': 'ירק ירוק שנראה כמו עץ קטן',
      'descEn': 'A green vegetable that looks like a small tree',
      'type': 'vegetable',
    },
    {
      'emoji': '🥬',
      'nameHe': 'חסה',
      'nameEn': 'Lettuce',
      'descHe': 'עלים ירוקים לסלט',
      'descEn': 'Green leaves for salad',
      'type': 'vegetable',
    },
    {
      'emoji': '🧅',
      'nameHe': 'בצל',
      'nameEn': 'Onion',
      'descHe': 'ירק עגול בעל ריח חזק',
      'descEn': 'A round vegetable with a strong smell',
      'type': 'vegetable',
    },
  ];

  bool _isHebrew = true;

  @override
  void initState() {
    super.initState();
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isHebrew = Localizations.localeOf(context).languageCode == 'he';
      });
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
    final text = _isHebrew ? item['nameHe']! : item['nameEn']!;
    final lang = _isHebrew ? 'he-IL' : 'en-US';

    await _flutterTts.setLanguage(lang);
    await _flutterTts.speak(text);
  }

  void _goToNext() {
    if (_currentIndex < _items.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _speakCurrent();
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
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
    final isFruit = currentItem['type'] == 'fruit';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isFruit
                ? [
                    Colors.orange.shade100,
                    Colors.red.shade100,
                  ]
                : [
                    Colors.green.shade100,
                    Colors.lightGreen.shade100,
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
                        color: Colors.green.shade700,
                        size: 32,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        _isHebrew ? 'זמן למידה' : 'Learning Time',
                        style: TextStyle(
                          fontSize: responsive.titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
              ),

              // Progress indicator
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _items.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentIndex
                            ? Colors.green
                            : Colors.green.shade200,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: responsive.spacing(20)),

              // Main content
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Item emoji
                      Text(
                        currentItem['emoji']!,
                        style: TextStyle(fontSize: responsive.fontSize(150)),
                      ),

                      SizedBox(height: responsive.spacing(20)),

                      // Item name
                      Text(
                        _isHebrew
                            ? currentItem['nameHe']!
                            : currentItem['nameEn']!,
                        style: TextStyle(
                          fontSize: responsive.fontSize(36),
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: responsive.spacing(12)),

                      // Item description
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: responsive.spacing(40)),
                        child: Text(
                          _isHebrew
                              ? currentItem['descHe']!
                              : currentItem['descEn']!,
                          style: TextStyle(
                            fontSize: responsive.fontSize(20),
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Previous button
                    Expanded(
                      child: KidButton(
                        text: _isHebrew ? 'הקודם' : 'Previous',
                        icon: _isHebrew ? Icons.arrow_forward : Icons.arrow_back,
                        onPressed: _currentIndex > 0 ? _goToPrevious : null,
                        color: Colors.orange,
                        height: 60,
                      ),
                    ),
                    SizedBox(width: 12),
                    // Repeat button
                    Expanded(
                      child: KidButton(
                        text: _isHebrew ? 'שמע שוב' : 'Repeat',
                        icon: Icons.volume_up,
                        onPressed: _speakCurrent,
                        color: Colors.blue,
                        height: 60,
                      ),
                    ),
                    SizedBox(width: 12),
                    // Next button
                    Expanded(
                      child: KidButton(
                        text: _isHebrew ? 'הבא' : 'Next',
                        icon: _isHebrew ? Icons.arrow_back : Icons.arrow_forward,
                        onPressed: _currentIndex < _items.length - 1 ? _goToNext : null,
                        color: Colors.green,
                        height: 60,
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
}
