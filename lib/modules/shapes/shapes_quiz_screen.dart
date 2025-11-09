import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/kid_button.dart';
import '../../widgets/reward_animation.dart';
import '../../utils/responsive_helper.dart';
import 'package:learning_fun/generated/app_localizations.dart';
import 'shapes_learning_screen.dart';

/// מסך חידון צורות - שאלות אקראיות עם בחירה מרובה
class ShapesQuizScreen extends StatefulWidget {
  const ShapesQuizScreen({super.key});

  @override
  State<ShapesQuizScreen> createState() => _ShapesQuizScreenState();
}

class _ShapesQuizScreenState extends State<ShapesQuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;
  int? _selectedAnswer;
  bool? _isCorrect;
  bool _showReward = false;

  late int _correctAnswerIndex;
  late List<Map<String, dynamic>> _options;

  final Random _random = Random();

  // 8 צורות
  final List<Map<String, dynamic>> _allShapes = [
    {'key': 'shapeCircle', 'type': ShapeType.circle, 'color': Colors.red},
    {'key': 'shapeSquare', 'type': ShapeType.square, 'color': Colors.blue},
    {'key': 'shapeTriangle', 'type': ShapeType.triangle, 'color': Colors.green},
    {'key': 'shapeRectangle', 'type': ShapeType.rectangle, 'color': Colors.orange},
    {'key': 'shapeStar', 'type': ShapeType.star, 'color': Colors.purple},
    {'key': 'shapeHeart', 'type': ShapeType.heart, 'color': Colors.pink},
    {'key': 'shapeDiamond', 'type': ShapeType.diamond, 'color': Colors.teal},
    {'key': 'shapeOval', 'type': ShapeType.oval, 'color': Colors.amber},
  ];

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    setState(() {
      // בחר צורה נכונה אקראית
      _correctAnswerIndex = _random.nextInt(_allShapes.length);
      _options = [_allShapes[_correctAnswerIndex]];

      // הוסף 3 צורות שגויות
      while (_options.length < 4) {
        final wrongShapeIndex = _random.nextInt(_allShapes.length);
        final wrongShape = _allShapes[wrongShapeIndex];
        if (!_options.any((s) => s['key'] == wrongShape['key'])) {
          _options.add(wrongShape);
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
    final shapeName = _getShapeName(l10n, _allShapes[_correctAnswerIndex]['key']);

    // דבר "בחרו את העיגול" או "Select the circle"
    final question = l10n.selectTheShape(shapeName);
    appProvider.speak(question);
  }

  String _getShapeName(AppLocalizations l10n, String shapeKey) {
    switch (shapeKey) {
      case 'shapeCircle': return l10n.shapeCircle;
      case 'shapeSquare': return l10n.shapeSquare;
      case 'shapeTriangle': return l10n.shapeTriangle;
      case 'shapeRectangle': return l10n.shapeRectangle;
      case 'shapeStar': return l10n.shapeStar;
      case 'shapeHeart': return l10n.shapeHeart;
      case 'shapeDiamond': return l10n.shapeDiamond;
      case 'shapeOval': return l10n.shapeOval;
      default: return '';
    }
  }

  void _handleAnswer(int optionIndex) {
    // אם כבר ענו נכון, אל תאפשר לחיצות נוספות
    if (_isCorrect == true) return;

    final appProvider = context.read<AppProvider>();
    final selectedShapeKey = _options[optionIndex]['key'];
    final correctShapeKey = _allShapes[_correctAnswerIndex]['key'];
    final isCorrect = selectedShapeKey == correctShapeKey;

    setState(() {
      _selectedAnswer = optionIndex;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      // רק תשובות נכונות נספרות
      appProvider.recordAnswer('shapes', isCorrect);

      setState(() {
        _score++;
        _correctAnswers++;
        _showReward = true;
      });
      appProvider.addStar('shapes');

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

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final l10n = AppLocalizations.of(context)!;
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';
    final correctShapeName = _getShapeName(l10n, _allShapes[_correctAnswerIndex]['key']);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quizMode),
        centerTitle: true,
        backgroundColor: Colors.purple,
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
                  Colors.purple.shade50,
                  Colors.pink.shade50,
                  Colors.blue.shade50,
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
                                    ? 'שאלה ${_currentQuestionIndex + 1}'
                                    : 'Question ${_currentQuestionIndex + 1}',
                                style: TextStyle(
                                  fontSize: responsive.subtitleSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple.shade700,
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
                                  fontSize: responsive.subtitleSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: responsive.verticalSpacing),

                      // השאלה
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                        child: Text(
                          l10n.selectTheShape(correctShapeName),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: responsive.questionTextSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),

                      SizedBox(height: responsive.verticalSpacing * 1.5),

                      // אפשרויות תשובה - מלבנים עם צורות דקים כמו בחידון מספרים
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.spacing(20),
                            vertical: responsive.spacing(8),
                          ),
                          child: GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            mainAxisSpacing: responsive.spacing(8),
                            crossAxisSpacing: responsive.spacing(8),
                            childAspectRatio: responsive.quizButtonAspectRatio,
                            physics: const NeverScrollableScrollPhysics(),
                            children: List.generate(_options.length, (index) {
                              final shapeData = _options[index];
                              return GestureDetector(
                                onTap: () => _handleAnswer(index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(responsive.spacing(16)),
                                    border: Border.all(
                                      color: _getButtonBorderColor(index),
                                      width: _getButtonBorderWidth(index),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: SizedBox(
                                      width: responsive.iconSize(40),
                                      height: responsive.iconSize(40),
                                      child: CustomPaint(
                                        key: ValueKey('${shapeData['key']}_$index'),
                                        painter: ShapePainter(
                                          shapeType: shapeData['type'],
                                          color: shapeData['color'],
                                        ),
                                      ),
                                    ),
                                  ),
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
                                  text: isHebrew ? 'הקשב שוב 🔊' : 'Listen Again 🔊',
                                  icon: Icons.volume_up,
                                  onPressed: _speakQuestion,
                                  color: Colors.green.shade400,
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

                      SizedBox(height: responsive.verticalSpacing),
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
                                          ? 'שאלה ${_currentQuestionIndex + 1}'
                                          : 'Question ${_currentQuestionIndex + 1}',
                                      style: TextStyle(
                                        fontSize: responsive.subtitleSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple.shade700,
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
                                        fontSize: responsive.subtitleSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: responsive.verticalSpacing),

                            // השאלה
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                              child: Text(
                                l10n.selectTheShape(correctShapeName),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: responsive.questionTextSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),

                            SizedBox(height: responsive.verticalSpacing * 1.5),

                            // אפשרויות תשובה - מלבנים עם צורות דקים כמו בחידון מספרים
                            Container(
                              height: responsive.height(30),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: responsive.spacing(20),
                                  vertical: responsive.spacing(8),
                                ),
                                child: GridView.count(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: responsive.spacing(8),
                                  crossAxisSpacing: responsive.spacing(8),
                                  childAspectRatio: responsive.quizButtonAspectRatio,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: List.generate(_options.length, (index) {
                                    final shapeData = _options[index];
                                    return GestureDetector(
                                      onTap: () => _handleAnswer(index),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(responsive.spacing(16)),
                                          border: Border.all(
                                            color: _getButtonBorderColor(index),
                                            width: _getButtonBorderWidth(index),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: SizedBox(
                                            width: responsive.iconSize(40),
                                            height: responsive.iconSize(40),
                                            child: CustomPaint(
                                              key: ValueKey('${shapeData['key']}_$index'),
                                              painter: ShapePainter(
                                                shapeType: shapeData['type'],
                                                color: shapeData['color'],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
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
                                        text: isHebrew ? 'הקשב שוב 🔊' : 'Listen Again 🔊',
                                        icon: Icons.volume_up,
                                        onPressed: _speakQuestion,
                                        color: Colors.green.shade400,
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

                            SizedBox(height: responsive.verticalSpacing),
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
}
