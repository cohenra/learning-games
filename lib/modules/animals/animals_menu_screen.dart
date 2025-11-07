import 'package:flutter/material.dart';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';
import 'animals_learning_screen.dart';
import 'animals_quiz_screen.dart';

/// מסך תפריט מודול בעלי חיים
class AnimalsMenuScreen extends StatelessWidget {
  const AnimalsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';

    return Scaffold(
      appBar: AppBar(
        title: Text(isHebrew ? 'בעלי חיים 🐾' : 'Animals 🐾'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50,
              Colors.blue.shade50,
              Colors.yellow.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // רשימת כל הכפתורים
              final buttons = _getButtons(context, isHebrew);

              // חישוב גובה זמין
              final availableHeight = constraints.maxHeight;
              final numButtons = buttons.length;

              // רווחים: אייקון + כותרת + תיאור + כפתורים
              const iconHeight = 60.0;
              const titleHeight = 40.0;
              const descriptionHeight = 60.0;
              const topBottomPadding = 40.0;

              final usedHeight = iconHeight + titleHeight + descriptionHeight + topBottomPadding;
              final availableForButtons = availableHeight - usedHeight;

              // חישוב גובה כפתור ורווח
              final totalSpacing = (numButtons - 1) * 8.0;
              final buttonHeight = ((availableForButtons - totalSpacing) / numButtons).clamp(50.0, responsive.buttonHeight);

              return SingleChildScrollView(
                physics: numButtons <= 5 ? const NeverScrollableScrollPhysics() : null,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),

                        // אייקון
                        Text(
                          '🐾',
                          style: TextStyle(fontSize: responsive.emojiSize * 0.7),
                        ),
                        const SizedBox(height: 8),

                        // כותרת
                        Text(
                          isHebrew ? 'בעלי חיים' : 'Animals',
                          style: TextStyle(
                            fontSize: responsive.titleSize * 0.9,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // תיאור
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            isHebrew
                                ? 'למדו על בעלי חיים שונים'
                                : 'Learn about different animals',
                            style: TextStyle(
                              fontSize: responsive.subtitleSize * 0.85,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // כפתורים
                        ...buttons.map((buttonData) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: responsive.safePadding,
                              child: KidButton(
                                text: buttonData['text'] as String,
                                icon: buttonData['icon'] as IconData,
                                onPressed: buttonData['onPressed'] as VoidCallback,
                                color: buttonData['color'] as Color,
                                width: responsive.width(80),
                                height: buttonHeight,
                              ),
                            ),
                          );
                        }).toList(),

                        const SizedBox(height: 8),
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

  List<Map<String, dynamic>> _getButtons(BuildContext context, bool isHebrew) {
    return [
      {
        'text': isHebrew ? 'למידה 📚' : 'Learning 📚',
        'icon': Icons.school,
        'color': Colors.blue.shade500,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AnimalsLearningScreen(),
            ),
          );
        },
      },
      {
        'text': isHebrew ? 'חידון 🎮' : 'Quiz 🎮',
        'icon': Icons.gamepad,
        'color': Colors.green.shade500,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AnimalsQuizScreen(),
            ),
          );
        },
      },
    ];
  }
}
