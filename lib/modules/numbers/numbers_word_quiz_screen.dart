import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/kid_button.dart';
import '../../widgets/reward_animation.dart';
import '../../utils/responsive_helper.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// חידון מספרים עם תשובות במילים - "שבע" במקום "7"
class NumbersWordQuizScreen extends StatefulWidget {
  const NumbersWordQuizScreen({super.key});

  @override
  State<NumbersWordQuizScreen> createState() => _NumbersWordQuizScreenState();
}

class _NumbersWordQuizScreenState extends State<NumbersWordQuizScreen> {
  final int _totalQuestions = 5;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool? _isCorrect;
  bool _showReward = false;
  bool _showWords = true; // Toggle: true = מילים, false = ספרות

  late int _correctAnswer;
  late List<int> _options;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  String _getNumberName(AppLocalizations l10n, int number) {
    switch (number) {
      case 1: return l10n.numberOne;
      case 2: return l10n.numberTwo;
      case 3: return l10n.numberThree;
      case 4: return l10n.numberFour;
      case 5: return l10n.numberFive;
      case 6: return l10n.numberSix;
      case 7: return l10n.numberSeven;
      case 8: return l10n.numberEight;
      case 9: return l10n.numberNine;
      case 10: return l10n.numberTen;
      default: return '';
    }
  }

  void _generateQuestion() {
    setState(() {
      _correctAnswer = _random.nextInt(10) + 1;
      _options = [_correctAnswer];

      // הוסף 3 תשובות שגויות
      while (_options.length < 4) {
        final wrongOption = _random.nextInt(10) + 1;
        if (!_options.contains(wrongOption)) {
          _options.add(wrongOption);
        }
      }

      // ערבב
      _options.shuffle();

      _selectedAnswer = null;
      _isCorrect = null;
      _showReward = false;
    });

    // דבר את השאלה אחרי שהמסך נבנה
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakQuestion();
    });
  }

  void _speakQuestion() {
    final appProvider = context.read<AppProvider>();
    final l10n = AppLocalizations.of(context)!;
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';

    // ההנחיה הקולית אומרת "בחר את המספר 7" (במספר)
    final question = isHebrew
        ? 'בחרו את המספר $_correctAnswer'
        : 'Select the number $_correctAnswer';
    appProvider.speak(question);
  }

  void _handleAnswer(int answer) {
    // אם כבר ענו נכון, אל תאפשר לחיצות נוספות
    if (_isCorrect == true) return;

    final appProvider = context.read<AppProvider>();
    final isCorrect = answer == _correctAnswer;

    setState(() {
      _selectedAnswer = answer;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      // רק תשובות נכונות נספרות
      appProvider.recordAnswer('numbers', isCorrect);

      setState(() {
        _score++;
        _showReward = true;
      });
      appProvider.addStar('numbers');

      // נגן סאונד תשובה נכונה
      appProvider.speak(Localizations.localeOf(context).languageCode == 'he' ? 'כל הכבוד!' : 'Great job!');

      // הסתר את הפרס ועבור לשאלה הבאה אחרי 2.5 שניות
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) {
          setState(() {
            _showReward = false;
          });
          // עבור לשאלה הבאה אוטומטית
          if (_currentQuestionIndex < _totalQuestions - 1) {
            setState(() {
              _currentQuestionIndex++;
            });
            _generateQuestion();
          } else {
            // סיימנו את כל השאלות
            setState(() {
              _currentQuestionIndex++;
            });
          }
        }
      });
    } else {
      // תשובה שגויה - נגן סאונד ואפשר ניסיון נוסף
      appProvider.speak(Localizations.localeOf(context).languageCode == 'he' ? 'נסה שוב' : 'Try again');

      // אפס את הבחירה אחרי שניה כדי שיוכל לנסות שוב
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && _isCorrect == false) {
          setState(() {
            _selectedAnswer = null;
            _isCorrect = null;
          });
        }
      });
    }
  }

  Color _getButtonColor(int option) {
    if (_selectedAnswer == null) {
      return Colors.orange.shade400;
    }

    // אם בחרו את האופציה הזו
    if (option == _selectedAnswer) {
      if (_isCorrect == true) {
        return Colors.green.shade500; // נכון - ירוק
      } else {
        return Colors.red.shade500; // שגוי - אדום
      }
    }

    // כפתורים שלא נבחרו נשארים כתומים
    return Colors.orange.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';
    final responsive = ResponsiveHelper(context);

    if (_currentQuestionIndex >= _totalQuestions && _selectedAnswer != null) {
      return _buildCompletionScreen(l10n, isHebrew);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quizMode),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
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
                  final isTablet = MediaQuery.of(context).size.width >= 600;

                  if (isTablet) {
                    // Tablet: fit everything on one screen
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      // Header עם התקדמות וניקוד
                      Padding(
                        padding: EdgeInsets.all(responsive.spacing(16)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                isHebrew
                                    ? 'שאלה ${_currentQuestionIndex + 1} מתוך $_totalQuestions'
                                    : 'Question ${_currentQuestionIndex + 1} of $_totalQuestions',
                                style: TextStyle(
                                  fontSize: responsive.subtitleSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: responsive.spacing(20),
                                vertical: responsive.spacing(10)
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(responsive.spacing(20)),
                              ),
                              child: Text(
                                isHebrew ? 'ניקוד: $_score' : 'Score: $_score',
                                style: TextStyle(
                                  fontSize: responsive.subtitleSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: responsive.spacing(12)),

                      // כפתור החלפה בין מילים למספרים
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showWords = !_showWords;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.spacing(20),
                            vertical: responsive.spacing(8)
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade200,
                            borderRadius: BorderRadius.circular(responsive.spacing(20)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _showWords ? Icons.text_fields : Icons.numbers,
                                color: Colors.orange.shade700,
                                size: responsive.iconSize(20),
                              ),
                              SizedBox(width: responsive.spacing(8)),
                              Text(
                                _showWords
                                    ? (isHebrew ? 'מילים' : 'Words')
                                    : (isHebrew ? 'ספרות' : 'Digits'),
                                style: TextStyle(
                                  fontSize: responsive.bodyTextSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                              SizedBox(width: responsive.spacing(8)),
                              Icon(
                                Icons.swap_horiz,
                                color: Colors.orange.shade700,
                                size: responsive.iconSize(20),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: responsive.spacing(12)),

                      // השאלה - טקסט בלבד ללא מספר
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                        child: Text(
                          isHebrew ? 'בחרו את המספר:' : 'Select the number:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: responsive.questionTextSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),

                      SizedBox(height: responsive.spacing(12)),

                      // אפשרויות תשובה - מלבנים דקים כמו בחידונים האחרים
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.spacing(20),
                            vertical: responsive.spacing(8)
                          ),
                          child: GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            mainAxisSpacing: responsive.spacing(8),
                            crossAxisSpacing: responsive.spacing(8),
                            childAspectRatio: responsive.quizButtonAspectRatio,
                            physics: const NeverScrollableScrollPhysics(),
                            children: _options.map<Widget>((number) {
                              final displayText = _showWords
                                  ? _getNumberName(l10n, number)
                                  : '$number';
                              return GestureDetector(
                                onTap: () => _handleAnswer(number),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: _getButtonColor(number),
                                    borderRadius: BorderRadius.circular(responsive.spacing(16)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: responsive.spacing(8),
                                        offset: Offset(0, responsive.spacing(4)),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          displayText,
                                          style: TextStyle(
                                            fontSize: _showWords
                                                ? responsive.answerTextSize
                                                : responsive.largeNumberSize,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      SizedBox(height: responsive.spacing(32)),

                      // כפתור להאזנה לשאלה שוב
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: responsive.spacing(8)),
                        child: KidButton(
                          text: isHebrew ? 'הקשב שוב 🔊' : 'Listen Again 🔊',
                          onPressed: _speakQuestion,
                          color: Colors.green.shade400,
                          width: responsive.width(50),
                        ),
                      ),

                      SizedBox(height: responsive.spacing(20)),
                        ],
                      ),
                    );
                  } else {
                    // Phone: allow scrolling
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Column(
                          children: [
                            // Header עם התקדמות וניקוד
                            Padding(
                              padding: EdgeInsets.all(responsive.spacing(16)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      isHebrew
                                          ? 'שאלה ${_currentQuestionIndex + 1} מתוך $_totalQuestions'
                                          : 'Question ${_currentQuestionIndex + 1} of $_totalQuestions',
                                      style: TextStyle(
                                        fontSize: responsive.subtitleSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: responsive.spacing(20),
                                      vertical: responsive.spacing(10)
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(responsive.spacing(20)),
                                    ),
                                    child: Text(
                                      isHebrew ? 'ניקוד: $_score' : 'Score: $_score',
                                      style: TextStyle(
                                        fontSize: responsive.subtitleSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: responsive.spacing(12)),

                            // כפתור החלפה בין מילים למספרים
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showWords = !_showWords;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: responsive.spacing(20),
                                  vertical: responsive.spacing(8)
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade200,
                                  borderRadius: BorderRadius.circular(responsive.spacing(20)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _showWords ? Icons.text_fields : Icons.numbers,
                                      color: Colors.orange.shade700,
                                      size: responsive.iconSize(20),
                                    ),
                                    SizedBox(width: responsive.spacing(8)),
                                    Text(
                                      _showWords
                                          ? (isHebrew ? 'מילים' : 'Words')
                                          : (isHebrew ? 'ספרות' : 'Digits'),
                                      style: TextStyle(
                                        fontSize: responsive.bodyTextSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                    SizedBox(width: responsive.spacing(8)),
                                    Icon(
                                      Icons.swap_horiz,
                                      color: Colors.orange.shade700,
                                      size: responsive.iconSize(20),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: responsive.spacing(12)),

                            // השאלה - טקסט בלבד ללא מספר
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                              child: Text(
                                isHebrew ? 'בחרו את המספר:' : 'Select the number:',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: responsive.questionTextSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),

                            SizedBox(height: responsive.spacing(12)),

                            // אפשרויות תשובה - מלבנים דקים כמו בחידונים האחרים
                            SizedBox(
                              height: responsive.height(20),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: responsive.spacing(20),
                                  vertical: responsive.spacing(8)
                                ),
                                child: GridView.count(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: responsive.spacing(8),
                                  crossAxisSpacing: responsive.spacing(8),
                                  childAspectRatio: responsive.quizButtonAspectRatio,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: _options.map<Widget>((number) {
                                    final displayText = _showWords
                                        ? _getNumberName(l10n, number)
                                        : '$number';
                                    return GestureDetector(
                                      onTap: () => _handleAnswer(number),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        decoration: BoxDecoration(
                                          color: _getButtonColor(number),
                                          borderRadius: BorderRadius.circular(responsive.spacing(16)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: responsive.spacing(8),
                                              offset: Offset(0, responsive.spacing(4)),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                displayText,
                                                style: TextStyle(
                                                  fontSize: _showWords
                                                      ? responsive.answerTextSize
                                                      : responsive.largeNumberSize,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),

                            SizedBox(height: responsive.spacing(16)),

                            // כפתור להאזנה לשאלה שוב
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: responsive.spacing(8)),
                              child: KidButton(
                                text: isHebrew ? 'הקשב שוב 🔊' : 'Listen Again 🔊',
                                onPressed: _speakQuestion,
                                color: Colors.green.shade400,
                                width: responsive.width(50),
                              ),
                            ),

                            SizedBox(height: responsive.spacing(20)),
                          ],
                        ),
                      ),
                    );
                  }
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
        width: double.infinity,
        height: double.infinity,
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = MediaQuery.of(context).size.width >= 600;

              if (isTablet) {
                // Tablet: fit everything on one screen
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Text(
                          l10n.wellDone,
                          style: TextStyle(
                            fontSize: responsive.titleSize * 1.3,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        SizedBox(height: responsive.spacing(30)),
                        Text(
                          isHebrew ? '!נקודות $_score מתוך $_totalQuestions' : 'Score: $_score out of $_totalQuestions!',
                          style: TextStyle(
                            fontSize: responsive.titleSize,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        SizedBox(height: responsive.spacing(50)),
                        KidButton(
                          text: l10n.playAgain,
                          onPressed: () {
                            setState(() {
                              _currentQuestionIndex = 0;
                              _score = 0;
                            });
                            _generateQuestion();
                          },
                          color: Colors.green.shade400,
                          width: responsive.width(50),
                        ),
                        SizedBox(height: responsive.spacing(20)),
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
                );
              } else {
                // Phone: allow scrolling
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.wellDone,
                            style: TextStyle(
                              fontSize: responsive.titleSize * 1.3,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          SizedBox(height: responsive.spacing(30)),
                          Text(
                            isHebrew ? '!נקודות $_score מתוך $_totalQuestions' : 'Score: $_score out of $_totalQuestions!',
                            style: TextStyle(
                              fontSize: responsive.titleSize,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          SizedBox(height: responsive.spacing(50)),
                          KidButton(
                            text: l10n.playAgain,
                            onPressed: () {
                              setState(() {
                                _currentQuestionIndex = 0;
                                _score = 0;
                              });
                              _generateQuestion();
                            },
                            color: Colors.green.shade400,
                            width: responsive.width(50),
                          ),
                          SizedBox(height: responsive.spacing(20)),
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
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
