import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';
import '../modules/music/music_menu_screen.dart';
import '../modules/drawing/drawing_menu_screen.dart';
import 'package:learning_fun/generated/app_localizations.dart';

/// מסך יצירתי ומהנה - מוזיקה ופעילויות יצירתיות
class CreativeFunScreen extends StatelessWidget {
  const CreativeFunScreen({super.key});

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
              Colors.purple.shade50,
              Colors.pink.shade50,
              Colors.red.shade50,
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
                        color: Colors.purple.shade700,
                        size: 32,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        isHebrew ? 'יצירתי ומהנה' : 'Creative & Fun',
                        style: TextStyle(
                          fontSize: responsive.titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
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
                    ? 'מוזיקה ויצירתיות'
                    : 'Music & Creativity',
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
                      title: isHebrew ? 'מוזיקה' : 'Music',
                      icon: '🎵',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MusicMenuScreen(),
                          ),
                        );
                      },
                      isAvailable: true,
                    ),
                    _buildModuleCard(
                      context: context,
                      title: isHebrew ? 'ציור' : 'Drawing',
                      icon: '🎨',
                      color: Colors.pink,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DrawingMenuScreen(),
                          ),
                        );
                      },
                      isAvailable: true,
                    ),
                    _buildModuleCard(
                      context: context,
                      title: isHebrew ? 'סיפורים' : 'Stories',
                      icon: '📖',
                      color: Colors.blue,
                      isAvailable: false,
                    ),
                    _buildModuleCard(
                      context: context,
                      title: isHebrew ? 'ריקוד' : 'Dance',
                      icon: '💃',
                      color: Colors.orange,
                      isAvailable: false,
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
    VoidCallback? onTap,
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
          borderRadius: BorderRadius.circular(responsive.spacing(25)),
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
                    borderRadius: BorderRadius.circular(responsive.spacing(25)),
                  ),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  icon,
                  style: TextStyle(fontSize: responsive.iconSize(60)),
                ),
                SizedBox(height: responsive.spacing(12)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: responsive.spacing(8)),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: responsive.fontSize(16),
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isAvailable) ...[
                  SizedBox(height: responsive.spacing(8)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.spacing(12),
                      vertical: responsive.spacing(6),
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
                        fontSize: responsive.fontSize(12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
