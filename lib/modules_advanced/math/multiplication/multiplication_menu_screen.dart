import 'package:flutter/material.dart';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/kid_button.dart';
import '../../../widgets/kid_back_button.dart';
import 'multiplication_table_screen.dart';
import 'speed_multiplication_game.dart';

/// מסך תפריט לוח הכפל - גילאי 7-12
class MultiplicationMenuScreen extends StatefulWidget {
  const MultiplicationMenuScreen({super.key});

  @override
  State<MultiplicationMenuScreen> createState() =>
      _MultiplicationMenuScreenState();
}

class _MultiplicationMenuScreenState extends State<MultiplicationMenuScreen>
    with SingleTickerProviderStateMixin {
  bool _isHebrew = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isHebrew = Localizations.localeOf(context).languageCode == 'he';
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    _isHebrew = Localizations.localeOf(context).languageCode == 'he';

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
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
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
                              '✖️',
                              style: TextStyle(fontSize: responsive.iconSize(80)),
                            ),
                            SizedBox(height: responsive.spacing(12)),
                            Text(
                              _isHebrew ? 'לוח הכפל' : 'Multiplication',
                              style: TextStyle(
                                fontSize: responsive.titleSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: responsive.spacing(8)),
                            Text(
                              _isHebrew
                                  ? 'למד כפל בדרך מהנה!'
                                  : 'Learn multiplication the fun way!',
                              style: TextStyle(
                                fontSize: responsive.fontSize(16),
                                color: Colors.grey.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: _isHebrew ? 0 : null,
                        left: _isHebrew ? null : 0,
                        child: KidBackButton(
                          onPressed: () => Navigator.pop(context),
                          color: Colors.purple.shade600,
                          isHebrew: _isHebrew,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: responsive.spacing(20)),

                // Game Cards
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.spacing(20),
                    ),
                    child: Column(
                      children: [
                        _buildGameCard(
                          context,
                          responsive,
                          icon: '📊',
                          title: _isHebrew
                              ? 'לוח הכפל האינטראקטיבי'
                              : 'Interactive Multiplication Table',
                          description: _isHebrew
                              ? 'למד את לוח הכפל עם אנימציות וצבעים'
                              : 'Learn multiplication with animations and colors',
                          color: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MultiplicationTableScreen(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: responsive.verticalSpacing),
                        _buildGameCard(
                          context,
                          responsive,
                          icon: '⚡',
                          title: _isHebrew ? 'כפל מהיר' : 'Speed Multiplication',
                          description: _isHebrew
                              ? 'כמה מהר אתה יכול לענות?'
                              : 'How fast can you answer?',
                          color: Colors.orange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SpeedMultiplicationGame(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: responsive.verticalSpacing),
                        _buildComingSoonCard(
                          context,
                          responsive,
                          icon: '🎯',
                          title: _isHebrew ? 'אתגרי כפל' : 'Multiplication Challenges',
                          description: _isHebrew
                              ? 'בקרוב...'
                              : 'Coming soon...',
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: responsive.spacing(20)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(
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
                      fontSize: responsive.fontSize(18),
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
              _isHebrew ? Icons.arrow_back : Icons.arrow_forward,
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
                      fontSize: responsive.fontSize(18),
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
