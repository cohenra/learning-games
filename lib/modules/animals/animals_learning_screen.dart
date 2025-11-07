import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';

/// מסך למידת בעלי חיים - מציג בעל חיים אחד בכל פעם
class AnimalsLearningScreen extends StatefulWidget {
  const AnimalsLearningScreen({super.key});

  @override
  State<AnimalsLearningScreen> createState() => _AnimalsLearningScreenState();
}

class _AnimalsLearningScreenState extends State<AnimalsLearningScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  bool _isHebrew = true;

  // 12 בעלי חיים
  final List<Map<String, String>> _animals = [
    {'emoji': '🐕', 'nameHe': 'כלב', 'nameEn': 'Dog', 'soundHe': 'הב הב', 'soundEn': 'Woof'},
    {'emoji': '🐈', 'nameHe': 'חתול', 'nameEn': 'Cat', 'soundHe': 'מיאו', 'soundEn': 'Meow'},
    {'emoji': '🐰', 'nameHe': 'ארנב', 'nameEn': 'Rabbit', 'soundHe': '', 'soundEn': ''},
    {'emoji': '🐘', 'nameHe': 'פיל', 'nameEn': 'Elephant', 'soundHe': '', 'soundEn': 'Trumpet'},
    {'emoji': '🦁', 'nameHe': 'אריה', 'nameEn': 'Lion', 'soundHe': 'שאגה', 'soundEn': 'Roar'},
    {'emoji': '🐄', 'nameHe': 'פרה', 'nameEn': 'Cow', 'soundHe': 'מו', 'soundEn': 'Moo'},
    {'emoji': '🐴', 'nameHe': 'סוס', 'nameEn': 'Horse', 'soundHe': 'צהלה', 'soundEn': 'Neigh'},
    {'emoji': '🐦', 'nameHe': 'ציפור', 'nameEn': 'Bird', 'soundHe': 'ציוץ', 'soundEn': 'Tweet'},
    {'emoji': '🐟', 'nameHe': 'דג', 'nameEn': 'Fish', 'soundHe': '', 'soundEn': ''},
    {'emoji': '🐻', 'nameHe': 'דוב', 'nameEn': 'Bear', 'soundHe': 'שאגה', 'soundEn': 'Growl'},
    {'emoji': '🐵', 'nameHe': 'קוף', 'nameEn': 'Monkey', 'soundHe': 'אהאה', 'soundEn': 'Ooh ooh'},
    {'emoji': '🐢', 'nameHe': 'צב', 'nameEn': 'Turtle', 'soundHe': '', 'soundEn': ''},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isHebrew = Localizations.localeOf(context).languageCode == 'he';
      });
      _speakCurrent();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _speakCurrent() {
    final appProvider = context.read<AppProvider>();
    final name = _isHebrew
        ? _animals[_currentIndex]['nameHe']!
        : _animals[_currentIndex]['nameEn']!;
    appProvider.speak(name);
  }

  void _goToNext() {
    if (_currentIndex < _animals.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _animationController.reset();
      _animationController.forward();
      _speakCurrent();
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _animationController.reset();
      _animationController.forward();
      _speakCurrent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final current = _animals[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(_isHebrew ? 'למידה 📚' : 'Learning 📚'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50,
              Colors.blue.shade50,
              Colors.yellow.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_currentIndex + 1}/${_animals.length}',
                      style: TextStyle(
                        fontSize: responsive.fontSize(24),
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Animal display
              Expanded(
                child: Center(
                  child: FadeTransition(
                    opacity: _animationController,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animal emoji
                        Text(
                          current['emoji']!,
                          style: TextStyle(fontSize: responsive.fontSize(180)),
                        ),
                        const SizedBox(height: 30),

                        // Animal name
                        Text(
                          _isHebrew ? current['nameHe']! : current['nameEn']!,
                          style: TextStyle(
                            fontSize: responsive.fontSize(48),
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),

                        // Animal sound (if exists)
                        if ((_isHebrew && current['soundHe']!.isNotEmpty) ||
                            (!_isHebrew && current['soundEn']!.isNotEmpty))
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              _isHebrew ? current['soundHe']! : current['soundEn']!,
                              style: TextStyle(
                                fontSize: responsive.fontSize(28),
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
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
                    KidButton(
                      text: _isHebrew ? 'הקודם' : 'Previous',
                      icon: _isHebrew ? Icons.arrow_forward : Icons.arrow_back,
                      onPressed: _currentIndex > 0 ? _goToPrevious : null,
                      color: _currentIndex > 0 ? Colors.blue : Colors.grey,
                      width: responsive.width(35),
                      height: 60,
                    ),

                    // Repeat button
                    KidButton(
                      text: _isHebrew ? 'שמע שוב 🔊' : 'Hear Again 🔊',
                      icon: Icons.volume_up,
                      onPressed: _speakCurrent,
                      color: Colors.green,
                      width: responsive.width(35),
                      height: 60,
                    ),

                    // Next button
                    KidButton(
                      text: _isHebrew ? 'הבא' : 'Next',
                      icon: _isHebrew ? Icons.arrow_back : Icons.arrow_forward,
                      onPressed: _currentIndex < _animals.length - 1 ? _goToNext : null,
                      color: _currentIndex < _animals.length - 1 ? Colors.orange : Colors.grey,
                      width: responsive.width(35),
                      height: 60,
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
