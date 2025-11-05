import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/kid_button.dart';
import '../../widgets/reward_animation.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// משחק מיון מספרים - סידור מספרים מהקטן לגדול
class NumbersSortingGame extends StatefulWidget {
  const NumbersSortingGame({super.key});

  @override
  State<NumbersSortingGame> createState() => _NumbersSortingGameState();
}

class _NumbersSortingGameState extends State<NumbersSortingGame> {
  final int _totalRounds = 5;
  int _currentRound = 0;
  int _score = 0;
  bool _showReward = false;

  List<int> _numbers = [];
  List<int> _userOrder = [];
  List<int> _correctOrder = [];

  final Random _random = Random();

  // רמות קושי
  int _difficulty = 3; // 3 = קל (3 מספרים), 4 = בינוני, 5 = קשה

  @override
  void initState() {
    super.initState();
    _generateRound();
  }

  void _generateRound() {
    // בחר 3-5 מספרים אקראיים שונים
    final numbersSet = <int>{};
    while (numbersSet.length < _difficulty) {
      numbersSet.add(_random.nextInt(10) + 1);
    }

    _numbers = numbersSet.toList();
    _numbers.shuffle();
    _correctOrder = List<int>.from(_numbers)..sort();
    _userOrder = [];

    setState(() {});

    // הקרא את ההנחיה
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakInstructions();
    });
  }

  void _speakInstructions() {
    final appProvider = context.read<AppProvider>();
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';
    final instruction = isHebrew
        ? 'סדרו את המספרים מהקטן לגדול'
        : 'Sort the numbers from smallest to largest';
    appProvider.speak(instruction);
  }

  void _onNumberTap(int number) {
    if (_userOrder.contains(number)) {
      // אם כבר בחרו את המספר, הסר אותו
      setState(() {
        _userOrder.remove(number);
      });
    } else {
      // הוסף את המספר לסדר
      setState(() {
        _userOrder.add(number);
      });

      // בדוק אם סיימו
      if (_userOrder.length == _numbers.length) {
        _checkAnswer();
      }
    }
  }

  void _checkAnswer() {
    final appProvider = context.read<AppProvider>();
    final isCorrect = _userOrder.toString() == _correctOrder.toString();

    if (isCorrect) {
      appProvider.recordAnswer('numbers', true);
      setState(() {
        _score++;
        _showReward = true;
      });
      appProvider.addStar('numbers');
      appProvider.speak(Localizations.localeOf(context).languageCode == 'he' ? 'מצוין!' : 'Excellent!');

      // עבור לסיבוב הבא
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) {
          setState(() {
            _showReward = false;
          });
          if (_currentRound < _totalRounds - 1) {
            setState(() {
              _currentRound++;
              // הגבר קושי בהדרגה
              if (_currentRound == 2 && _difficulty < 4) _difficulty = 4;
              if (_currentRound == 4 && _difficulty < 5) _difficulty = 5;
            });
            _generateRound();
          } else {
            setState(() {
              _currentRound++;
            });
          }
        }
      });
    } else {
      appProvider.speak(Localizations.localeOf(context).languageCode == 'he' ? 'נסו שוב' : 'Try again');
      setState(() {
        _userOrder.clear();
      });
    }
  }

  void _reset() {
    setState(() {
      _userOrder.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';

    if (_currentRound >= _totalRounds) {
      return _buildCompletionScreen(l10n, isHebrew);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isHebrew ? 'מיון מספרים' : 'Number Sorting'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.shade50,
                  Colors.yellow.shade50,
                  Colors.pink.shade50,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header עם התקדמות
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isHebrew
                              ? 'סיבוב ${_currentRound + 1} מתוך $_totalRounds'
                              : 'Round ${_currentRound + 1} of $_totalRounds',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isHebrew ? 'ניקוד: $_score' : 'Score: $_score',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // הוראות
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      isHebrew ? 'סדרו את המספרים מהקטן לגדול' : 'Sort from smallest to largest',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // המספרים לבחירה
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: _numbers.map((number) {
                        final isSelected = _userOrder.contains(number);
                        return GestureDetector(
                          onTap: () => _onNumberTap(number),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.grey.shade300 : Colors.orange.shade400,
                              shape: BoxShape.circle,
                              boxShadow: isSelected
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: Colors.orange.shade300,
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                            ),
                            child: Center(
                              child: Text(
                                '$number',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.grey.shade500 : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // הסדר שנבחר
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Text(
                          isHebrew ? 'הסדר שלכם:' : 'Your order:',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.orange.shade300,
                              width: 3,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: _userOrder.isEmpty
                                ? [
                                    Text(
                                      '...',
                                      style: TextStyle(
                                        fontSize: 36,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ]
                                : _userOrder.map((number) {
                                    return Text(
                                      '$number',
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade700,
                                      ),
                                    );
                                  }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // כפתורים
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        KidButton(
                          text: isHebrew ? 'איפוס' : 'Reset',
                          onPressed: _reset,
                          color: Colors.grey.shade500,
                          width: 140,
                        ),
                        KidButton(
                          text: isHebrew ? 'הקשב 🔊' : 'Listen 🔊',
                          onPressed: _speakInstructions,
                          color: Colors.green.shade400,
                          width: 140,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_showReward)
            const RewardAnimation(),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen(AppLocalizations l10n, bool isHebrew) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.yellow.shade100,
              Colors.orange.shade100,
              Colors.pink.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.wellDone,
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  isHebrew ? '!נקודות $_score מתוך $_totalRounds' : 'Score: $_score out of $_totalRounds!',
                  style: TextStyle(
                    fontSize: 36,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 50),
                KidButton(
                  text: l10n.playAgain,
                  onPressed: () {
                    setState(() {
                      _currentRound = 0;
                      _score = 0;
                      _difficulty = 3;
                    });
                    _generateRound();
                  },
                  color: Colors.green.shade400,
                  width: 200,
                ),
                const SizedBox(height: 20),
                KidButton(
                  text: isHebrew ? 'חזרה' : 'Back',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  color: Colors.blue.shade400,
                  width: 200,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
