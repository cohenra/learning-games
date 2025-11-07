import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';
import '../../services/audio_service.dart';

/// משחק קצב - תרגול ושחזור קצבים עם מספר צלילים גדל
class RhythmGameScreen extends StatefulWidget {
  const RhythmGameScreen({super.key});

  @override
  State<RhythmGameScreen> createState() => _RhythmGameScreenState();
}

class _RhythmGameScreenState extends State<RhythmGameScreen> with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  final AudioService _audioService = AudioService();
  final Random _random = Random();

  int _level = 1;
  int _score = 0;
  List<int> _pattern = []; // 0, 1, 2 = different drum sounds
  List<int> _userInput = [];
  bool _isPlaying = false;
  bool _isListening = false;
  bool _showResult = false;
  bool? _isCorrect;
  bool _isHebrew = true;

  late List<AnimationController> _animControllers;
  late List<Animation<double>> _scaleAnimations;

  // Define 3 different musical instruments with different sounds
  final List<Map<String, dynamic>> _instruments = [
    {'emoji': '🎹', 'nameHe': 'פסנתר', 'nameEn': 'Piano', 'color': Colors.blue, 'note': 'C'},
    {'emoji': '🎸', 'nameHe': 'גיטרה', 'nameEn': 'Guitar', 'color': Colors.orange, 'note': 'E'},
    {'emoji': '🎺', 'nameHe': 'חצוצרה', 'nameEn': 'Trumpet', 'color': Colors.red, 'note': 'G'},
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
    _audioService.initialize();

    // Create animation controllers for each instrument
    _animControllers = List.generate(
      _instruments.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    );

    _scaleAnimations = _animControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.3).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

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
    // Level 1: 3 sounds, Level 2: 4 sounds, Level 3: 5 sounds, etc.
    final patternLength = 2 + _level; // Level 1 = 3, Level 2 = 4, etc.
    final maxSoundTypes = min(3, _level + 2); // Start with 3 types, can use all 3

    _pattern = List.generate(
      patternLength,
      (index) => _random.nextInt(maxSoundTypes), // Random drum from available types
    );

    _userInput = [];
    _showResult = false;
    _isCorrect = null;
  }

  Future<void> _playPattern() async {
    if (!mounted) return;

    setState(() {
      _isPlaying = true;
      _isListening = false;
    });

    await _speak(_isHebrew ? 'הקשב לקצב' : 'Listen to the rhythm');
    await Future.delayed(const Duration(milliseconds: 500));

    for (int i = 0; i < _pattern.length; i++) {
      if (!mounted) return; // Check if widget is still mounted

      final instrumentIndex = _pattern[i];
      _animControllers[instrumentIndex].forward().then((_) {
        if (mounted) {
          _animControllers[instrumentIndex].reverse();
        }
      });
      await _playInstrumentSound(instrumentIndex);
      await Future.delayed(const Duration(milliseconds: 600));
    }

    if (!mounted) return;

    setState(() {
      _isPlaying = false;
      _isListening = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    await _speak(_isHebrew ? 'עכשיו תורך! חזור על הקצב' : 'Now your turn! Repeat the rhythm');
  }

  Future<void> _playInstrumentSound(int instrumentIndex) async {
    final note = _instruments[instrumentIndex]['note'] as String;
    await _audioService.playNote(note);
  }

  Future<void> _speak(String text) async {
    final lang = _isHebrew ? 'he-IL' : 'en-US';
    await _flutterTts.setLanguage(lang);
    await _flutterTts.speak(text);
  }

  void _onInstrumentTap(int instrumentIndex) {
    if (!_isListening || _showResult || !mounted) return;

    setState(() {
      _userInput.add(instrumentIndex);
    });

    _animControllers[instrumentIndex].forward().then((_) {
      if (mounted) {
        _animControllers[instrumentIndex].reverse();
      }
    });
    _playInstrumentSound(instrumentIndex);

    if (_userInput.length == _pattern.length) {
      _checkAnswer();
    }
  }

  void _checkAnswer() {
    if (!mounted) return;

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
    if (!mounted) return;

    setState(() {
      _generatePattern();
      _userInput = [];
      _showResult = false;
      _isCorrect = null;
      _isPlaying = false;
      _isListening = false;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _playPattern();
      }
    });
  }

  void _tryAgain() {
    if (!mounted) return;

    setState(() {
      _userInput = [];
      _showResult = false;
      _isCorrect = null;
      _isPlaying = false;
      _isListening = false;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _playPattern();
      }
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _audioService.stop();
    for (var controller in _animControllers) {
      controller.dispose();
    }
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
                    const SizedBox(width: 48),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

              SizedBox(height: responsive.spacing(20)),

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
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: _pattern.asMap().entries.map((entry) {
                      final index = entry.key;
                      final drumType = entry.value;
                      final isUserInput = index < _userInput.length;
                      final userCorrect = isUserInput && _userInput[index] == drumType;

                      Color color = Colors.grey.shade300;
                      if (_showResult && isUserInput) {
                        color = userCorrect ? Colors.green : Colors.red;
                      } else if (isUserInput) {
                        color = _instruments[drumType]['color'];
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isUserInput
                              ? Icon(
                                  userCorrect ? Icons.check : Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : Text(
                                  _instruments[drumType]['emoji'],
                                  style: const TextStyle(fontSize: 20),
                                ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              SizedBox(height: responsive.spacing(20)),

              // Instrument buttons - show all 3 instruments
              Expanded(
                child: Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 20,
                    runSpacing: 20,
                    children: List.generate(_instruments.length, (index) {
                      final instrument = _instruments[index];
                      return GestureDetector(
                        onTap: () => _onInstrumentTap(index),
                        child: AnimatedBuilder(
                          animation: _scaleAnimations[index],
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _isListening ? _scaleAnimations[index].value : 1.0,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: _isListening ? instrument['color'] : (instrument['color'] as Color).withOpacity(0.5),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (instrument['color'] as Color).withOpacity(0.5),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        instrument['emoji'],
                                        style: const TextStyle(fontSize: 50),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _isHebrew ? instrument['nameHe'] : instrument['nameEn'],
                                        style: const TextStyle(
                                          fontSize: 16,
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
                      );
                    }),
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
                                text: _isHebrew ? 'נסה שוב' : 'Try Again',
                                icon: Icons.replay,
                                onPressed: _tryAgain,
                                color: Colors.orange,
                                height: 60,
                              ),
                            ),
                          ),
                          if (_isCorrect == true)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: KidButton(
                                  text: _isHebrew ? 'רמה הבאה' : 'Next Level',
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
