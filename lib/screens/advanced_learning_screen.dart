import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';
import '../widgets/kid_back_button.dart';
import '../modules_advanced/math/math_menu_screen.dart';

/// מסך למידה מתקדמת - גילאי 7-12
class AdvancedLearningScreen extends StatelessWidget {
  const AdvancedLearningScreen({super.key});

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
              Colors.indigo.shade50,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(responsive.spacing(16)),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text(
                            '🎓',
                            style: TextStyle(fontSize: responsive.iconSize(80)),
                          ),
                          SizedBox(height: responsive.spacing(12)),
                          Text(
                            isHebrew ? 'למידה מתקדמת' : 'Advanced Learning',
                            style: TextStyle(
                              fontSize: responsive.titleSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: responsive.spacing(8)),
                          Text(
                            isHebrew ? 'גילאי 7-12' : 'Ages 7-12',
                            style: TextStyle(
                              fontSize: responsive.fontSize(18),
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: isHebrew ? 0 : null,
                      left: isHebrew ? null : 0,
                      child: KidBackButton(
                        onPressed: () => Navigator.pop(context),
                        color: Colors.indigo.shade600,
                        isHebrew: isHebrew,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: responsive.spacing(20)),

              // Subject categories
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.spacing(20),
                  ),
                  child: Column(
                    children: [
                      // Math
                      _buildSubjectCard(
                        context,
                        responsive,
                        icon: '🔢',
                        title: isHebrew ? 'מתמטיקה' : 'Mathematics',
                        description: isHebrew
                            ? 'כפל, חילוק, שברים ועוד'
                            : 'Multiplication, Division, Fractions & More',
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MathMenuScreen(),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: responsive.verticalSpacing),

                      // Coming soon cards
                      _buildComingSoonCard(
                        context,
                        responsive,
                        icon: '🔬',
                        title: isHebrew ? 'מדעים' : 'Science',
                        description: isHebrew
                            ? 'ניסויים ותגליות מדעיות'
                            : 'Experiments & Scientific Discoveries',
                      ),

                      SizedBox(height: responsive.verticalSpacing),

                      _buildComingSoonCard(
                        context,
                        responsive,
                        icon: '🌍',
                        title: isHebrew ? 'גיאוגרפיה' : 'Geography',
                        description: isHebrew
                            ? 'מפות, ערים ומדינות'
                            : 'Maps, Cities & Countries',
                      ),

                      SizedBox(height: responsive.verticalSpacing),

                      _buildComingSoonCard(
                        context,
                        responsive,
                        icon: '💭',
                        title: isHebrew ? 'חשיבה לוגית' : 'Logic & Thinking',
                        description: isHebrew
                            ? 'סודוקו, חידות ופאזלים'
                            : 'Sudoku, Riddles & Puzzles',
                      ),

                      SizedBox(height: responsive.verticalSpacing),

                      _buildComingSoonCard(
                        context,
                        responsive,
                        icon: '💻',
                        title: isHebrew ? 'תכנות בסיסי' : 'Basic Coding',
                        description: isHebrew
                            ? 'למד לתכנת בדרך מהנה'
                            : 'Learn to Code the Fun Way',
                      ),

                      SizedBox(height: responsive.spacing(20)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectCard(
    BuildContext context,
    ResponsiveHelper responsive, {
    required String icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(responsive.spacing(20)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: TextStyle(fontSize: responsive.iconSize(40)),
                ),
              ),
            ),
            SizedBox(width: responsive.spacing(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: responsive.fontSize(20),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: responsive.spacing(4)),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: responsive.fontSize(14),
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: color,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonCard(
    BuildContext context,
    ResponsiveHelper responsive, {
    required String icon,
    required String title,
    required String description,
  }) {
    return Opacity(
      opacity: 0.5,
      child: Container(
        padding: EdgeInsets.all(responsive.spacing(20)),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade400, width: 3),
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: TextStyle(fontSize: responsive.iconSize(40)),
                ),
              ),
            ),
            SizedBox(width: responsive.spacing(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: responsive.fontSize(20),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: responsive.spacing(4)),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: responsive.fontSize(14),
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.lock,
              color: Colors.grey.shade500,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
