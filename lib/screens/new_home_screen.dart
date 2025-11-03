import 'package:flutter/material.dart';
import '../widgets/language_toggle.dart';
import '../widgets/kid_button.dart';
import '../modules/numbers/numbers_menu_screen.dart';
import '../screens/settings_screen.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// מסך הבית המעודכן
class NewHomeScreen extends StatelessWidget {
  const NewHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48), // למרכז את הכותרת
                    Text(
                      l10n.appName,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const LanguageToggle(),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ברוכים הבאים
              Text(
                l10n.welcome,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 15),

              // כרטיסי מודולים
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 5.0,
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
                      onTap: () {},
                      isAvailable: false,
                    ),
                    _buildModuleCard(
                      context: context,
                      title: l10n.colors,
                      icon: '🎨',
                      color: Colors.pink,
                      onTap: () {},
                      isAvailable: false,
                    ),
                    _buildModuleCard(
                      context: context,
                      title: l10n.shapes,
                      icon: '⭐',
                      color: Colors.purple,
                      onTap: () {},
                      isAvailable: false,
                    ),
                  ],
                ),
              ),

              // כפתור הגדרות
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                  width: 160,
                  height: 50,
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

    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
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
                    borderRadius: BorderRadius.circular(30),
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
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  if (!isAvailable) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade400,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.comingSoon,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
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
