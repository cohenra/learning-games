import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/kid_button.dart';
import '../../widgets/reward_animation.dart';
import '../../utils/responsive_helper.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// מסך חידון צבעים - שאלות אקראיות עם בחירה מרובה
class ColorsQuizScreen extends StatefulWidget {
  const ColorsQuizScreen({super.key});

  @override
  State<ColorsQuizScreen> createState() => _ColorsQuizScreenState();
}

class _ColorsQuizScreenState extends State<ColorsQuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;
  int? _selectedAnswer;
  bool? _isCorrect;
  bool _showReward = false;

  late int _correctAnswerIndex;
  late List<Map<String, dynamic>> _options;

  final Random _random = Random();

  // 10 צבעים
  final List<Map<String, dynamic>> _allColors = [
    {'name': 'colorRed', 'color': Colors.red},
    {'name': 'colorBlue', 'color': Colors.blue},
    {'name': 'colorYellow', 'color': Colors.yellow.shade700},
    {'name': 'colorGreen', 'color': Colors.green},
    {'name': 'colorOrange', 'color': Colors.orange},
    {'name': 'colorPurple', 'color': Colors.purple},
    {'name': 'colorPink', 'color': Colors.pink},
    {'name': 'colorBrown', 'color': Colors.brown},
    {'name': 'colorBlack', 'color': Colors.black},
    {'name': 'colorWhite', 'color': Colors.white},
  ];

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    setState(() {
      // בחר צבע נכון אקראי
      _correctAnswerIndex = _random.nextInt(_allColors.length);
      _options = [_allColors[_correctAnswerIndex]];

      // הוסף 3 צבעים שגויים
      while (_options.length < 4) {
        final wrongColorIndex = _random.nextInt(_allColors.length);
        final wrongColor = _allColors[wrongColorIndex];
        if (!_options.any((c) => c['name'] == wrongColor['name'])) {
          _options.add(wrongColor);
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
    final colorName = _getColorName(l10n, _allColors[_correctAnswerIndex]['name']);

    // דבר "בחרו את הצבע אדום" או "Select the color red"
    final question = l10n.selectTheColor(colorName);
    appProvider.speak(question);
  }

  String _getColorName(AppLocalizations l10n, String colorKey) {
    switch (colorKey) {
      case 'colorRed':
        return l10n.colorRed;
      case 'colorBlue':
        return l10n.colorBlue;
      case 'colorYellow':
        return l10n.colorYellow;
      case 'colorGreen':
        return l10n.colorGreen;
      case 'colorOrange':
        return l10n.colorOrange;
      case 'colorPurple':
        return l10n.colorPurple;
      case 'colorPink':
        return l10n.colorPink;
      case 'colorBrown':
        return l10n.colorBrown;
      case 'colorBlack':
        return l10n.colorBlack;
      case 'colorWhite':
        return l10n.colorWhite;
      default:
        return '';
    }
  }

  void _handleAnswer(int optionIndex) {
    // אם כבר ענו נכון, אל תאפשר לחיצות נוספות
    if (_isCorrect == true) return;

    final appProvider = context.read<AppProvider>();
    final selectedColorName = _options[optionIndex]['name'];
    final correctColorName = _allColors[_correctAnswerIndex]['name'];
    final isCorrect = selectedColorName == correctColorName;

    setState(() {
      _selectedAnswer = optionIndex;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      // רק תשובות נכונות נספרות
      appProvider.recordAnswer('colors', isCorrect);

      setState(() {
        _score++;
        _correctAnswers++;
        _showReward = true;
      });
      appProvider.addStar('colors');

      // נגן סאונד תשובה נכונה
      appProvider.speak(Localizations.localeOf(context).languageCode == 'he' ? 'כל הכבוד!' : 'Great job!');

      // הסתר את הפרס ועבור לשאלה הבאה אחרי 2.5 שניות
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) {
          setState(() {
            _showReward = false;
          });
          // עבור לשאלה הבאה אוטומטית
          setState(() {
            _currentQuestionIndex++;
          });
          _generateQuestion();
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

  Color _getButtonBorderColor(int optionIndex) {
    if (_selectedAnswer == null) {
      return Colors.grey.shade400;
    }

    // אם בחרו את האופציה הזו
    if (optionIndex == _selectedAnswer) {
      if (_isCorrect == true) {
        return Colors.green.shade700; // נכון - גבול ירוק
      } else {
        return Colors.red.shade700; // שגוי - גבול אדום
      }
    }

    // כפתורים שלא נבחרו נשארים רגילים
    return Colors.grey.shade400;
  }

  double _getButtonBorderWidth(int optionIndex) {
    if (_selectedAnswer == optionIndex) {
      return 6.0; // גבול עבה יותר לכפתור שנבחר
    }
    return 3.0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';
    final responsive = ResponsiveHelper(context);

    final correctColorName = _getColorName(l10n, _allColors[_correctAnswerIndex]['name']);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quizMode),
        centerTitle: true,
        backgroundColor: Colors.green.shade600,
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
                  Colors.green.shade50,
                  Colors.blue.shade50,
                  Colors.purple.shade50,
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
                      // התקדמות
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.horizontalSpacing,
                          vertical: responsive.spacing(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${l10n.question} ${_currentQuestionIndex + 1}',
                              style: TextStyle(
                                fontSize: responsive.subtitleSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: List.generate(
                                _score,
                                (index) => Padding(
                                  padding: EdgeInsets.symmetric(horizontal: responsive.spacing(2)),
                                  child: Text('⭐', style: TextStyle(fontSize: responsive.fontSize(20))),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: responsive.spacing(8)),

                      // שאלה - "בחרו את הצבע אדום"
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: responsive.horizontalSpacing),
                        child: GestureDetector(
                          onTap: _speakQuestion,
                          child: Text(
                            l10n.selectTheColor(correctColorName),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: responsive.questionTextSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: responsive.spacing(12)),

                      // אפשרויות תשובה - מלבנים צבעוניים דקים כמו בחידון מספרים
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.horizontalSpacing,
                            vertical: responsive.spacing(8),
                          ),
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: responsive.spacing(8),
                            crossAxisSpacing: responsive.spacing(8),
                            childAspectRatio: responsive.quizButtonAspectRatio,
                          children: List.generate(_options.length, (index) {
                            final colorData = _options[index];
                            final color = colorData['color'] as Color;

                            return GestureDetector(
                              onTap: () => _handleAnswer(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(responsive.spacing(20)),
                                  border: Border.all(
                                    color: _getButtonBorderColor(index),
                                    width: _getButtonBorderWidth(index),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withOpacity(0.5),
                                      blurRadius: responsive.spacing(15),
                                      offset: Offset(0, responsive.spacing(6)),
                                    ),
                                  ],
                                ),
                                child: color == Colors.white
                                    ? Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(responsive.spacing(18)),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: responsive.spacing(2),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          }),
                        ),
                      ),
                      ),

                      SizedBox(height: responsive.verticalSpacing * 2),

                      // כפתורים - האזנה וסיום
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.horizontalSpacing,
                          vertical: responsive.spacing(8)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: KidButton(
                                  text: isHebrew ? 'הקשב 🔊' : 'Listen 🔊',
                                  icon: Icons.volume_up,
                                  onPressed: _speakQuestion,
                                  color: Colors.purple.shade400,
                                  height: 60,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: KidButton(
                                  text: isHebrew ? 'סיום 🏁' : 'Finish 🏁',
                                  icon: Icons.check_circle,
                                  onPressed: _showFinalScore,
                                  color: Colors.red,
                                  height: 60,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // הודעת נכון (ללא כפתורים - עובר אוטומטית)
                      if (_isCorrect == true)
                        Padding(
                          padding: EdgeInsets.only(bottom: responsive.spacing(16)),
                          child: Text(
                            l10n.correct,
                            style: TextStyle(
                              fontSize: responsive.questionTextSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        )
                      else
                        SizedBox(height: responsive.spacing(16)),
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
                            // התקדמות
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: responsive.horizontalSpacing,
                                vertical: responsive.spacing(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${l10n.question} ${_currentQuestionIndex + 1}',
                                    style: TextStyle(
                                      fontSize: responsive.subtitleSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(
                                      _score,
                                      (index) => Padding(
                                        padding: EdgeInsets.symmetric(horizontal: responsive.spacing(2)),
                                        child: Text('⭐', style: TextStyle(fontSize: responsive.fontSize(20))),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: responsive.spacing(8)),

                            // שאלה - "בחרו את הצבע אדום"
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: responsive.horizontalSpacing),
                              child: GestureDetector(
                                onTap: _speakQuestion,
                                child: Text(
                                  l10n.selectTheColor(correctColorName),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: responsive.questionTextSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: responsive.spacing(12)),

                            // אפשרויות תשובה - מלבנים צבעוניים דקים כמו בחידון מספרים
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: responsive.horizontalSpacing,
                                vertical: responsive.spacing(8),
                              ),
                              child: GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                mainAxisSpacing: responsive.spacing(8),
                                crossAxisSpacing: responsive.spacing(8),
                                childAspectRatio: responsive.quizButtonAspectRatio,
                                children: List.generate(_options.length, (index) {
                                  final colorData = _options[index];
                                  final color = colorData['color'] as Color;

                                  return GestureDetector(
                                    onTap: () => _handleAnswer(index),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(responsive.spacing(20)),
                                        border: Border.all(
                                          color: _getButtonBorderColor(index),
                                          width: _getButtonBorderWidth(index),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: color.withOpacity(0.5),
                                            blurRadius: responsive.spacing(15),
                                            offset: Offset(0, responsive.spacing(6)),
                                          ),
                                        ],
                                      ),
                                      child: color == Colors.white
                                          ? Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(responsive.spacing(18)),
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                  width: responsive.spacing(2),
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                  );
                                }),
                              ),
                            ),

                            SizedBox(height: responsive.verticalSpacing),

                            // כפתורים - האזנה וסיום
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: responsive.horizontalSpacing,
                                vertical: responsive.spacing(8)
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: KidButton(
                                        text: isHebrew ? 'הקשב 🔊' : 'Listen 🔊',
                                        icon: Icons.volume_up,
                                        onPressed: _speakQuestion,
                                        color: Colors.purple.shade400,
                                        height: 60,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: KidButton(
                                        text: isHebrew ? 'סיום 🏁' : 'Finish 🏁',
                                        icon: Icons.check_circle,
                                        onPressed: _showFinalScore,
                                        color: Colors.red,
                                        height: 60,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // הודעת נכון (ללא כפתורים - עובר אוטומטית)
                            if (_isCorrect == true)
                              Padding(
                                padding: EdgeInsets.only(bottom: responsive.spacing(16)),
                                child: Text(
                                  l10n.correct,
                                  style: TextStyle(
                                    fontSize: responsive.questionTextSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              )
                            else
                              SizedBox(height: responsive.spacing(16)),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),

          // אנימציית פרס
          if (_showReward)
            Positioned.fill(
              child: RewardAnimation(
                onComplete: () {
                  setState(() {
                    _showReward = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showFinalScore() {
    final l10n = AppLocalizations.of(context)!;
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          isHebrew ? '🎉 כל הכבוד! 🎉' : '🎉 Well Done! 🎉',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isHebrew ? 'סיימת את החידון!' : 'You finished the quiz!',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              isHebrew ? 'תשובות נכונות:' : 'Correct answers:',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              '$_correctAnswers',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isHebrew ? 'כוכבים:' : 'Stars:',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              '⭐ $_score',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(isHebrew ? 'חזרה לתפריט' : 'Back to Menu'),
          ),
        ],
      ),
    );
  }
}
