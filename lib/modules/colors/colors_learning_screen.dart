import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/kid_button.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// מסך למידת צבעים - מציג צבע אחד בכל פעם עם ייצוג ויזואלי
class ColorsLearningScreen extends StatefulWidget {
  const ColorsLearningScreen({super.key});

  @override
  State<ColorsLearningScreen> createState() => _ColorsLearningScreenState();
}

class _ColorsLearningScreenState extends State<ColorsLearningScreen>
    with SingleTickerProviderStateMixin {
  int _currentColorIndex = 0;
  late AnimationController _animationController;

  // 10 צבעים
  final List<Map<String, dynamic>> _colors = [
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
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animationController.forward();

    // דבר את הצבע בהתחלה
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentColor();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _speakCurrentColor() {
    final appProvider = context.read<AppProvider>();
    final l10n = AppLocalizations.of(context)!;

    // קבל את שם הצבע בשפה הנוכחית
    final colorName = _getColorName(l10n);
    appProvider.speak(colorName);
  }

  String _getColorName(AppLocalizations l10n) {
    final colorKey = _colors[_currentColorIndex]['name'] as String;
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

  Color _getCurrentColor() {
    return _colors[_currentColorIndex]['color'] as Color;
  }

  void _goToNext() {
    if (_currentColorIndex < _colors.length - 1) {
      setState(() {
        _currentColorIndex++;
      });
      _animationController.reset();
      _animationController.forward();
      _speakCurrentColor();
    }
  }

  void _goToPrevious() {
    if (_currentColorIndex > 0) {
      setState(() {
        _currentColorIndex--;
      });
      _animationController.reset();
      _animationController.forward();
      _speakCurrentColor();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';
    final currentColor = _getCurrentColor();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.learnMode),
        centerTitle: true,
        backgroundColor: Colors.pink,
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
              const SizedBox(height: 20),

              // שם הצבע בחלק העליון
              FadeTransition(
                opacity: _animationController,
                child: Text(
                  _getColorName(l10n),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),

              // הריבוע הצבעוני הגדול
              ScaleTransition(
                scale: CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.elasticOut,
                ),
                child: GestureDetector(
                  onTap: _speakCurrentColor,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: currentColor,
                      borderRadius: BorderRadius.circular(30),
                      border: currentColor == Colors.white
                          ? Border.all(color: Colors.grey.shade400, width: 3)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: currentColor.withOpacity(0.5),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // כפתורי ניווט
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    KidButton(
                      text: l10n.back,
                      onPressed: _goToPrevious,
                      enabled: _currentColorIndex > 0,
                      color: Colors.blue.shade400,
                      width: 140,
                    ),
                    KidButton(
                      text: isHebrew ? 'הקשב 🔊' : 'Listen 🔊',
                      onPressed: _speakCurrentColor,
                      color: Colors.green.shade400,
                      width: 140,
                    ),
                    KidButton(
                      text: l10n.next,
                      onPressed: _goToNext,
                      enabled: _currentColorIndex < _colors.length - 1,
                      color: Colors.blue.shade400,
                      width: 140,
                    ),
                  ],
                ),
              ),

              // אינדיקטור התקדמות
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _colors.length,
                  (index) => Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentColorIndex
                          ? Colors.pink.shade600
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
