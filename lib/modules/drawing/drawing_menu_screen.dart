import 'package:flutter/material.dart';
import '../../widgets/kid_button.dart';
import '../../utils/responsive_helper.dart';
import 'free_drawing_screen.dart';
import 'complete_picture_screen.dart';
import 'shape_tracing_screen.dart';

/// מסך תפריט ציור
class DrawingMenuScreen extends StatelessWidget {
  const DrawingMenuScreen({super.key});

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
              Colors.pink.shade50,
              Colors.purple.shade50,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final buttons = [
                {
                  'titleHe': 'ציור חופשי',
                  'titleEn': 'Free Drawing',
                  'descriptionHe': 'צור את היצירה שלך',
                  'descriptionEn': 'Create your artwork',
                  'icon': Icons.brush,
                  'color': Colors.pink,
                  'onTap': () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FreeDrawingScreen(),
                      ),
                    );
                  },
                },
                {
                  'titleHe': 'ציור צורות',
                  'titleEn': 'Shape Tracing',
                  'descriptionHe': 'תרגל לצייר צורות',
                  'descriptionEn': 'Practice drawing shapes',
                  'icon': Icons.change_history,
                  'color': Colors.orange,
                  'onTap': () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ShapeTracingScreen(),
                      ),
                    );
                  },
                },
                {
                  'titleHe': 'השלמת תמונות',
                  'titleEn': 'Complete Pictures',
                  'descriptionHe': 'השלם את התמונה החסרה',
                  'descriptionEn': 'Complete the missing picture',
                  'icon': Icons.extension,
                  'color': Colors.purple,
                  'onTap': () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CompletePictureScreen(),
                      ),
                    );
                  },
                },
              ];

              final availableHeight = constraints.maxHeight;
              final numButtons = buttons.length;

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
                            color: Colors.pink.shade700,
                            size: 32,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            isHebrew ? 'ציור' : 'Drawing',
                            style: TextStyle(
                              fontSize: responsive.titleSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // Icon
                  Text(
                    '🎨',
                    style: TextStyle(fontSize: responsive.iconSize(60)),
                  ),

                  SizedBox(height: responsive.spacing(8)),

                  // Description
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                    child: Text(
                      isHebrew
                          ? 'צייר, צבע ויצור!'
                          : 'Draw, Paint & Create!',
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
                            text: isHebrew ? button['titleHe'] as String : button['titleEn'] as String,
                            icon: button['icon'] as IconData,
                            onPressed: button['onTap'] as VoidCallback,
                            color: button['color'] as Color,
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
