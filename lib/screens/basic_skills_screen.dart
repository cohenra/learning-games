import 'package:flutter/material.dart';
import '../widgets/kid_button.dart';
import '../modules/numbers/numbers_menu_screen.dart';
import '../modules/colors/colors_menu_screen.dart';
import '../modules/letters/letters_menu_screen.dart';
import '../modules/shapes/shapes_menu_screen.dart';
import '../utils/responsive_helper.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// מסך מיומנויות בסיסיות - אותיות, מספרים, צבעים, צורות
class BasicSkillsScreen extends StatelessWidget {
  const BasicSkillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              Colors.blue.shade50,
              Colors.purple.shade50,
              Colors.pink.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // כותרת עליונה עם כפתור חזרה
              Padding(
                padding: responsive.safePadding.copyWith(
                  top: responsive.spacing(12),
                  bottom: responsive.spacing(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isHebrew ? Icons.arrow_forward : Icons.arrow_back,
                        color: Colors.blue.shade700,
                        size: 32,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        isHebrew ? 'מיומנויות בסיסיות' : 'Basic Skills',
                        style: TextStyle(
                          fontSize: responsive.titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48), // לאיזון
                  ],
                ),
              ),

              SizedBox(height: responsive.spacing(10)),

              // תיאור
              Text(
                isHebrew
                    ? 'אותיות, מספרים, צבעים וצורות'
                    : 'Letters, Numbers, Colors & Shapes',
                style: TextStyle(
                  fontSize: responsive.subtitleSize,
                  color: Colors.grey.shade700,
                ),
              ),

              SizedBox(height: responsive.spacing(20)),

              // כרטיסי מודולים
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final availableHeight = constraints.maxHeight;
                    final availableWidth = constraints.maxWidth;

                    const padding = 16.0;
                    const spacing = 16.0;
                    const rowCount = 2; // 4 items in 2x2 grid

                    // Calculate card dimensions
                    final totalVerticalSpacing = spacing + (padding * 2);
                    final cardHeight = (availableHeight - totalVerticalSpacing) / rowCount;

                    final totalHorizontalSpacing = spacing + (padding * 2);
                    final cardWidth = (availableWidth - totalHorizontalSpacing) / 2;

                    final aspectRatio = cardWidth / cardHeight;

                    return GridView.count(
                      crossAxisCount: 2,
                      padding: EdgeInsets.symmetric(
                        horizontal: padding,
                        vertical: padding / 2,
                      ),
                      mainAxisSpacing: spacing,
                      crossAxisSpacing: spacing,
                      childAspectRatio: aspectRatio,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                    _buildModuleCard(
                      context: context,
                      title: l10n.numbers,
                      icon: '🔢',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NumbersMenuScreen(),
                          ),
                        );
                      },
                    ),
                    _buildModuleCard(
                      context: context,
                      title: l10n.letters,
                      icon: '🔤',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LettersMenuScreen(),
                          ),
                        );
                      },
                    ),
                    _buildModuleCard(
                      context: context,
                      title: l10n.colors,
                      icon: '🎨',
                      color: Colors.pink,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ColorsMenuScreen(),
                          ),
                        );
                      },
                    ),
                    _buildModuleCard(
                      context: context,
                      title: l10n.shapes,
                      icon: '⭐',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ShapesMenuScreen(),
                          ),
                        );
                      },
                    ),
                      ],
                    );
                  },
                ),
              ),

              SizedBox(height: responsive.spacing(16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard({
    required BuildContext context,
    required String title,
    required String icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final responsive = ResponsiveHelper(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(responsive.spacing(25)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: responsive.spacing(15),
              offset: Offset(0, responsive.spacing(8)),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: TextStyle(fontSize: responsive.iconSize(60)),
            ),
            SizedBox(height: responsive.spacing(12)),
            Text(
              title,
              style: TextStyle(
                fontSize: responsive.fontSize(18),
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
