import 'package:flutter/material.dart';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';
import 'numbers_learning_screen.dart';
import 'numbers_quiz_screen.dart';
import 'numbers_word_quiz_screen.dart';
import 'numbers_sorting_game.dart';
import 'numbers_compare_game.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// מסך תפריט מודול המספרים
class NumbersMenuScreen extends StatelessWidget {
  const NumbersMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final responsive = ResponsiveHelper(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.numbersTitle),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Container(
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
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: responsive.verticalSpacing),

                  // אייקון
                  Text(
                    '🔢',
                    style: TextStyle(fontSize: responsive.emojiSize),
                  ),
                  SizedBox(height: responsive.verticalSpacing),

                  // כותרת
                  Text(
                    l10n.numbersTitle,
                    style: TextStyle(
                      fontSize: responsive.titleSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  SizedBox(height: responsive.spacing(16)),

                  // תיאור
                  Padding(
                    padding: responsive.safePadding,
                    child: Text(
                      l10n.numbersDescription,
                      style: TextStyle(
                        fontSize: responsive.subtitleSize,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: responsive.spacing(40)),

                  // שורה ראשונה - 3 כפתורים
                  Padding(
                    padding: responsive.safePadding,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // כפתור מצב למידה
                      Expanded(
                        child: KidButton(
                          text: l10n.learnMode,
                          icon: Icons.school,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NumbersLearningScreen(),
                              ),
                            );
                          },
                          color: Colors.blue.shade500,
                          height: responsive.buttonHeight,
                        ),
                      ),
                      SizedBox(width: responsive.horizontalSpacing),

                      // כפתור מצב חידון
                      Expanded(
                        child: KidButton(
                          text: l10n.quizMode,
                          icon: Icons.gamepad,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NumbersQuizScreen(),
                              ),
                            );
                          },
                          color: Colors.green.shade500,
                          height: responsive.buttonHeight,
                        ),
                      ),
                      SizedBox(width: responsive.horizontalSpacing),

                      // כפתור חידון מילים
                      Expanded(
                        child: KidButton(
                          text: l10n.wordQuizMode,
                          icon: Icons.abc,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NumbersWordQuizScreen(),
                              ),
                            );
                          },
                          color: Colors.purple.shade500,
                          height: responsive.buttonHeight,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: responsive.verticalSpacing),

                // שורה שנייה - 2 משחקים
                Padding(
                  padding: responsive.safePadding,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // כפתור מיון מספרים
                      Expanded(
                        child: KidButton(
                          text: Localizations.localeOf(context).languageCode == 'he'
                              ? 'מיון מספרים'
                              : 'Number Sorting',
                          icon: Icons.sort,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NumbersSortingGame(),
                              ),
                            );
                          },
                          color: Colors.teal.shade500,
                          height: responsive.buttonHeight,
                        ),
                      ),
                      SizedBox(width: responsive.horizontalSpacing),

                      // כפתור השוואת מספרים
                      Expanded(
                        child: KidButton(
                          text: Localizations.localeOf(context).languageCode == 'he'
                              ? 'מי גדול יותר?'
                              : 'Which is Bigger?',
                          icon: Icons.compare_arrows,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NumbersCompareGame(),
                              ),
                            );
                          },
                          color: Colors.deepOrange.shade500,
                          height: responsive.buttonHeight,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: responsive.verticalSpacing),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
