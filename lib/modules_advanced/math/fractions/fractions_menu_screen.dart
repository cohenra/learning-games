import 'package:flutter/material.dart';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/kid_button.dart';
import '../../../widgets/kid_back_button.dart';
import 'cake_cutter_game.dart';
import 'chocolate_fractions_game.dart';
import 'fraction_rocket_collector_game.dart';
import 'fraction_balloon_blast_game.dart';
import 'fraction_platform_runner_game.dart';

/// מסך תפריט שברים - גילאי 7-12
class FractionsMenuScreen extends StatefulWidget {
  const FractionsMenuScreen({super.key});

  @override
  State<FractionsMenuScreen> createState() => _FractionsMenuScreenState();
}

class _FractionsMenuScreenState extends State<FractionsMenuScreen>
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
              Colors.pink.shade50,
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
                              '½',
                              style: TextStyle(fontSize: responsive.iconSize(80)),
                            ),
                            SizedBox(height: responsive.spacing(12)),
                            Text(
                              _isHebrew ? 'שברים' : 'Fractions',
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
                                  ? 'למד שברים בדרך חזותית!'
                                  : 'Learn fractions visually!',
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
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.spacing(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCompactGameCard(
                          context,
                          responsive,
                          icon: '🎂',
                          title: _isHebrew ? 'חותך עוגות' : 'Cake Cutter',
                          color: Colors.pink,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CakeCutterGame(),
                              ),
                            );
                          },
                        ),
                        _buildCompactGameCard(
                          context,
                          responsive,
                          icon: '🍫',
                          title: _isHebrew ? 'שברי שוקולד' : 'Chocolate Fractions',
                          color: Colors.brown,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChocolateFractionsGame(),
                              ),
                            );
                          },
                        ),
                        _buildCompactGameCard(
                          context,
                          responsive,
                          icon: '🚀',
                          title: _isHebrew ? 'רקטת שברים' : 'Fraction Rocket',
                          color: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FractionRocketCollectorGame(),
                              ),
                            );
                          },
                        ),
                        _buildCompactGameCard(
                          context,
                          responsive,
                          icon: '🎈',
                          title: _isHebrew ? 'פיצוץ בלונים' : 'Balloon Blast',
                          color: Colors.purple,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FractionBalloonBlastGame(),
                              ),
                            );
                          },
                        ),
                        _buildCompactGameCard(
                          context,
                          responsive,
                          icon: '🏃‍♂️',
                          title: _isHebrew ? 'מרוץ פלטפורמות' : 'Platform Runner',
                          color: Colors.orange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FractionPlatformRunnerGame(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: responsive.spacing(12)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactGameCard(
    BuildContext context,
    ResponsiveHelper responsive, {
    required String icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.spacing(12),
          vertical: responsive.spacing(8),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: TextStyle(fontSize: responsive.iconSize(28)),
                ),
              ),
            ),
            SizedBox(width: responsive.spacing(12)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: responsive.fontSize(16),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            Icon(
              _isHebrew ? Icons.arrow_back : Icons.arrow_forward,
              color: color,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
