import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// מסך למידת מספרים - מציג מספר אחד בכל פעם עם ייצוג ויזואלי
class NumbersLearningScreen extends StatefulWidget {
  const NumbersLearningScreen({super.key});

  @override
  State<NumbersLearningScreen> createState() => _NumbersLearningScreenState();
}

class _NumbersLearningScreenState extends State<NumbersLearningScreen>
    with SingleTickerProviderStateMixin {
  int _currentNumber = 1;
  late AnimationController _animationController;

  final List<String> _numberKeys = [
    'numberOne',
    'numberTwo',
    'numberThree',
    'numberFour',
    'numberFive',
    'numberSix',
    'numberSeven',
    'numberEight',
    'numberNine',
    'numberTen',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animationController.forward();

    // דבר את המספר בהתחלה
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentNumber();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _speakCurrentNumber() {
    final appProvider = context.read<AppProvider>();
    final l10n = AppLocalizations.of(context)!;

    // קבל את שם המספר בשפה הנוכחית
    final numberName = _getNumberName(l10n);
    appProvider.speak(numberName);
  }

  String _getNumberName(AppLocalizations l10n) {
    switch (_currentNumber) {
      case 1:
        return l10n.numberOne;
      case 2:
        return l10n.numberTwo;
      case 3:
        return l10n.numberThree;
      case 4:
        return l10n.numberFour;
      case 5:
        return l10n.numberFive;
      case 6:
        return l10n.numberSix;
      case 7:
        return l10n.numberSeven;
      case 8:
        return l10n.numberEight;
      case 9:
        return l10n.numberNine;
      case 10:
        return l10n.numberTen;
      default:
        return '';
    }
  }

  void _goToNext() {
    if (_currentNumber < 10) {
      setState(() {
        _currentNumber++;
      });
      _animationController.reset();
      _animationController.forward();
      _speakCurrentNumber();
    }
  }

  void _goToPrevious() {
    if (_currentNumber > 1) {
      setState(() {
        _currentNumber--;
      });
      _animationController.reset();
      _animationController.forward();
      _speakCurrentNumber();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';
    final responsive = ResponsiveHelper(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.learnMode),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // המספר הגדול
              ScaleTransition(
                scale: CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.elasticOut,
                ),
                child: GestureDetector(
                  onTap: _speakCurrentNumber,
                  child: Text(
                    '$_currentNumber',
                    style: TextStyle(
                      fontSize: responsive.fontSize(180),
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                      shadows: [
                        Shadow(
                          color: Colors.orange.shade200,
                          blurRadius: responsive.spacing(20),
                          offset: Offset(0, responsive.spacing(4)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // שם המספר
              FadeTransition(
                opacity: _animationController,
                child: Text(
                  _getNumberName(l10n),
                  style: TextStyle(
                    fontSize: responsive.fontSize(48),
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),

              // ייצוג ויזואלי - נקודות
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: responsive.spacing(12),
                  runSpacing: responsive.spacing(12),
                  children: List.generate(
                    _currentNumber,
                    (index) => SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            index * 0.1,
                            (index + 1) * 0.1,
                            curve: Curves.easeOut,
                          ),
                        ),
                      ),
                      child: Container(
                        width: responsive.iconSize(60),
                        height: responsive.iconSize(60),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade400,
                              Colors.orange.shade600,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.shade300,
                              blurRadius: responsive.spacing(8),
                              offset: Offset(0, responsive.spacing(4)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // כפתורי ניווט
              Padding(
                padding: responsive.safePadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    KidButton(
                      text: l10n.back,
                      onPressed: _goToPrevious,
                      enabled: _currentNumber > 1,
                      color: Colors.blue.shade400,
                      width: responsive.width(35),
                    ),
                    KidButton(
                      text: isHebrew ? 'הקשב 🔊' : 'Listen 🔊',
                      onPressed: _speakCurrentNumber,
                      color: Colors.green.shade400,
                      width: responsive.width(35),
                    ),
                    KidButton(
                      text: l10n.next,
                      onPressed: _goToNext,
                      enabled: _currentNumber < 10,
                      color: Colors.blue.shade400,
                      width: responsive.width(35),
                    ),
                  ],
                ),
              ),

              // אינדיקטור התקדמות
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  10,
                  (index) => Container(
                    width: responsive.iconSize(12),
                    height: responsive.iconSize(12),
                    margin: EdgeInsets.symmetric(horizontal: responsive.spacing(4)),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index + 1 == _currentNumber
                          ? Colors.orange.shade600
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              SizedBox(height: responsive.verticalSpacing),
            ],
          ),
        ),
      ),
    );
  }
}
