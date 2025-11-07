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
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(responsive.spacing(12)),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isHebrew ? Icons.arrow_forward : Icons.arrow_back,
                        color: Colors.green.shade700,
                        size: 32,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        isHebrew ? 'פירות וירקות 🍎🥕' : 'Fruits & Vegetables 🍎🥕',
                        style: TextStyle(
                          fontSize: responsive.titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
              ),

              // Menu buttons
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final availableHeight = constraints.maxHeight;
                    final availableWidth = constraints.maxWidth;

                    const padding = 16.0;
                    const spacing = 16.0;
                    const rowCount = 1; // 2 items in 1 row

                    final totalVerticalSpacing = spacing + (padding * 2);
                    final cardHeight = (availableHeight - totalVerticalSpacing) / rowCount;

                    final totalHorizontalSpacing = spacing + (padding * 2);
                    final cardWidth = (availableWidth - totalHorizontalSpacing) / 2;

                    final aspectRatio = cardWidth / cardHeight;

                    return GridView.count(
                      padding: const EdgeInsets.all(padding),
                      crossAxisCount: 2,
                      mainAxisSpacing: spacing,
                      crossAxisSpacing: spacing,
                      aspectRatio: aspectRatio,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildMenuCard(
                          context: context,
                          icon: Icons.school,
                          titleHe: 'זמן למידה',
                          titleEn: 'Learning Time',
                          emoji: '📚',
                          color: Colors.green,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const FruitsVegetablesLearningScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuCard(
                          context: context,
                          icon: Icons.extension,
                          titleHe: 'משחק התאמה',
                          titleEn: 'Matching Game',
                          emoji: '🎮',
                          color: Colors.orange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const FruitsVegetablesMatchingGame(),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String titleHe,
    required String titleEn,
    required String emoji,
    required Color color,
    required VoidCallback onTap,
  }) {
    final responsive = ResponsiveHelper(context);
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.shade300,
              color.shade400,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: responsive.fontSize(60)),
            ),
            SizedBox(height: responsive.spacing(12)),
            Text(
              isHebrew ? titleHe : titleEn,
              style: TextStyle(
                fontSize: responsive.fontSize(24),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
