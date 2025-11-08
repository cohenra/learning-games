import 'package:flutter/material.dart';
import 'dart:math';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';
import 'numbers_learning_screen.dart';
import 'numbers_quiz_screen.dart';
import 'numbers_word_quiz_screen.dart';
import 'numbers_sorting_game.dart';
import 'numbers_compare_game.dart';
import 'number_tracing_screen.dart';
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
        width: double.infinity,
        height: double.infinity,
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              // רשימת כל הכפתורים
              final buttons = _getButtons(context, l10n);

              // חישוב גובה זמין - עכשיו עם 2 כפתורים בשורה
              final availableHeight = constraints.maxHeight;
              final numRows = (buttons.length / 2).ceil(); // Number of rows needed

              // רווחים: אייקון + כותרת + תיאור + כפתורים
              const iconHeight = 60.0;
              const titleHeight = 40.0;
              const descriptionHeight = 60.0;
              const topBottomPadding = 40.0;

              final usedHeight = iconHeight + titleHeight + descriptionHeight + topBottomPadding;
              final availableForButtons = availableHeight - usedHeight;

              // חישוב גובה כפתור ורווח - מחושב לפי מספר שורות ולא מספר כפתורים
              final totalSpacing = (numRows - 1) * 8.0; // 8px בין שורות
              final buttonHeight = ((availableForButtons - totalSpacing) / numRows).clamp(60.0, responsive.buttonHeight);

              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(), // No scrolling needed with 2-column layout
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),

                        // אייקון
                        Text(
                          '🔢',
                          style: TextStyle(fontSize: responsive.emojiSize * 0.7),
                        ),
                        const SizedBox(height: 8),

                        // כותרת
                        Text(
                          l10n.numbersTitle,
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
                            l10n.numbersDescription,
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

                        // כפתורים - 2 בשורה
                        ...List.generate(numRows, (rowIndex) {
                          final startIndex = rowIndex * 2;
                          final endIndex = min(startIndex + 2, buttons.length);
                          final rowButtons = buttons.sublist(startIndex, endIndex);

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: 8,
                              left: responsive.spacing(12),
                              right: responsive.spacing(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: rowButtons.map((buttonData) {
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: KidButton(
                                      text: buttonData['text'] as String,
                                      icon: buttonData['icon'] as IconData,
                                      onPressed: buttonData['onPressed'] as VoidCallback,
                                      color: buttonData['color'] as Color,
                                      height: buttonHeight,
                                    ),
                                  ),
                                );
                              }).toList(),
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
              builder: (context) => const NumbersLearningScreen(),
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
              builder: (context) => const NumbersQuizScreen(),
            ),
          );
        },
      },
      {
        'text': l10n.wordQuizMode,
        'icon': Icons.abc,
        'color': Colors.purple.shade500,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NumbersWordQuizScreen(),
            ),
          );
        },
      },
      {
        'text': isHebrew ? 'מיון מספרים 🔢' : 'Number Sorting 🔢',
        'icon': Icons.sort,
        'color': Colors.teal.shade500,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NumbersSortingGame(),
            ),
          );
        },
      },
      {
        'text': isHebrew ? 'מי גדול יותר? ⚖️' : 'Which is Bigger? ⚖️',
        'icon': Icons.compare_arrows,
        'color': Colors.deepOrange.shade500,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NumbersCompareGame(),
            ),
          );
        },
      },
      {
        'text': isHebrew ? 'תרגול כתיבה ✍️' : 'Number Tracing ✍️',
        'icon': Icons.edit,
        'color': Colors.indigo.shade500,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NumberTracingScreen(),
            ),
          );
        },
      },
    ];
  }
}
