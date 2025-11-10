import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/kid_button.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// מסך הגדרות
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
        backgroundColor: Colors.grey.shade600,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade50,
              Colors.blue.shade50,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              final isHebrew = appProvider.locale.languageCode == 'he';

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // הגדרות שפה
                  _buildSettingCard(
                    title: l10n.language,
                    icon: Icons.language,
                    color: Colors.blue,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildLanguageButton(
                          context: context,
                          text: l10n.english,
                          flag: '🇺🇸',
                          isSelected: !isHebrew,
                          onTap: () =>
                              appProvider.setLocale(const Locale('en')),
                        ),
                        _buildLanguageButton(
                          context: context,
                          text: l10n.hebrew,
                          flag: '🇮🇱',
                          isSelected: isHebrew,
                          onTap: () =>
                              appProvider.setLocale(const Locale('he')),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // הגדרות קול
                  _buildSettingCard(
                    title: l10n.sound,
                    icon: Icons.volume_up,
                    color: Colors.green,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        KidButton(
                          text: appProvider.soundEnabled
                              ? l10n.soundOn
                              : l10n.soundOff,
                          icon: appProvider.soundEnabled
                              ? Icons.volume_up
                              : Icons.volume_off,
                          onPressed: appProvider.toggleSound,
                          color: appProvider.soundEnabled
                              ? Colors.green
                              : Colors.red,
                          width: 180,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // הגדרות מוזיקה
                  _buildSettingCard(
                    title: l10n.music,
                    icon: Icons.music_note,
                    color: Colors.purple,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        KidButton(
                          text: appProvider.musicEnabled
                              ? l10n.musicOn
                              : l10n.musicOff,
                          icon: appProvider.musicEnabled
                              ? Icons.music_note
                              : Icons.music_off,
                          onPressed: appProvider.toggleMusic,
                          color: appProvider.musicEnabled
                              ? Colors.purple
                              : Colors.red,
                          width: 180,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // סטטיסטיקות התקדמות
                  _buildSettingCard(
                    title: l10n.progress,
                    icon: Icons.star,
                    color: Colors.orange,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.stars,
                              style: const TextStyle(fontSize: 20),
                            ),
                            Row(
                              children: [
                                const Text(
                                  '⭐',
                                  style: TextStyle(fontSize: 32),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${appProvider.totalStars}',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...appProvider.progress.entries.map((entry) {
                          final moduleName = entry.key;
                          final progress = entry.value;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _getModuleName(moduleName, l10n),
                                  style: const TextStyle(fontSize: 18),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '${progress.stars} ⭐',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (progress.completed)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildLanguageButton({
    required BuildContext context,
    required String text,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade500 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getModuleName(String key, AppLocalizations l10n) {
    final isHebrew = l10n.localeName == 'he';

    switch (key) {
      // מיומנויות בסיסיות
      case 'numbers':
        return l10n.numbers;
      case 'letters':
        return l10n.letters;
      case 'colors':
        return l10n.colors;
      case 'shapes':
        return l10n.shapes;

      // העולם סביבנו
      case 'animals':
        return isHebrew ? 'בעלי חיים' : 'Animals';
      case 'vehicles':
        return isHebrew ? 'כלי תחבורה' : 'Vehicles';
      case 'weather':
        return isHebrew ? 'מזג אוויר' : 'Weather';
      case 'fruits_vegetables':
        return isHebrew ? 'פירות וירקות' : 'Fruits & Vegetables';
      case 'body_parts':
        return isHebrew ? 'חלקי הגוף' : 'Body Parts';

      // אנשים ורגשות
      case 'family':
        return isHebrew ? 'משפחה' : 'Family';
      case 'emotions':
        return isHebrew ? 'רגשות' : 'Emotions';
      case 'professions':
        return isHebrew ? 'מקצועות' : 'Professions';

      // יצירתי ומהנה
      case 'music':
        return isHebrew ? 'מוזיקה' : 'Music';
      case 'drawing':
        return isHebrew ? 'ציור' : 'Drawing';

      default:
        return key;
    }
  }
}
