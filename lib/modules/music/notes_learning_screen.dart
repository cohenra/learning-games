import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';

/// מסך למידת תווים מוזיקליים
class NotesLearningScreen extends StatefulWidget {
  const NotesLearningScreen({super.key});

  @override
  State<NotesLearningScreen> createState() => _NotesLearningScreenState();
}

class _NotesLearningScreenState extends State<NotesLearningScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  int _currentIndex = 0;

  final List<Map<String, String>> _notes = [
    {
      'emoji': '🎵',
      'nameHe': 'דו',
      'nameEn': 'Do',
      'letter': 'C',
      'colorName': 'אדום',
      'colorNameEn': 'Red',
      'ttsHe': 'דוֹ', // Phonetic with vowel mark
    },
    {
      'emoji': '🎶',
      'nameHe': 'רה',
      'nameEn': 'Re',
      'letter': 'D',
      'colorName': 'כתום',
      'colorNameEn': 'Orange',
      'ttsHe': 'רֶה', // Phonetic with vowel mark
    },
    {
      'emoji': '🎵',
      'nameHe': 'מי',
      'nameEn': 'Mi',
      'letter': 'E',
      'colorName': 'צהוב',
      'colorNameEn': 'Yellow',
      'ttsHe': 'מִי', // Phonetic with vowel mark
    },
    {
      'emoji': '🎶',
      'nameHe': 'פה',
      'nameEn': 'Fa',
      'letter': 'F',
      'colorName': 'ירוק',
      'colorNameEn': 'Green',
      'ttsHe': 'פָה', // Phonetic with vowel mark
    },
    {
      'emoji': '🎵',
      'nameHe': 'סול',
      'nameEn': 'Sol',
      'letter': 'G',
      'colorName': 'כחול',
      'colorNameEn': 'Blue',
      'ttsHe': 'סוֹל', // Phonetic with vowel mark
    },
    {
      'emoji': '🎶',
      'nameHe': 'לה',
      'nameEn': 'La',
      'letter': 'A',
      'colorName': 'סגול',
      'colorNameEn': 'Purple',
      'ttsHe': 'לָה', // Phonetic with vowel mark
    },
    {
      'emoji': '🎵',
      'nameHe': 'סי',
      'nameEn': 'Si',
      'letter': 'B',
      'colorName': 'ורוד',
      'colorNameEn': 'Pink',
      'ttsHe': 'סִי', // Phonetic with vowel mark
    },
  ];

  final List<Color> _noteColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
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
    final note = _notes[_currentIndex];
    final text = _isHebrew ? note['ttsHe']! : note['nameEn']!;
    final lang = _isHebrew ? 'he-IL' : 'en-US';

    await _flutterTts.setLanguage(lang);
    await _flutterTts.speak(text);
  }

  void _goToNext() {
    if (_currentIndex < _notes.length - 1) {
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

    final currentNote = _notes[_currentIndex];
    final currentColor = _noteColors[_currentIndex];

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
              // Header with back button
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
                        _isHebrew ? 'תווים מוזיקליים' : 'Musical Notes',
                        style: TextStyle(
                          fontSize: responsive.titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
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
                      '${_currentIndex + 1} / ${_notes.length}',
                      style: TextStyle(
                        fontSize: responsive.fontSize(18),
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: responsive.spacing(30)),

              // Note display
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Colored circle with note
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: currentColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: currentColor.withOpacity(0.5),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                currentNote['emoji']!,
                                style: TextStyle(fontSize: 60),
                              ),
                              Text(
                                currentNote['letter']!,
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: responsive.spacing(32)),

                      // Note name
                      Text(
                        _isHebrew
                            ? currentNote['nameHe']!
                            : currentNote['nameEn']!,
                        style: TextStyle(
                          fontSize: responsive.fontSize(48),
                          fontWeight: FontWeight.bold,
                          color: currentColor,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: responsive.spacing(16)),

                      // Letter
                      Text(
                        '(${currentNote['letter']})',
                        style: TextStyle(
                          fontSize: responsive.fontSize(28),
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: responsive.spacing(16)),

                      // Color name
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: currentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _isHebrew
                              ? currentNote['colorName']!
                              : currentNote['colorNameEn']!,
                          style: TextStyle(
                            fontSize: responsive.fontSize(20),
                            fontWeight: FontWeight.bold,
                            color: Color.lerp(currentColor, Colors.black, 0.4)!,
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
                          onPressed: _currentIndex < _notes.length - 1 ? _goToNext : null,
                          color: _currentIndex < _notes.length - 1 ? Colors.orange : Colors.grey,
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
