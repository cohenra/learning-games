import 'package:flutter/material.dart';
import '../widgets/language_toggle.dart';
import '../widgets/kid_button.dart';
import '../screens/basic_skills_screen.dart';
import '../screens/world_around_us_screen.dart';
import '../screens/people_feelings_screen.dart';
import '../screens/creative_fun_screen.dart';
import '../screens/advanced_learning_screen.dart';
import '../screens/settings_screen.dart';
import '../utils/responsive_helper.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// מסך קטגוריות ראשי - מארגן את כל התכנים לפי סוגי למידה
class CategoriesHomeScreen extends StatelessWidget {
  const CategoriesHomeScreen({super.key});

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
              // כותרת עליונה עם החלפת שפה
              Padding(
                padding: responsive.safePadding.copyWith(
                  top: responsive.spacing(12),
                  bottom: responsive.spacing(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: responsive.spacing(48)), // למרכז את הכותרת
                    Flexible(
                      child: Text(
                        l10n.appName,
                        style: TextStyle(
                          fontSize: responsive.titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const LanguageToggle(),
                  ],
                ),
              ),

              SizedBox(height: responsive.spacing(10)),

              // ברוכים הבאים
              Text(
                l10n.welcome,
                style: TextStyle(
                  fontSize: responsive.subtitleSize,
                  color: Colors.grey.shade700,
                ),
              ),

              SizedBox(height: responsive.spacing(20)),

              // כרטיסי קבוצות ראשיות
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final availableHeight = constraints.maxHeight;

                    const settingsHeight = 80.0;
                    const spacing = 16.0;
                    const numCategories = 5;

                    final availableForCards = availableHeight - settingsHeight;
                    final totalSpacing = (numCategories - 1) * spacing + (spacing * 2);
                    final cardHeight = ((availableForCards - totalSpacing) / numCategories)
                        .clamp(80.0, 120.0);

                    return Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: responsive.spacing(16),
                            ),
                            child: Column(
                              children: [
                                _buildCategoryCard(
                                  context: context,
                                  title: isHebrew ? 'מיומנויות בסיסיות' : 'Basic Skills',
                                  subtitle: isHebrew
                                      ? 'אותיות, מספרים, צבעים וצורות'
                                      : 'Letters, Numbers, Colors & Shapes',
                                  icon: '📚',
                                  color: Colors.blue,
                                  height: cardHeight,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const BasicSkillsScreen(),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: spacing),
                                _buildCategoryCard(
                                  context: context,
                                  title: isHebrew ? 'העולם סביבנו' : 'World Around Us',
                                  subtitle: isHebrew
                                      ? 'בעלי חיים, כלי תחבורה ועוד'
                                      : 'Animals, Vehicles & More',
                                  icon: '🌍',
                                  color: Colors.green,
                                  height: cardHeight,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const WorldAroundUsScreen(),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: spacing),
                                _buildCategoryCard(
                                  context: context,
                                  title: isHebrew ? 'אנשים ורגשות' : 'People & Feelings',
                                  subtitle: isHebrew
                                      ? 'משפחה, רגשות ומקצועות'
                                      : 'Family, Emotions & Professions',
                                  icon: '👨‍👩‍👧',
                                  color: Colors.orange,
                                  height: cardHeight,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const PeopleFeelingsScreen(),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: spacing),
                                _buildCategoryCard(
                                  context: context,
                                  title: isHebrew ? 'יצירתי ומהנה' : 'Creative & Fun',
                                  subtitle: isHebrew
                                      ? 'מוזיקה ופעילויות יצירתיות'
                                      : 'Music & Creative Activities',
                                  icon: '🎨',
                                  color: Colors.purple,
                                  height: cardHeight,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const CreativeFunScreen(),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: spacing),
                                _buildCategoryCard(
                                  context: context,
                                  title: isHebrew ? 'למידה מתקדמת 🎓' : 'Advanced Learning 🎓',
                                  subtitle: isHebrew
                                      ? 'מתמטיקה, מדעים ועוד - גילאי 7-12'
                                      : 'Math, Science & More - Ages 7-12',
                                  icon: '🎓',
                                  color: Colors.indigo,
                                  height: cardHeight,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AdvancedLearningScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        // כפתור הגדרות
                        Padding(
                          padding: responsive.safePadding.copyWith(
                            top: responsive.spacing(12),
                            bottom: responsive.spacing(12),
                          ),
                          child: KidButton(
                            text: l10n.settings,
                            icon: Icons.settings,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsScreen(),
                                ),
                              );
                            },
                            color: Colors.grey.shade600,
                            width: responsive.width(40),
                            height: responsive.buttonHeight * 0.6,
                          ),
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

  Widget _buildCategoryCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String icon,
    required Color color,
    required double height,
    required VoidCallback onTap,
  }) {
    final responsive = ResponsiveHelper(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(responsive.spacing(20)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: responsive.spacing(15),
              offset: Offset(0, responsive.spacing(8)),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(responsive.spacing(16)),
          child: Row(
            children: [
              // אייקון
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(responsive.spacing(15)),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: TextStyle(fontSize: responsive.iconSize(35)),
                  ),
                ),
              ),

              SizedBox(width: responsive.spacing(16)),

              // טקסטים
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 3,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: responsive.fontSize(18),
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: responsive.spacing(2)),
                    Flexible(
                      flex: 2,
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: responsive.fontSize(12),
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // חץ
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: responsive.iconSize(24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
