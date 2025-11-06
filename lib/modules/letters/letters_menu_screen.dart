import 'package:flutter/material.dart';
import '../../widgets/kid_button.dart';
import 'letters_learning_screen.dart';
import 'letters_quiz_screen.dart';
import 'letters_memory_game_screen.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// מסך תפריט מודול האותיות
class LettersMenuScreen extends StatelessWidget {
  const LettersMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // אייקון
                const Text(
                  '🔤',
                  style: TextStyle(fontSize: 120),
                ),
                const SizedBox(height: 20),

                // כותרת
                Text(
                  l10n.lettersTitle,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 16),

                // תיאור
                Text(
                  l10n.lettersDescription,
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
                        builder: (context) => const LettersLearningScreen(),
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
                        builder: (context) => const LettersQuizScreen(),
                      ),
                    );
                  },
                  color: Colors.green.shade500,
                  width: 300,
                  height: 90,
                ),
                const SizedBox(height: 24),

                // כפתור משחק זיכרון
                KidButton(
                  text: Localizations.localeOf(context).languageCode == 'he'
                      ? 'משחק זיכרון 🎮'
                      : 'Memory Game 🎮',
                  icon: Icons.extension,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LettersMemoryGameScreen(),
                      ),
                    );
                  },
                  color: Colors.purple.shade500,
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