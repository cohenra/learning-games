import 'package:flutter/material.dart';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/kid_button.dart';
import '../../../widgets/kid_back_button.dart';
import 'share_treats_game.dart';
import 'pizza_party_game.dart';
import 'division_racing_game.dart';
import 'pirate_treasure_division_game.dart';
import 'potion_master_division_game.dart';

/// מסך תפריט חילוק - גילאי 7-12
class DivisionMenuScreen extends StatefulWidget {
  const DivisionMenuScreen({super.key});

  @override
  State<DivisionMenuScreen> createState() => _DivisionMenuScreenState();
}

class _DivisionMenuScreenState extends State<DivisionMenuScreen>
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
              Colors.teal.shade50,
              Colors.cyan.shade50,
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
                              '➗',
                              style: TextStyle(fontSize: responsive.iconSize(80)),
                            ),
                            SizedBox(height: responsive.spacing(12)),
                            Text(
                              _isHebrew ? 'חילוק' : 'Division',
                              style: TextStyle(
                                fontSize: responsive.titleSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: responsive.spacing(8)),
                            Text(
                              _isHebrew
                                  ? 'למד לחלק בדרך מהנה!'
                                  : 'Learn division the fun way!',
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
                          color: Colors.teal.shade600,
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
                        SizedBox(height: responsive.spacing(12)),
                        _buildGameCard(
                          context,
                          responsive,
                          icon: '🏎️',
                          title: _isHebrew ? 'מרוץ החילוק' : 'Division Racing',
                          description: _isHebrew
                              ? 'מרוץ מרגש נגד יריבים!'
                              : 'Exciting race against opponents!',
                          color: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DivisionRacingGame(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: responsive.spacing(16)),
                        _buildGameCard(
                          context,
                          responsive,
                          icon: '🏴‍☠️',
                          title: _isHebrew ? 'אוצר הפיראטים' : 'Pirate\'s Treasure',
                          description: _isHebrew
                              ? 'הרפתקה באיים מסתוריים'
                              : 'Adventure on mysterious islands',
                          color: Colors.amber.shade700,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PirateTreasureDivisionGame(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: responsive.spacing(16)),
                        _buildGameCard(
                          context,
                          responsive,
                          icon: '🧙‍♂️',
                          title: _isHebrew ? 'קוסם השיקויים' : 'Potion Master',
                          description: _isHebrew
                              ? 'בשל שיקויים קסומים!'
                              : 'Brew magical potions!',
                          color: Colors.purple,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PotionMasterDivisionGame(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: responsive.spacing(16)),
                        _buildGameCard(
                          context,
                          responsive,
                          icon: '🍪',
                          title: _isHebrew ? 'חלק את הממתקים' : 'Share the Treats',
                          description: _isHebrew
                              ? 'חלק ממתקים באופן שווה בין חברים'
                              : 'Share treats equally among friends',
                          color: Colors.orange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ShareTreatsGame(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: responsive.spacing(16)),
                        _buildGameCard(
                          context,
                          responsive,
                          icon: '🍕',
                          title: _isHebrew ? 'מסיבת פיצה' : 'Pizza Party',
                          description: _isHebrew
                              ? 'חלק פיצות לפלחים שווים'
                              : 'Divide pizzas into equal slices',
                          color: Colors.red,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PizzaPartyGame(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: responsive.spacing(16)),
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
              blurRadius: 8,
              offset: const Offset(0, 4),
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
}
