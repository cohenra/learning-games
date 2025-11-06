import 'package:flutter/material.dart';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';
import 'colors_learning_screen.dart';
import 'colors_quiz_screen.dart';
import 'colors_sorting_game_screen.dart';
import 'colors_odd_one_out_game_screen.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// מסך תפריט מודול הצבעים
class ColorsMenuScreen extends StatelessWidget {
  const ColorsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final responsive = ResponsiveHelper(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.colorsTitle),
        centerTitle: true,
        backgroundColor: Colors.pink,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.pink.shade50,
              Colors.purple.shade50,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // רשימת כל הכפתורים
              final buttons = _getButtons(context, l10n);

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
              final totalSpacing = (numButtons - 1) * 8.0; // 8px בין כפתורים
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
                          '🎨',
                          style: TextStyle(fontSize: responsive.emojiSize * 0.7),
                        ),
                        const SizedBox(height: 8),

                        // כותרת
                        Text(
                          l10n.colorsTitle,
                          style: TextStyle(
                            fontSize: responsive.titleSize * 0.9,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // תיאור
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            l10n.colorsDescription,
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

  List<Map<String, dynamic>> _getButtons(BuildContext context, AppLocalizations l10n) {
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';

    return [
      {
        'text': l10n.learnMode,
        'icon': Icons.school,
        'color': Colors.blue.shade500,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ColorsLearningScreen(),
            ),
          );
        },
      },
      {
        'text': l10n.quizMode,
        'icon': Icons.gamepad,
        'color': Colors.green.shade500,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ColorsQuizScreen(),
            ),
          );
        },
      },
      {
        'text': isHebrew ? 'משחק מיון 🎯' : 'Sorting Game 🎯',
        'icon': Icons.sort,
        'color': Colors.orange.shade500,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ColorsSortingGameScreen(),
            ),
          );
        },
      },
      {
        'text': isHebrew ? 'מצא את השונה 🔍' : 'Find the Odd One 🔍',
        'icon': Icons.search,
        'color': Colors.purple.shade500,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ColorsOddOneOutGameScreen(),
            ),
          );
        },
      },
    ];
  }
}
