import 'package:flutter/material.dart';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';
import 'letters_learning_screen.dart';
import 'letters_quiz_screen.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// מסך תפריט מודול האותיות
class LettersMenuScreen extends StatelessWidget {
  const LettersMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final responsive = ResponsiveHelper(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.lettersTitle),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: responsive.verticalSpacing),

                        // אייקון
                        Text(
                          '🔤',
                          style: TextStyle(fontSize: responsive.emojiSize),
                        ),
                        SizedBox(height: responsive.verticalSpacing),

                        // כותרת
                        Text(
                          l10n.lettersTitle,
                          style: TextStyle(
                            fontSize: responsive.titleSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        SizedBox(height: responsive.spacing(16)),

                        // תיאור
                        Padding(
                          padding: responsive.safePadding,
                          child: Text(
                            l10n.lettersDescription,
                            style: TextStyle(
                              fontSize: responsive.subtitleSize,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: responsive.spacing(40)),

                        // כפתור מצב למידה
                        Padding(
                          padding: responsive.safePadding,
                          child: KidButton(
                            text: l10n.learnMode,
                            icon: Icons.school,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LettersLearningScreen(),
                                ),
                              );
                            },
                            color: Colors.blue.shade500,
                            width: responsive.width(80),
                            height: responsive.buttonHeight,
                          ),
                        ),
                        SizedBox(height: responsive.verticalSpacing),

                        // כפתור מצב חידון
                        Padding(
                          padding: responsive.safePadding,
                          child: KidButton(
                            text: l10n.quizMode,
                            icon: Icons.gamepad,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LettersQuizScreen(),
                                ),
                              );
                            },
                            color: Colors.green.shade500,
                            width: responsive.width(80),
                            height: responsive.buttonHeight,
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
    );
  }
}
