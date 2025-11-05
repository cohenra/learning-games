import 'package:flutter/material.dart';
import '../../widgets/kid_button.dart';
import 'shapes_learning_screen.dart';
import 'shapes_quiz_screen.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// מסך תפריט מודול הצורות
class ShapesMenuScreen extends StatelessWidget {
  const ShapesMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shapesTitle),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Container(
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // אייקון
                const Text(
                  '⭐',
                  style: TextStyle(fontSize: 120),
                ),
                const SizedBox(height: 20),

                // כותרת
                Text(
                  l10n.shapesTitle,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
                const SizedBox(height: 16),

                // תיאור
                Text(
                  l10n.shapesDescription,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 60),

                // כפתור מצב למידה
                KidButton(
                  text: l10n.learnMode,
                  icon: Icons.school,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ShapesLearningScreen(),
                      ),
                    );
                  },
                  color: Colors.blue.shade500,
                  width: 300,
                  height: 90,
                ),
                const SizedBox(height: 24),

                // כפתור מצב חידון
                KidButton(
                  text: l10n.quizMode,
                  icon: Icons.gamepad,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ShapesQuizScreen(),
                      ),
                    );
                  },
                  color: Colors.green.shade500,
                  width: 300,
                  height: 90,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
