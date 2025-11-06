import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/kid_button.dart';
import '../../widgets/reward_animation.dart';
import '../../utils/responsive_helper.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// מסך חידון אותיות - שאלות אקראיות עם בחירה מרובה
class LettersQuizScreen extends StatefulWidget {
  const LettersQuizScreen({super.key});

  @override
  State<LettersQuizScreen> createState() => _LettersQuizScreenState();
}

class _LettersQuizScreenState extends State<LettersQuizScreen> {
  final int _totalQuestions = 5;
  int _currentQuestionIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool? _isCorrect;
  bool _showReward = false;

  late Map<String, dynamic> _correctAnswer;
  List<Map<String, dynamic>> _options = [];

  final Random _random = Random();

  // רשימת 22 האותיות העבריות
  final List<Map<String, dynamic>> _hebrewLetters = [
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

  // רשימת 26 האותיות האנגליות
  final List<Map<String, dynamic>> _englishLetters = [
    {'letter': 'A', 'key': 'letterA', 'color': Colors.red},
    {'letter': 'B', 'key': 'letterB', 'color': Colors.blue},
    {'letter': 'C', 'key': 'letterC', 'color': Colors.green},
    {'letter': 'D', 'key': 'letterD', 'color': Colors.orange},
    {'letter': 'E', 'key': 'letterE', 'color': Colors.purple},
    {'letter': 'F', 'key': 'letterF', 'color': Colors.pink},
    {'letter': 'G', 'key': 'letterG', 'color': Colors.teal},
    {'letter': 'H', 'key': 'letterH', 'color': Colors.amber},
    {'letter': 'I', 'key': 'letterI', 'color': Colors.cyan},
    {'letter': 'J', 'key': 'letterJ', 'color': Colors.lime},
    {'letter': 'K', 'key': 'letterK', 'color': Colors.indigo},
    {'letter': 'L', 'key': 'letterL', 'color': Colors.deepOrange},
    {'letter': 'M', 'key': 'letterM', 'color': Colors.lightGreen},
    {'letter': 'N', 'key': 'letterN', 'color': Colors.deepPurple},
    {'letter': 'O', 'key': 'letterO', 'color': Colors.brown},
    {'letter': 'P', 'key': 'letterP', 'color': Colors.blueGrey},
    {'letter': 'Q', 'key': 'letterQ', 'color': Colors.redAccent},
    {'letter': 'R', 'key': 'letterR', 'color': Colors.lightBlue},
    {'letter': 'S', 'key': 'letterS', 'color': Colors.greenAccent},
    {'letter': 'T', 'key': 'letterT', 'color': Colors.orangeAccent},
    {'letter': 'U', 'key': 'letterU', 'color': Colors.purpleAccent},
    {'letter': 'V', 'key': 'letterV', 'color': Colors.pinkAccent},
    {'letter': 'W', 'key': 'letterW', 'color': Colors.red.shade300},
    {'letter': 'X', 'key': 'letterX', 'color': Colors.blue.shade300},
    {'letter': 'Y', 'key': 'letterY', 'color': Colors.green.shade300},
    {'letter': 'Z', 'key': 'letterZ', 'color': Colors.orange.shade300},
  ];

  @override
  void initState() {
    super.initState();
    // _generateQuestion will be called in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_currentQuestionIndex == 0 && _options.isEmpty) {
      _generateQuestion();
    }
  }

  List<Map<String, dynamic>> _getCurrentLetters() {
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';
    return isHebrew ? _hebrewLetters : _englishLetters;
  }

  String _getLetterName(AppLocalizations l10n, String key, [String? letter]) {
    // עבור אותיות אנגליות, השתמש באות עצמה כשם
    if (key.startsWith('letter') && key.length == 7 && letter != null) {
      return letter;
    }

    // עבור אותיות עבריות, השתמש בשמות המלאים
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
      default: return letter ?? '';
    }
  }

  void _generateQuestion() {
    setState(() {
      final letters = _getCurrentLetters();
      _correctAnswer = letters[_random.nextInt(letters.length)];
      _options = [_correctAnswer];

      // הוסף 3 תשובות שגויות
      while (_options.length < 4) {
        final wrongOption = letters[_random.nextInt(letters.length)];
        if (!_options.any((opt) => opt['letter'] == wrongOption['letter'])) {
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
    final letterName = _getLetterName(l10n, _correctAnswer['key'], _correctAnswer['letter']);

    // דבר "בחרו את האות אלף" או "Select the letter A"
    final question = l10n.selectTheLetter(letterName);
    appProvider.speak(question);
  }

  void _handleAnswer(String answer) {
    // אם כבר ענו נכון, אל תאפשר לחיצות נוספות
    if (_isCorrect == true) return;

    final appProvider = context.read<AppProvider>();
    final l10n = AppLocalizations.of(context)!;
    final isCorrect = answer == _correctAnswer['letter'];

    setState(() {
      _selectedAnswer = answer;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      // רק תשובות נכונות נספרות
      appProvider.recordAnswer('letters', isCorrect);

      setState(() {
        _score++;
        _showReward = true;
      });
      appProvider.addStar('letters');

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

  Color _getButtonColor(String letter) {
    if (_selectedAnswer == null) {
      return Colors.blue.shade400;
    }

    // אם בחרו את האופציה הזו
    if (letter == _selectedAnswer) {
      if (_isCorrect == true) {
        return Colors.green.shade500; // נכון - ירוק
      } else {
        return Colors.red.shade500; // שגוי - אדום
      }
    }

    // כפתורים שלא נבחרו נשארים כחולים
    return Colors.blue.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final l10n = AppLocalizations.of(context)!;
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';
    final correctLetterName = _getLetterName(l10n, _correctAnswer['key'], _correctAnswer['letter']);

    if (_currentQuestionIndex >= _totalQuestions && _selectedAnswer != null) {
      return _buildCompletionScreen(l10n, isHebrew);
    }

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
                              '${l10n.question} ${_currentQuestionIndex + 1}/$_totalQuestions',
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

                      // שאלה - "בחרו את האות אלף"
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: responsive.horizontalSpacing),
                        child: GestureDetector(
                          onTap: _speakQuestion,
                          child: Text(
                            l10n.selectTheLetter(correctLetterName),
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

                      // אפשרויות תשובה - 4 אותיות בלבד (רק התווים, לא השמות)
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.horizontalSpacing,
                            vertical: responsive.spacing(8),
                          ),
                          child: GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            mainAxisSpacing: responsive.spacing(8),
                            crossAxisSpacing: responsive.spacing(8),
                            childAspectRatio: responsive.quizButtonAspectRatio,
                            physics: const NeverScrollableScrollPhysics(),
                            children: _options.map((option) {
                              final letter = option['letter'] as String;

                              return GestureDetector(
                                onTap: () => _handleAnswer(letter),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _getButtonColor(letter),
                                        _getButtonColor(letter).withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(responsive.spacing(20)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getButtonColor(letter).withOpacity(0.3),
                                        blurRadius: responsive.spacing(10),
                                        offset: Offset(0, responsive.spacing(6)),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          letter,
                                          style: TextStyle(
                                            fontSize: responsive.largeNumberSize,
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
                        ),
                      ),

                      SizedBox(height: responsive.spacing(32)),

                      // כפתור להאזנה לשאלה שוב
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: responsive.spacing(8)),
                        child: KidButton(
                          text: isHebrew ? 'הקשב 🔊' : 'Listen 🔊',
                          onPressed: _speakQuestion,
                          color: Colors.purple.shade400,
                          width: responsive.width(50),
                          height: responsive.buttonHeight * 0.7,
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
                                    '${l10n.question} ${_currentQuestionIndex + 1}/$_totalQuestions',
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

                            // שאלה - "בחרו את האות אלף"
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: responsive.horizontalSpacing),
                              child: GestureDetector(
                                onTap: _speakQuestion,
                                child: Text(
                                  l10n.selectTheLetter(correctLetterName),
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

                            // אפשרויות תשובה - 4 אותיות בלבד (רק התווים, לא השמות)
                            SizedBox(
                              height: responsive.height(20),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: responsive.horizontalSpacing,
                                  vertical: responsive.spacing(8),
                                ),
                                child: GridView.count(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: responsive.spacing(8),
                                  crossAxisSpacing: responsive.spacing(8),
                                  childAspectRatio: responsive.quizButtonAspectRatio,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: _options.map((option) {
                                    final letter = option['letter'] as String;

                                    return GestureDetector(
                                      onTap: () => _handleAnswer(letter),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              _getButtonColor(letter),
                                              _getButtonColor(letter).withOpacity(0.8),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(responsive.spacing(20)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _getButtonColor(letter).withOpacity(0.3),
                                              blurRadius: responsive.spacing(10),
                                              offset: Offset(0, responsive.spacing(6)),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                letter,
                                                style: TextStyle(
                                                  fontSize: responsive.largeNumberSize,
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
                                text: isHebrew ? 'הקשב 🔊' : 'Listen 🔊',
                                onPressed: _speakQuestion,
                                color: Colors.purple.shade400,
                                width: responsive.width(50),
                                height: responsive.buttonHeight * 0.7,
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
                  child: Padding(
                    padding: responsive.safePadding,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          SizedBox(height: responsive.height(10)),
                          Text(
                            l10n.wellDone,
                            style: TextStyle(
                              fontSize: responsive.titleSize * 1.3,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          SizedBox(height: responsive.spacing(40)),
                          Text(
                            '${l10n.score}: $_score / $_totalQuestions',
                            style: TextStyle(
                              fontSize: responsive.titleSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: responsive.spacing(40)),
                          Wrap(
                            children: List.generate(
                              _score,
                              (index) => Padding(
                                padding: EdgeInsets.all(responsive.spacing(8)),
                                child: Text('⭐', style: TextStyle(fontSize: responsive.emojiSize * 0.6)),
                              ),
                            ),
                          ),
                          SizedBox(height: responsive.spacing(60)),
                          KidButton(
                            text: l10n.playAgain,
                            onPressed: () {
                              setState(() {
                                _currentQuestionIndex = 0;
                                _score = 0;
                                _selectedAnswer = null;
                                _isCorrect = null;
                              });
                              _generateQuestion();
                            },
                            color: Colors.orange.shade500,
                            width: responsive.width(65),
                          ),
                          SizedBox(height: responsive.spacing(20)),
                          KidButton(
                            text: l10n.back,
                            onPressed: () => Navigator.pop(context),
                            color: Colors.blue.shade400,
                            width: responsive.width(65),
                          ),
                          SizedBox(height: responsive.height(5)),
                      ],
                    ),
                  ),
                );
              } else {
                // Phone: allow scrolling
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: Padding(
                        padding: responsive.safePadding,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: responsive.height(10)),
                            Text(
                              l10n.wellDone,
                              style: TextStyle(
                                fontSize: responsive.titleSize * 1.3,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                            SizedBox(height: responsive.spacing(40)),
                            Text(
                              '${l10n.score}: $_score / $_totalQuestions',
                              style: TextStyle(
                                fontSize: responsive.titleSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: responsive.spacing(40)),
                            Wrap(
                              children: List.generate(
                                _score,
                                (index) => Padding(
                                  padding: EdgeInsets.all(responsive.spacing(8)),
                                  child: Text('⭐', style: TextStyle(fontSize: responsive.emojiSize * 0.6)),
                                ),
                              ),
                            ),
                            SizedBox(height: responsive.spacing(60)),
                            KidButton(
                              text: l10n.playAgain,
                              onPressed: () {
                                setState(() {
                                  _currentQuestionIndex = 0;
                                  _score = 0;
                                  _selectedAnswer = null;
                                  _isCorrect = null;
                                });
                                _generateQuestion();
                              },
                              color: Colors.orange.shade500,
                              width: responsive.width(65),
                            ),
                            SizedBox(height: responsive.spacing(20)),
                            KidButton(
                              text: l10n.back,
                              onPressed: () => Navigator.pop(context),
                              color: Colors.blue.shade400,
                              width: responsive.width(65),
                            ),
                            SizedBox(height: responsive.height(5)),
                          ],
                        ),
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