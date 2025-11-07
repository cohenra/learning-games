import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';

/// משחק קצב - תרגול ושחזור קצבים
class RhythmGameScreen extends StatefulWidget {
  const RhythmGameScreen({super.key});

  @override
  State<RhythmGameScreen> createState() => _RhythmGameScreenState();
}

class _RhythmGameScreenState extends State<RhythmGameScreen> with SingleTickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();

  int _level = 1;
  int _score = 0;
  List<bool> _pattern = []; // true = beat, false = pause
  List<bool> _userInput = [];
  bool _isPlaying = false;
  bool _isListening = false;
  bool _showResult = false;
  bool? _isCorrect;
  bool _isHebrew = true;

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initTts();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isHebrew = Localizations.localeOf(context).languageCode == 'he';
      });
      _generatePattern();
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
  }

  void _generatePattern() {
    final patternLength = min(3 + _level, 8); // Start with 4, max 8
    _pattern = List.generate(
      patternLength,
      (index) => _random.nextBool(),
    );
    // Ensure at least 2 beats
    if (_pattern.where((b) => b).length < 2) {
      _pattern[0] = true;
      _pattern[1] = true;
    }
    _userInput = [];
    _showResult = false;
    _isCorrect = null;
  }

  Future<void> _playPattern() async {
    setState(() {
      _isPlaying = true;
      _isListening = false;
    });

    // First speak the instruction
    await _speak(_isHebrew ? 'הקשב לקצב' : 'Listen to the rhythm');
    await Future.delayed(const Duration(milliseconds: 500));

    for (int i = 0; i < _pattern.length; i++) {
      if (_pattern[i]) {
        _animController.forward().then((_) => _animController.reverse());
        await _playDrumSound(); // Play drum sound
        await Future.delayed(const Duration(milliseconds: 500));
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    setState(() {
      _isPlaying = false;
      _isListening = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    await _speak(_isHebrew ? 'עכשיו תורך! לחץ על התוף או על ההפסקה' : 'Now your turn! Tap the drum or pause');
  }

  Future<void> _playDrumSound() async {
    // Play a drum sound using TTS with very specific settings
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(5.0); // Very very fast
    await _flutterTts.setPitch(0.3); // Very low pitch for drum effect
    await _flutterTts.speak('dum dum dum');
    await Future.delayed(const Duration(milliseconds: 100));
    // Reset to normal
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    final lang = _isHebrew ? 'he-IL' : 'en-US';
    await _flutterTts.setLanguage(lang);
    await _flutterTts.speak(text);
  }

  void _onDrumTap() {
    if (!_isListening || _showResult) return;

    setState(() {
      _userInput.add(true);
    });

    _animController.forward().then((_) => _animController.reverse());
    _playDrumSound(); // Play drum sound when user taps

    // Check if user finished input
    if (_userInput.length == _pattern.length) {
      _checkAnswer();
    }
  }

  void _onPauseTap() {
    if (!_isListening || _showResult) return;

    setState(() {
      _userInput.add(false);
    });

    // Check if user finished input
    if (_userInput.length == _pattern.length) {
      _checkAnswer();
    }
  }

  void _checkAnswer() {
    bool correct = true;
    for (int i = 0; i < _pattern.length; i++) {
      if (_pattern[i] != _userInput[i]) {
        correct = false;
        break;
      }
    }

    setState(() {
      _isCorrect = correct;
      _showResult = true;
      _isListening = false;
      if (correct) {
        _score += 10 * _level;
        _level++;
      }
    });

    if (correct) {
      _speak(_isHebrew ? 'מעולה!' : 'Excellent!');
    } else {
      _speak(_isHebrew ? 'נסה שוב!' : 'Try again!');
    }
  }

  void _nextRound() {
    _generatePattern();
    _playPattern();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _animController.dispose();
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
              Colors.red.shade50,
              Colors.orange.shade50,
              Colors.yellow.shade50,
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
                        color: Colors.red.shade700,
                        size: 32,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        _isHebrew ? 'משחק קצב' : 'Rhythm Game',
                        style: TextStyle(
                          fontSize: responsive.titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
              ),

              // Level and score
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_isHebrew ? 'רמה' : 'Level'} $_level',
                        style: TextStyle(
                          fontSize: responsive.fontSize(18),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_isHebrew ? 'ניקוד' : 'Score'}: $_score',
                        style: TextStyle(
                          fontSize: responsive.fontSize(18),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: responsive.spacing(30)),

              // Instructions
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                child: Text(
                  _isPlaying
                      ? (_isHebrew ? 'הקשב לקצב...' : 'Listen to the rhythm...')
                      : _isListening
                          ? (_isHebrew ? 'שחזר את הקצב!' : 'Repeat the rhythm!')
                          : (_isHebrew ? 'לחץ כדי להתחיל' : 'Press to start'),
                  style: TextStyle(
                    fontSize: responsive.fontSize(22),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: responsive.spacing(20)),

              // Pattern display
              if (_pattern.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _pattern.asMap().entries.map((entry) {
                      final index = entry.key;
                      final isBeat = entry.value;
                      final isUserInput = index < _userInput.length;
                      final userCorrect = isUserInput && _userInput[index] == isBeat;

                      Color color = Colors.grey.shade300;
                      if (_showResult && isUserInput) {
                        color = userCorrect ? Colors.green : Colors.red;
                      } else if (isUserInput) {
                        color = Colors.blue;
                      }

                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: color,
                          shape: isBeat ? BoxShape.circle : BoxShape.rectangle,
                          borderRadius: isBeat ? null : BorderRadius.circular(6),
                        ),
                        child: isUserInput
                            ? Icon(
                                userCorrect ? Icons.check : Icons.close,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      );
                    }).toList(),
                  ),
                ),

              SizedBox(height: responsive.spacing(20)),

              // Drum and Pause buttons
              Expanded(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Drum button
                      GestureDetector(
                        onTap: _onDrumTap,
                        child: AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _isListening ? _scaleAnimation.value : 1.0,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: _isListening ? Colors.red : Colors.red.shade300,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.5),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '🥁',
                                        style: TextStyle(fontSize: 60),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        _isHebrew ? 'תוף' : 'Drum',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Pause button
                      GestureDetector(
                        onTap: _onPauseTap,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: _isListening ? Colors.grey.shade600 : Colors.grey.shade400,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.pause,
                                  size: 60,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _isHebrew ? 'הפסקה' : 'Pause',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Control buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (!_isPlaying && !_isListening && !_showResult)
                      KidButton(
                        text: _isHebrew ? 'שמע קצב 🔊' : 'Play Rhythm 🔊',
                        icon: Icons.play_arrow,
                        onPressed: _playPattern,
                        color: Colors.green,
                        height: 60,
                      ),
                    if (_showResult)
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: KidButton(
                                text: _isHebrew ? 'שמע שוב' : 'Replay',
                                icon: Icons.replay,
                                onPressed: _playPattern,
                                color: Colors.blue,
                                height: 60,
                              ),
                            ),
                          ),
                          if (_isCorrect == true)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: KidButton(
                                  text: _isHebrew ? 'הבא' : 'Next',
                                  icon: Icons.arrow_forward,
                                  onPressed: _nextRound,
                                  color: Colors.green,
                                  height: 60,
                                ),
                              ),
                            ),
                        ],
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
