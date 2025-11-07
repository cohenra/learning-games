import 'package:flutter/material.dart';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';
import 'instruments_learning_screen.dart';
import 'instruments_quiz_screen.dart';
import 'notes_learning_screen.dart';
import 'notes_quiz_screen.dart';
import 'rhythm_game_screen.dart';
import 'kids_songs_screen.dart';
import 'music_composer_screen.dart';

/// מסך תפריט מוזיקה
class MusicMenuScreen extends StatelessWidget {
  const MusicMenuScreen({super.key});

  List<Map<String, dynamic>> _getButtons(BuildContext context, bool isHebrew) {
    return [
      {
        'titleHe': 'כלי נגינה 🎸',
        'titleEn': 'Musical Instruments 🎸',
        'descriptionHe': 'למד על כלי נגינה שונים',
        'descriptionEn': 'Learn about different instruments',
        'icon': Icons.music_note,
        'color': Colors.purple,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InstrumentsLearningScreen(),
            ),
          );
        },
      },
      {
        'titleHe': 'חידון כלי נגינה 🎯',
        'titleEn': 'Instruments Quiz 🎯',
        'descriptionHe': 'בדוק את הידע שלך על כלי נגינה',
        'descriptionEn': 'Test your instruments knowledge',
        'icon': Icons.quiz,
        'color': Colors.orange,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InstrumentsQuizScreen(),
            ),
          );
        },
      },
      {
        'titleHe': 'תווים מוזיקליים 🎼',
        'titleEn': 'Musical Notes 🎼',
        'descriptionHe': 'למד את התווים המוזיקליים',
        'descriptionEn': 'Learn the musical notes',
        'icon': Icons.piano,
        'color': Colors.blue,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotesLearningScreen(),
            ),
          );
        },
      },
      {
        'titleHe': 'חידון תווים 🎯',
        'titleEn': 'Notes Quiz 🎯',
        'descriptionHe': 'בדוק את הידע שלך על תווים',
        'descriptionEn': 'Test your notes knowledge',
        'icon': Icons.quiz,
        'color': Colors.green,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotesQuizScreen(),
            ),
          );
        },
      },
      {
        'titleHe': 'משחק קצב 🥁',
        'titleEn': 'Rhythm Game 🥁',
        'descriptionHe': 'תרגל קצבים ושחזר אותם',
        'descriptionEn': 'Practice and repeat rhythms',
        'icon': Icons.graphic_eq,
        'color': Colors.red,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RhythmGameScreen(),
            ),
          );
        },
      },
      {
        'titleHe': 'יוצר מוזיקה 🎹',
        'titleEn': 'Music Composer 🎹',
        'descriptionHe': 'צור את המוזיקה שלך',
        'descriptionEn': 'Create your own music',
        'icon': Icons.piano,
        'color': Colors.teal,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MusicComposerScreen(),
            ),
          );
        },
      },
      // Kids Songs temporarily disabled - keeping code for future use
      // {
      //   'titleHe': 'שירי ילדים 🎤',
      //   'titleEn': 'Kids Songs 🎤',
      //   'descriptionHe': 'שמע שירים לילדים',
      //   'descriptionEn': 'Listen to kids songs',
      //   'icon': Icons.library_music,
      //   'color': Colors.pink,
      //   'onTap': () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => const KidsSongsScreen(),
      //       ),
      //     );
      //   },
      // },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade50,
              Colors.pink.shade50,
              Colors.orange.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final buttons = _getButtons(context, isHebrew);
              final availableHeight = constraints.maxHeight;
              final numButtons = buttons.length;

              // Calculate sizes
              const iconHeight = 60.0;
              const titleHeight = 40.0;
              const descriptionHeight = 60.0;
              const topBottomPadding = 40.0;

              final usedHeight = iconHeight + titleHeight + descriptionHeight + topBottomPadding;
              final availableForButtons = availableHeight - usedHeight;

              final totalSpacing = (numButtons - 1) * 8.0;
              final buttonHeight = ((availableForButtons - totalSpacing) / numButtons)
                  .clamp(50.0, responsive.buttonHeight);

              return Column(
                children: [
                  // Header with back button
                  Padding(
                    padding: EdgeInsets.all(responsive.spacing(12)),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isHebrew ? Icons.arrow_forward : Icons.arrow_back,
                            color: Colors.purple.shade700,
                            size: 32,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            isHebrew ? 'מוזיקה' : 'Music',
                            style: TextStyle(
                              fontSize: responsive.titleSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 48), // Balance
                      ],
                    ),
                  ),

                  // Icon
                  Text(
                    '🎵',
                    style: TextStyle(fontSize: responsive.iconSize(60)),
                  ),

                  SizedBox(height: responsive.spacing(8)),

                  // Description
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                    child: Text(
                      isHebrew
                          ? 'למד מוזיקה בדרך מהנה!'
                          : 'Learn Music the Fun Way!',
                      style: TextStyle(
                        fontSize: responsive.fontSize(18),
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),

                  SizedBox(height: responsive.spacing(20)),

                  // Buttons
                  Expanded(
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
                      itemCount: buttons.length,
                      itemBuilder: (context, index) {
                        final button = buttons[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index < buttons.length - 1 ? 8 : 0,
                          ),
                          child: KidButton(
                            text: isHebrew ? button['titleHe'] : button['titleEn'],
                            icon: button['icon'],
                            onPressed: button['onTap'],
                            color: button['color'],
                            height: buttonHeight,
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: responsive.spacing(12)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
