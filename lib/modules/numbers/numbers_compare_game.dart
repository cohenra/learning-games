import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/kid_button.dart';
import '../../widgets/reward_animation.dart';
import '../../utils/responsive_helper.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// משחק השוואת מספרים - מי גדול יותר?
class NumbersCompareGame extends StatefulWidget {
  const NumbersCompareGame({super.key});

  @override
  State<NumbersCompareGame> createState() => _NumbersCompareGameState();
}

class _NumbersCompareGameState extends State<NumbersCompareGame> {
  final int _totalRounds = 5;
  int _currentRound = 0;
  int _score = 0;
  bool _showReward = false;
  int? _selectedSide; // 0 = שמאל, 1 = ימין

  int _leftNumber = 0;
  int _rightNumber = 0;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateRound();
  }

  void _generateRound() {
    // יצירת שני מספרים שונים
    do {
      _leftNumber = _random.nextInt(10) + 1;
      _rightNumber = _random.nextInt(10) + 1;
    } while (_leftNumber == _rightNumber);

    _selectedSide = null;

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
        ? 'לחצו על המספר הגדול יותר'
        : 'Tap on the bigger number';
    appProvider.speak(instruction);
  }

  void _onSideSelected(int side) {
    if (_selectedSide != null) return; // כבר ענו

    final appProvider = context.read<AppProvider>();
    final selectedNumber = side == 0 ? _leftNumber : _rightNumber;
    final otherNumber = side == 0 ? _rightNumber : _leftNumber;
    final isCorrect = selectedNumber > otherNumber;

    setState(() {
      _selectedSide = side;
    });

    if (isCorrect) {
      appProvider.recordAnswer('numbers', true);
      setState(() {
        _score++;
        _showReward = true;
      });
      appProvider.addStar('numbers');
      appProvider.speak(Localizations.localeOf(context).languageCode == 'he' ? 'נכון!' : 'Correct!');

      // עבור לסיבוב הבא
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) {
          setState(() {
            _showReward = false;
          });
          if (_currentRound < _totalRounds - 1) {
            setState(() {
              _currentRound++;
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
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _selectedSide = null;
          });
        }
      });
    }
  }

  Color _getSideColor(int side) {
    if (_selectedSide == null) {
      return Colors.orange.shade400;
    }

    if (_selectedSide == side) {
      final selectedNumber = side == 0 ? _leftNumber : _rightNumber;
      final otherNumber = side == 0 ? _rightNumber : _leftNumber;
      return selectedNumber > otherNumber ? Colors.green.shade500 : Colors.red.shade500;
    }

    return Colors.orange.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final l10n = AppLocalizations.of(context)!;
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';

    if (_currentRound >= _totalRounds) {
      return _buildCompletionScreen(l10n, isHebrew);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isHebrew ? 'מי גדול יותר?' : 'Which is Bigger?'),
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                  // Header עם התקדמות
                  Padding(
                    padding: responsive.safePadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            isHebrew
                                ? 'סיבוב ${_currentRound + 1} מתוך $_totalRounds'
                                : 'Round ${_currentRound + 1} of $_totalRounds',
                            style: TextStyle(
                              fontSize: responsive.fontSize(22),
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.spacing(20),
                            vertical: responsive.spacing(10),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(responsive.spacing(20)),
                          ),
                          child: Text(
                            isHebrew ? 'ניקוד: $_score' : 'Score: $_score',
                            style: TextStyle(
                              fontSize: responsive.fontSize(20),
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: responsive.verticalSpacing),

                  // הוראות
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                    child: Text(
                      isHebrew ? 'לחצו על המספר הגדול יותר' : 'Tap on the bigger number',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: responsive.questionTextSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),

                  SizedBox(height: responsive.verticalSpacing * 2),

                  // שני המספרים
                  Expanded(
                    child: Row(
                      children: [
                        // צד שמאל
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _onSideSelected(0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: EdgeInsets.all(responsive.spacing(12)),
                              decoration: BoxDecoration(
                                color: _getSideColor(0),
                                borderRadius: BorderRadius.circular(responsive.spacing(20)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: responsive.spacing(10),
                                    offset: Offset(0, responsive.spacing(5)),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // המספר
                                  Text(
                                    '$_leftNumber',
                                    style: TextStyle(
                                      fontSize: responsive.emojiSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: responsive.verticalSpacing),
                                  // ייצוג ויזואלי
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: responsive.spacing(8),
                                      runSpacing: responsive.spacing(8),
                                      children: List.generate(
                                        _leftNumber,
                                        (index) => Container(
                                          width: responsive.fontSize(30),
                                          height: responsive.fontSize(30),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // צד ימין
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _onSideSelected(1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: EdgeInsets.all(responsive.spacing(12)),
                              decoration: BoxDecoration(
                                color: _getSideColor(1),
                                borderRadius: BorderRadius.circular(responsive.spacing(20)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: responsive.spacing(10),
                                    offset: Offset(0, responsive.spacing(5)),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // המספר
                                  Text(
                                    '$_rightNumber',
                                    style: TextStyle(
                                      fontSize: responsive.emojiSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: responsive.verticalSpacing),
                                  // ייצוג ויזואלי
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: responsive.spacing(8),
                                      runSpacing: responsive.spacing(8),
                                      children: List.generate(
                                        _rightNumber,
                                        (index) => Container(
                                          width: responsive.fontSize(30),
                                          height: responsive.fontSize(30),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
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

                  // כפתור הקשב
                  Padding(
                    padding: responsive.safePadding,
                    child: KidButton(
                      text: isHebrew ? 'הקשב 🔊' : 'Listen 🔊',
                      onPressed: _speakInstructions,
                      color: Colors.green.shade400,
                      width: responsive.width(50),
                    ),
                  ),

                  SizedBox(height: responsive.verticalSpacing),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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
    final responsive = ResponsiveHelper(context);

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
                    fontSize: responsive.titleSize * 1.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
                SizedBox(height: responsive.verticalSpacing * 2),
                Text(
                  isHebrew ? '!נקודות $_score מתוך $_totalRounds' : 'Score: $_score out of $_totalRounds!',
                  style: TextStyle(
                    fontSize: responsive.titleSize,
                    color: Colors.blue.shade700,
                  ),
                ),
                SizedBox(height: responsive.verticalSpacing * 3),
                KidButton(
                  text: l10n.playAgain,
                  onPressed: () {
                    setState(() {
                      _currentRound = 0;
                      _score = 0;
                    });
                    _generateRound();
                  },
                  color: Colors.green.shade400,
                  width: responsive.width(50),
                ),
                SizedBox(height: responsive.verticalSpacing),
                KidButton(
                  text: isHebrew ? 'חזרה' : 'Back',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  color: Colors.blue.shade400,
                  width: responsive.width(50),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
