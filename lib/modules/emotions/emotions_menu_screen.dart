import 'package:flutter/material.dart';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';
import 'emotions_learning_screen.dart';
import 'emotions_matching_game.dart';

class EmotionsMenuScreen extends StatelessWidget {
  const EmotionsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';

    return Scaffold(
      appBar: AppBar(
        title: Text(isHebrew ? 'רגשות 😊😢' : 'Emotions 😊😢'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.amber.shade50, Colors.amber.shade50, Colors.lightBlue.shade50],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final buttons = [
                {'text': isHebrew ? 'זמן למידה 📚' : 'Learning Time 📚', 'icon': Icons.school, 'color': Colors.amber, 'screen': const EmotionsLearningScreen()},
                {'text': isHebrew ? 'משחק התאמה 🎮' : 'Matching Game 🎮', 'icon': Icons.extension, 'color': Colors.amber, 'screen': const EmotionsMatchingGame()},
              ];

              final buttonHeight = ((constraints.maxHeight - 200) / buttons.length).clamp(50.0, 80.0);

              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('😊😢', style: TextStyle(fontSize: responsive.emojiSize * 0.7)),
                      const SizedBox(height: 8),
                      Text(isHebrew ? 'רגשות' : 'Emotions', style: TextStyle(fontSize: responsive.titleSize * 0.9, fontWeight: FontWeight.bold, color: Colors.amber.shade700)),
                      const SizedBox(height: 20),
                      for (var button in buttons)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          child: KidButton(
                            text: button['text'] as String,
                            icon: button['icon'] as IconData,
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => button['screen'] as Widget)),
                            color: button['color'] as Color,
                            height: buttonHeight,
                          ),
                        ),
                    ],
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
