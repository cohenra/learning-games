import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/kid_button.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// מסך למידת אותיות - מציג אות אחת בכל פעם
class LettersLearningScreen extends StatefulWidget {
  const LettersLearningScreen({super.key});

  @override
  State<LettersLearningScreen> createState() => _LettersLearningScreenState();
}

class _LettersLearningScreenState extends State<LettersLearningScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;

  // רשימת 22 האותיות העבריות
  final List<Map<String, dynamic>> _letters = [
    {'letter': 'א', 'key': 'letterAlef', 'color': Colors.red},
    {'letter': 'ב', 'key': 'letterBet', 'color': Colors.blue},
    {'letter': 'ג', 'key': 'letterGimel', 'color': Colors.green},
    {'letter': 'ד', 'key': 'letterDalet', 'color': Colors.orange},
    {'letter': 'ה', 'key': 'letterHey', 'color': Colors.purple},
    {'letter': 'ו', 'key': 'letterVav', 'color': Colors.pink},
    {'letter': 'ז', 'key': 'letterZayin', 'color': Colors.teal},
    {'letter': 'ח', 'key': 'letterChet', 'color': Colors.amber},
    {'letter': 'ט', 'key': 'letterTet', 'color': Colors.cyan},
    {'letter': 'י', 'key': 'letterYod', 'color': Colors.lime},
    {'letter': 'כ', 'key': 'letterKaf', 'color': Colors.indigo},
    {'letter': 'ל', 'key': 'letterLamed', 'color': Colors.deepOrange},
    {'letter': 'מ', 'key': 'letterMem', 'color': Colors.lightGreen},
    {'letter': 'נ', 'key': 'letterNun', 'color': Colors.deepPurple},
    {'letter': 'ס', 'key': 'letterSamech', 'color': Colors.brown},
    {'letter': 'ע', 'key': 'letterAyin', 'color': Colors.blueGrey},
    {'letter': 'פ', 'key': 'letterPey', 'color': Colors.redAccent},
    {'letter': 'צ', 'key': 'letterTzadi', 'color': Colors.lightBlue},
    {'letter': 'ק', 'key': 'letterKof', 'color': Colors.greenAccent},
    {'letter': 'ר', 'key': 'letterResh', 'color': Colors.orangeAccent},
    {'letter': 'ש', 'key': 'letterShin', 'color': Colors.purpleAccent},
    {'letter': 'ת', 'key': 'letterTav', 'color': Colors.pinkAccent},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animationController.forward();

    // דבר את האות בהתחלה
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentLetter();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _speakCurrentLetter() {
    final appProvider = context.read<AppProvider>();
    final l10n = AppLocalizations.of(context)!;

    // קבל את שם האות בשפה הנוכחית
    final letterName = _getLetterName(l10n);
    appProvider.speak(letterName);
  }

  String _getLetterName(AppLocalizations l10n) {
    final key = _letters[_currentIndex]['key'] as String;

    switch (key) {
      case 'letterAlef': return l10n.letterAlef;
      case 'letterBet': return l10n.letterBet;
      case 'letterGimel': return l10n.letterGimel;
      case 'letterDalet': return l10n.letterDalet;
      case 'letterHey': return l10n.letterHey;
      case 'letterVav': return l10n.letterVav;
      case 'letterZayin': return l10n.letterZayin;
      case 'letterChet': return l10n.letterChet;
      case 'letterTet': return l10n.letterTet;
      case 'letterYod': return l10n.letterYod;
      case 'letterKaf': return l10n.letterKaf;
      case 'letterLamed': return l10n.letterLamed;
      case 'letterMem': return l10n.letterMem;
      case 'letterNun': return l10n.letterNun;
      case 'letterSamech': return l10n.letterSamech;
      case 'letterAyin': return l10n.letterAyin;
      case 'letterPey': return l10n.letterPey;
      case 'letterTzadi': return l10n.letterTzadi;
      case 'letterKof': return l10n.letterKof;
      case 'letterResh': return l10n.letterResh;
      case 'letterShin': return l10n.letterShin;
      case 'letterTav': return l10n.letterTav;
      default: return '';
    }
  }

  void _goToNext() {
    if (_currentIndex < _letters.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _animationController.reset();
      _animationController.forward();
      _speakCurrentLetter();
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _animationController.reset();
      _animationController.forward();
      _speakCurrentLetter();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';
    final currentLetter = _letters[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.learnMode),
        centerTitle: true,
        backgroundColor: Colors.blue,
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
              // האות הגדולה
              ScaleTransition(
                scale: CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.elasticOut,
                ),
                child: GestureDetector(
                  onTap: _speakCurrentLetter,
                  child: Text(
                    currentLetter['letter'] as String,
                    style: TextStyle(
                      fontSize: 180,
                      fontWeight: FontWeight.bold,
                      color: currentLetter['color'] as Color,
                      shadows: [
                        Shadow(
                          color: (currentLetter['color'] as Color).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // שם האות
              FadeTransition(
                opacity: _animationController,
                child: Text(
                  _getLetterName(l10n),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),

              // ייצוג ויזואלי - עיגול צבעוני גדול
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      (currentLetter['color'] as Color).withOpacity(0.3),
                      (currentLetter['color'] as Color).withOpacity(0.6),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (currentLetter['color'] as Color).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    currentLetter['letter'] as String,
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // כפתורי ניווט
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    KidButton(
                      text: l10n.back,
                      onPressed: _goToPrevious,
                      enabled: _currentIndex > 0,
                      color: Colors.blue.shade400,
                      width: 140,
                    ),
                    KidButton(
                      text: isHebrew ? 'הקשב 🔊' : 'Listen 🔊',
                      onPressed: _speakCurrentLetter,
                      color: Colors.green.shade400,
                      width: 140,
                    ),
                    KidButton(
                      text: l10n.next,
                      onPressed: _goToNext,
                      enabled: _currentIndex < _letters.length - 1,
                      color: Colors.blue.shade400,
                      width: 140,
                    ),
                  ],
                ),
              ),

              // אינדיקטור התקדמות
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: _letters.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentIndex
                            ? Colors.blue.shade600
                            : Colors.grey.shade300,
                      ),
                    );
                  },
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