import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';

/// מסך למידת כלי נגינה
class InstrumentsLearningScreen extends StatefulWidget {
  const InstrumentsLearningScreen({super.key});

  @override
  State<InstrumentsLearningScreen> createState() => _InstrumentsLearningScreenState();
}

class _InstrumentsLearningScreenState extends State<InstrumentsLearningScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  int _currentIndex = 0;

  final List<Map<String, String>> _instruments = [
    {
      'emoji': '🎸',
      'nameHe': 'גיטרה',
      'nameEn': 'Guitar',
      'descHe': 'כלי מיתר פופולרי עם 6 מיתרים',
      'descEn': 'Popular string instrument with 6 strings'
    },
    {
      'emoji': '🎹',
      'nameHe': 'פסנתר',
      'nameEn': 'Piano',
      'descHe': 'כלי מקלדת עם מקשים לבנים ושחורים',
      'descEn': 'Keyboard instrument with white and black keys'
    },
    {
      'emoji': '🥁',
      'nameHe': 'תוף',
      'nameEn': 'Drum',
      'descHe': 'כלי הקשה שמשמיע קצבים',
      'descEn': 'Percussion instrument that makes rhythms'
    },
    {
      'emoji': '🎺',
      'nameHe': 'חצוצרה',
      'nameEn': 'Trumpet',
      'descHe': 'כלי נשיפה נחושת בעל צליל חזק',
      'descEn': 'Brass wind instrument with loud sound'
    },
    {
      'emoji': '🎻',
      'nameHe': 'כינור',
      'nameEn': 'Violin',
      'descHe': 'כלי מיתר קטן שמנגנים עליו עם קשת',
      'descEn': 'Small string instrument played with a bow'
    },
    {
      'emoji': '🎷',
      'nameHe': 'סקסופון',
      'nameEn': 'Saxophone',
      'descHe': 'כלי נשיפה מתכתי בעל צליל ג\'אזי',
      'descEn': 'Metal wind instrument with jazzy sound'
    },
    {
      'emoji': '🪕',
      'nameHe': 'בנג\'ו',
      'nameEn': 'Banjo',
      'descHe': 'כלי מיתר עם גוף עגול',
      'descEn': 'String instrument with round body'
    },
    {
      'emoji': '🪗',
      'nameHe': 'אקורדיון',
      'nameEn': 'Accordion',
      'descHe': 'כלי נשיפה שמושכים ודוחפים',
      'descEn': 'Wind instrument that you push and pull'
    },
    {
      'emoji': '🎤',
      'nameHe': 'מיקרופון',
      'nameEn': 'Microphone',
      'descHe': 'מכשיר שמגביר את הקול',
      'descEn': 'Device that amplifies voice'
    },
    {
      'emoji': '🪘',
      'nameHe': 'תוף עם מקלות',
      'nameEn': 'Drum with Sticks',
      'descHe': 'תוף שמנגנים עליו במקלות',
      'descEn': 'Drum played with sticks'
    },
    {
      'emoji': '🎼',
      'nameHe': 'תווים',
      'nameEn': 'Musical Notes',
      'descHe': 'סימנים שמייצגים מוזיקה',
      'descEn': 'Symbols that represent music'
    },
    {
      'emoji': '🔔',
      'nameHe': 'פעמון',
      'nameEn': 'Bell',
      'descHe': 'כלי הקשה שמצלצל',
      'descEn': 'Percussion instrument that rings'
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
    final instrument = _instruments[_currentIndex];
    final text = _isHebrew ? instrument['nameHe']! : instrument['nameEn']!;
    final lang = _isHebrew ? 'he-IL' : 'en-US';

    await _flutterTts.setLanguage(lang);
    await _flutterTts.speak(text);
  }

  void _goToNext() {
    if (_currentIndex < _instruments.length - 1) {
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

    final currentInstrument = _instruments[_currentIndex];

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
              // Header with back button
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
                        _isHebrew ? 'כלי נגינה' : 'Musical Instruments',
                        style: TextStyle(
                          fontSize: responsive.titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48), // Balance
                  ],
                ),
              ),

              SizedBox(height: responsive.spacing(20)),

              // Progress indicator
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_currentIndex + 1} / ${_instruments.length}',
                      style: TextStyle(
                        fontSize: responsive.fontSize(18),
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: responsive.spacing(30)),

              // Instrument display
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Emoji
                      Text(
                        currentInstrument['emoji']!,
                        style: TextStyle(fontSize: responsive.iconSize(120)),
                      ),

                      SizedBox(height: responsive.spacing(24)),

                      // Name
                      Text(
                        _isHebrew
                            ? currentInstrument['nameHe']!
                            : currentInstrument['nameEn']!,
                        style: TextStyle(
                          fontSize: responsive.fontSize(36),
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: responsive.spacing(16)),

                      // Description
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: responsive.spacing(32)),
                        child: Text(
                          _isHebrew
                              ? currentInstrument['descHe']!
                              : currentInstrument['descEn']!,
                          style: TextStyle(
                            fontSize: responsive.fontSize(18),
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Previous button
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: KidButton(
                          text: _isHebrew ? 'הקודם' : 'Previous',
                          icon: _isHebrew ? Icons.arrow_forward : Icons.arrow_back,
                          onPressed: _currentIndex > 0 ? _goToPrevious : null,
                          color: _currentIndex > 0 ? Colors.blue : Colors.grey,
                          height: 60,
                        ),
                      ),
                    ),

                    // Repeat button
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: KidButton(
                          text: _isHebrew ? 'שמע שוב 🔊' : 'Hear Again 🔊',
                          icon: Icons.volume_up,
                          onPressed: _speakCurrent,
                          color: Colors.green,
                          height: 60,
                        ),
                      ),
                    ),

                    // Next button
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: KidButton(
                          text: _isHebrew ? 'הבא' : 'Next',
                          icon: _isHebrew ? Icons.arrow_back : Icons.arrow_forward,
                          onPressed: _currentIndex < _instruments.length - 1 ? _goToNext : null,
                          color: _currentIndex < _instruments.length - 1 ? Colors.orange : Colors.grey,
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
}
