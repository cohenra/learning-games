import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame_audio/flame_audio.dart';
import '../data/hebrew_letters.dart';

/// משחק למידה אותיות - מציג אותיות אחת אחת
/// הילד יכול ללחוץ על האות כדי לשמוע אותה
/// ניתן לנווט קדימה/אחורה בין האותיות
///
/// מתאים לגילאי 2-6: עיצוב חמוד, צבעוני, וברור
class LearnLettersGame extends StatefulWidget {
  const LearnLettersGame({super.key});

  @override
  State<LearnLettersGame> createState() => _LearnLettersGameState();
}

class _LearnLettersGameState extends State<LearnLettersGame>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _soundEnabled = true;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;

  List<HebrewLetter> get letters => HebrewLettersData.basicLetters;
  HebrewLetter get currentLetter => letters[_currentIndex];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _preloadAudio();
  }

  void _initAnimations() {
    // אנימציית לחיצה (scale down/up)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // אנימציית נשימה (breathing effect)
    _breatheController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
  }

  Future<void> _preloadAudio() async {
    FlameAudio.audioCache.prefix = 'assets/audio/';
    // טעינת כל קבצי הסאונד של האותיות (יהיו צריכים להיווצר)
    try {
      for (final letter in letters) {
        await FlameAudio.audioCache.load('letters/${letter.key}.wav');
      }
    } catch (e) {
      debugPrint('שגיאה בטעינת קבצי אודיו: $e');
    }
  }

  Future<void> _playLetterSound() async {
    if (!_soundEnabled) return;
    try {
      await FlameAudio.play('letters/${currentLetter.key}.wav');
    } catch (e) {
      debugPrint('שגיאה בהשמעת קול האות: $e');
    }
  }

  void _onLetterTap() {
    HapticFeedback.mediumImpact();
    _scaleController.forward().then((_) => _scaleController.reverse());
    _playLetterSound();
  }

  void _goToNext() {
    if (_currentIndex < letters.length - 1) {
      setState(() => _currentIndex++);
      _playLetterSound();
      HapticFeedback.selectionClick();
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _playLetterSound();
      HapticFeedback.selectionClick();
    }
  }

  void _toggleSound() {
    setState(() => _soundEnabled = !_soundEnabled);
    HapticFeedback.selectionClick();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF), // רקע תכלת בהיר
      appBar: AppBar(
        title: const Text('לומדים אותיות', textDirection: TextDirection.rtl),
        backgroundColor: Colors.teal,
        actions: [
          // כפתור השתקה
          IconButton(
            icon: Icon(_soundEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: _toggleSound,
            tooltip: _soundEnabled ? 'השתק' : 'הפעל סאונד',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // מונה התקדמות
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'אות ${_currentIndex + 1} מתוך ${letters.length}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),

            // אינדיקטור התקדמות
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / letters.length,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(currentLetter.color),
                minHeight: 8,
              ),
            ),

            const SizedBox(height: 40),

            // האות הגדולה במרכז
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: _onLetterTap,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_scaleAnimation, _breatheAnimation]),
                    builder: (context, child) {
                      final scale = _scaleAnimation.value * _breatheAnimation.value;
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            color: currentLetter.color.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: currentLetter.color,
                              width: 6,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: currentLetter.color.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              currentLetter.letter,
                              style: TextStyle(
                                fontSize: 140,
                                fontWeight: FontWeight.bold,
                                color: currentLetter.color,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // שם האות
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    currentLetter.name,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: currentLetter.color,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'הקש על האות כדי לשמוע אותה',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // כפתורי ניווט
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // כפתור הקודם
                  ElevatedButton.icon(
                    onPressed: _currentIndex > 0 ? _goToPrevious : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_back, size: 28),
                    label: const Text(
                      'הקודם',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textDirection: TextDirection.rtl,
                    ),
                  ),

                  // כפתור הבא
                  ElevatedButton.icon(
                    onPressed:
                        _currentIndex < letters.length - 1 ? _goToNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 28),
                    label: const Text(
                      'הבא',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
