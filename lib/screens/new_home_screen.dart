import 'package:flutter/material.dart';
import '../widgets/language_toggle.dart';
import '../widgets/kid_button.dart';
import '../modules/numbers/numbers_menu_screen.dart';
import '../modules/colors/colors_menu_screen.dart';
import '../modules/letters/letters_menu_screen.dart';
import '../modules/shapes/shapes_menu_screen.dart';
import '../screens/settings_screen.dart';
import '../utils/responsive_helper.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// מסך הבית המעודכן
class NewHomeScreen extends StatelessWidget {
  const NewHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final responsive = ResponsiveHelper(context);

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

              SizedBox(height: responsive.spacing(15)),

              // כרטיסי מודולים
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.spacing(12),
                    vertical: responsive.spacing(8),
                  ),
                  mainAxisSpacing: responsive.spacing(10),
                  crossAxisSpacing: responsive.spacing(10),
                  childAspectRatio: responsive.isPhone ? 3.5 : 5.0,
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
                      isAvailable: true,
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
                      isAvailable: true,
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
                      isAvailable: true,
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
                      isAvailable: true,
                    ),
                  ],
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
    required bool isAvailable,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final responsive = ResponsiveHelper(context);

    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(responsive.spacing(30)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: responsive.spacing(15),
              offset: Offset(0, responsive.spacing(8)),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (!isAvailable)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(responsive.spacing(30)),
                  ),
                ),
              ),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    icon,
                    style: TextStyle(fontSize: responsive.iconSize(40)),
                  ),
                  SizedBox(width: responsive.spacing(8)),
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: responsive.bodyTextSize,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!isAvailable) ...[
                    SizedBox(width: responsive.spacing(8)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.spacing(8),
                        vertical: responsive.spacing(4),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade400,
                        borderRadius: BorderRadius.circular(responsive.spacing(12)),
                      ),
                      child: Text(
                        l10n.comingSoon,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: responsive.fontSize(10),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
