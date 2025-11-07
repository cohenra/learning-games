import 'package:flutter/material.dart';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';
import 'fruits_vegetables_learning_screen.dart';
import 'fruits_vegetables_matching_game.dart';

/// מסך תפריט פירות וירקות
class FruitsVegetablesMenuScreen extends StatelessWidget {
  const FruitsVegetablesMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';

    return Scaffold(
      appBar: AppBar(
        title: Text(isHebrew ? 'פירות וירקות 🍎🥕' : 'Fruits & Vegetables 🍎🥕'),
        centerTitle: true,
        backgroundColor: Colors.orange,
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
              Colors.yellow.shade50,
              Colors.orange.shade50,
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
                          '🍎🥕',
                          style: TextStyle(fontSize: responsive.emojiSize * 0.7),
                        ),
                        const SizedBox(height: 8),

                        // כותרת
                        Text(
                          isHebrew ? 'פירות וירקות' : 'Fruits & Vegetables',
                          style: TextStyle(
                            fontSize: responsive.titleSize * 0.9,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // תיאור
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            isHebrew
                                ? 'למדו על פירות וירקות שונים'
                                : 'Learn about different fruits and vegetables',
                            style: TextStyle(
                              fontSize: responsive.subtitleSize * 0.85,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // כפתורים
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var button in buttons)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                  child: KidButton(
                                    text: button['text']!,
                                    icon: button['icon'] as IconData,
                                    onPressed: button['onPressed'] as VoidCallback,
                                    color: button['color'] as Color,
                                    height: buttonHeight,
                                  ),
                                ),
                            ],
                          ),
                        ),

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
        'text': isHebrew ? 'זמן למידה 📚' : 'Learning Time 📚',
        'icon': Icons.school,
        'color': Colors.green,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FruitsVegetablesLearningScreen(),
            ),
          );
        },
      },
      {
        'text': isHebrew ? 'משחק התאמה 🎮' : 'Matching Game 🎮',
        'icon': Icons.extension,
        'color': Colors.orange,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FruitsVegetablesMatchingGame(),
            ),
          );
        },
      },
    ];
  }
}
