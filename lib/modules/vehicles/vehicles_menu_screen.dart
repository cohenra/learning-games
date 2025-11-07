import 'package:flutter/material.dart';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';
import 'vehicles_learning_screen.dart';
import 'vehicles_matching_game.dart';

class VehiclesMenuScreen extends StatelessWidget {
  const VehiclesMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';

    return Scaffold(
      appBar: AppBar(
        title: Text(isHebrew ? 'כלי תחבורה 🚗✈️' : 'Vehicles 🚗✈️'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.cyan.shade50,
              Colors.lightBlue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final buttons = _getButtons(context, isHebrew);

              final availableHeight = constraints.maxHeight;
              final numButtons = buttons.length;

              const iconHeight = 60.0;
              const titleHeight = 40.0;
              const descriptionHeight = 60.0;
              const topBottomPadding = 40.0;

              final usedHeight = iconHeight + titleHeight + descriptionHeight + topBottomPadding;
              final availableForButtons = availableHeight - usedHeight;

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

                        Text(
                          '🚗✈️',
                          style: TextStyle(fontSize: responsive.emojiSize * 0.7),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          isHebrew ? 'כלי תחבורה' : 'Vehicles',
                          style: TextStyle(
                            fontSize: responsive.titleSize * 0.9,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            isHebrew
                                ? 'למדו על כלי תחבורה שונים'
                                : 'Learn about different vehicles',
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
              builder: (context) => const VehiclesLearningScreen(),
            ),
          );
        },
      },
      {
        'text': isHebrew ? 'משחק התאמה 🎮' : 'Matching Game 🎮',
        'icon': Icons.gamepad,
        'color': Colors.cyan.shade500,
        'onPressed': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VehiclesMatchingGame(),
            ),
          );
        },
      },
    ];
  }
}
