import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'dart:async';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/kid_button.dart';
import '../../../widgets/kid_back_button.dart';

/// משחק קוסם השיקויים (גרסה 2) - בחר את השיקוי הנכון ושפוך לקדרה!
class PotionMasterDivisionGame extends StatefulWidget {
  const PotionMasterDivisionGame({super.key});

  @override
  State<PotionMasterDivisionGame> createState() =>
      _PotionMasterDivisionGameState();
}

class _PotionMasterDivisionGameState extends State<PotionMasterDivisionGame>
    with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();
  bool _isHebrew = true;

  // Game state
  int _currentQuestion = 0;
  final int _totalQuestions = 10;
  int _score = 0;

  // Current question
  int? _dividend;
  int? _divisor;
  int? _correctAnswer;
  List<PotionOption> _potions = [];
  int? _selectedPotion;
  bool? _isCorrect;

  // Animations
  late AnimationController _cauldronBubbleController;
  late AnimationController _sparkleController;
  late AnimationController _pourController;
  late AnimationController _explosionController;
  late Animation<double> _bubbleAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _pourAnimation;
  late Animation<double> _explosionAnimation;

  // Particles for magic effects
  List<MagicParticle> _particles = [];
  bool _showExplosion = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initTts();
    _initAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isHebrew = Localizations.localeOf(context).languageCode == 'he';
      });
      _generateQuestion();
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage(_isHebrew ? 'he-IL' : 'en-US');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
  }

  void _initAnimations() {
    _cauldronBubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _bubbleAnimation =
        Tween<double>(begin: 0, end: 1).animate(_cauldronBubbleController);

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _sparkleAnimation =
        Tween<double>(begin: 0, end: 1).animate(_sparkleController);

    _pourController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pourAnimation = CurvedAnimation(
      parent: _pourController,
      curve: Curves.easeInOut,
    );

    _explosionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _explosionAnimation = CurvedAnimation(
      parent: _explosionController,
      curve: Curves.easeOut,
    );
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _generateQuestion() {
    // Generate division problem
    final divisors = [2, 3, 4, 5, 6, 7, 8];
    final divisor = divisors[_random.nextInt(divisors.length)];
    final answer = _random.nextInt(8) + 2; // 2-9
    final dividend = divisor * answer;

    // Generate 4 answer options (potions)
    final options = <int>{answer};
    while (options.length < 4) {
      final offset = _random.nextInt(7) - 3;
      final option = (answer + offset).clamp(1, 50);
      options.add(option);
    }

    final optionsList = options.toList()..shuffle();

    // Create potion options with colors
    final colors = [
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.orange,
    ];

    final potionEmojis = ['🔮', '⚗️', '🧪', '🍶'];

    setState(() {
      _dividend = dividend;
      _divisor = divisor;
      _correctAnswer = answer;
      _potions = List.generate(
        4,
        (i) => PotionOption(
          value: optionsList[i],
          color: colors[i],
          emoji: potionEmojis[i],
        ),
      );
      _selectedPotion = null;
      _isCorrect = null;
      _particles.clear();
      _showExplosion = false;
    });

    _speak(_isHebrew
        ? 'כמה זה $_dividend חלקי $_divisor?'
        : 'What is $_dividend divided by $_divisor?');
  }

  void _selectPotion(int index) {
    if (_selectedPotion != null) return; // Already selected

    setState(() => _selectedPotion = index);

    final selectedValue = _potions[index].value;
    final isCorrect = selectedValue == _correctAnswer;

    setState(() => _isCorrect = isCorrect);

    _pourController.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;

      setState(() => _showExplosion = true);

      if (isCorrect) {
        _speak(_isHebrew ? 'מעולה! קסם מושלם!' : 'Excellent! Perfect magic!');
        _createSuccessParticles();
        setState(() => _score++);
      } else {
        _speak(_isHebrew ? 'אופס! נסה שוב' : 'Oops! Try again');
        _createFailureParticles();
      }

      _explosionController.forward(from: 0);

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;

        if (isCorrect) {
          _currentQuestion++;
          if (_currentQuestion >= _totalQuestions) {
            _showFinalScore();
          } else {
            _generateQuestion();
          }
        } else {
          setState(() {
            _selectedPotion = null;
            _isCorrect = null;
            _showExplosion = false;
            _particles.clear();
          });
        }
      });
    });
  }

  void _createSuccessParticles() {
    final newParticles = List.generate(30, (i) {
      final angle = (i / 30) * 2 * pi;
      return MagicParticle(
        x: 0.5,
        y: 0.5,
        vx: cos(angle) * 0.015,
        vy: sin(angle) * 0.015,
        color: [Colors.yellow, Colors.orange, Colors.pink, Colors.purple]
            [_random.nextInt(4)],
        size: _random.nextDouble() * 8 + 4,
      );
    });
    setState(() => _particles.addAll(newParticles));

    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted || _particles.isEmpty) {
        timer.cancel();
        return;
      }
      setState(() {
        _particles = _particles.map((p) => p.update()).toList();
        _particles.removeWhere((p) => p.life <= 0);
      });
    });
  }

  void _createFailureParticles() {
    final newParticles = List.generate(15, (i) {
      return MagicParticle(
        x: 0.5 + (_random.nextDouble() - 0.5) * 0.2,
        y: 0.45 + (_random.nextDouble() - 0.5) * 0.2,
        vx: (_random.nextDouble() - 0.5) * 0.01,
        vy: -_random.nextDouble() * 0.02,
        color: Colors.grey.shade700,
        size: _random.nextDouble() * 12 + 6,
      );
    });
    setState(() => _particles.addAll(newParticles));

    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted || _particles.isEmpty) {
        timer.cancel();
        return;
      }
      setState(() {
        _particles = _particles.map((p) => p.update()).toList();
        _particles.removeWhere((p) => p.life <= 0);
      });
    });
  }

  void _showFinalScore() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple.shade100, Colors.pink.shade100],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🧙‍♂️ ✨ 🧙‍♀️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                _isHebrew ? 'מאסטר קוסם!' : 'Master Wizard!',
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                _isHebrew ? 'תשובות נכונות:' : 'Correct answers:',
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                '$_score / $_totalQuestions',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text(_isHebrew ? 'יציאה' : 'Exit'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _score = 0;
                        _currentQuestion = 0;
                      });
                      _generateQuestion();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade600,
                    ),
                    child: Text(_isHebrew ? 'שחק שוב' : 'Play Again'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _cauldronBubbleController.dispose();
    _sparkleController.dispose();
    _pourController.dispose();
    _explosionController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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
              Colors.deepPurple.shade900,
              Colors.purple.shade700,
              Colors.indigo.shade800,
            ],
          ),
        ),
        child: SafeArea(
          child: _dividend == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    Column(
                      children: [
                        _buildHeader(responsive),
                        SizedBox(height: responsive.spacing(16)),
                        _buildQuestion(responsive),
                        SizedBox(height: responsive.spacing(24)),
                        Expanded(
                          child: Stack(
                            children: [
                              _buildCauldron(responsive),
                              if (_selectedPotion != null)
                                _buildPouringPotion(responsive),
                            ],
                          ),
                        ),
                        SizedBox(height: responsive.spacing(24)),
                        _buildPotionOptions(responsive),
                        SizedBox(height: responsive.spacing(16)),
                      ],
                    ),
                    if (_particles.isNotEmpty)
                      CustomPaint(
                        painter: ParticlePainter(_particles),
                        size: Size.infinite,
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(12)),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade800.withOpacity(0.9),
      ),
      child: Row(
        children: [
          KidBackButton(
            onPressed: () => Navigator.pop(context),
            color: Colors.purple.shade300,
            isHebrew: _isHebrew,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatBadge(
                  responsive,
                  '🎯',
                  '${_currentQuestion + 1}/$_totalQuestions',
                  _isHebrew ? 'שאלה' : 'Question',
                ),
                _buildStatBadge(
                  responsive,
                  '⭐',
                  '$_score',
                  _isHebrew ? 'נכונות' : 'Score',
                ),
              ],
            ),
          ),
          SizedBox(width: responsive.spacing(48)),
        ],
      ),
    );
  }

  Widget _buildStatBadge(
      ResponsiveHelper responsive, String emoji, String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing(12),
        vertical: responsive.spacing(8),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade100, Colors.pink.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: responsive.iconSize(20))),
          SizedBox(width: responsive.spacing(6)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: responsive.fontSize(16),
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade800,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: responsive.fontSize(10),
                  color: Colors.purple.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(ResponsiveHelper responsive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
      padding: EdgeInsets.all(responsive.spacing(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.shade400, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _isHebrew ? 'בחר את השיקוי הנכון:' : 'Choose the correct potion:',
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              color: Colors.purple.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive.spacing(8)),
          Text(
            '$_dividend ÷ $_divisor = ?',
            style: TextStyle(
              fontSize: responsive.fontSize(32),
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCauldron(ResponsiveHelper responsive) {
    return Center(
      child: AnimatedBuilder(
        animation: _bubbleAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: CauldronPainter(
              bubbleValue: _bubbleAnimation.value,
              showExplosion: _showExplosion,
              explosionValue: _explosionAnimation.value,
              isCorrect: _isCorrect ?? true,
            ),
            size: Size(
              responsive.width * 0.5,
              responsive.height * 0.25,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPouringPotion(ResponsiveHelper responsive) {
    if (_selectedPotion == null) return const SizedBox();

    final potion = _potions[_selectedPotion!];

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedBuilder(
        animation: _pourAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: PouringPotionPainter(
              pourValue: _pourAnimation.value,
              potionColor: potion.color,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildPotionOptions(ResponsiveHelper responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(4, (index) {
          final potion = _potions[index];
          final isSelected = _selectedPotion == index;

          return GestureDetector(
            onTap:
                _selectedPotion == null ? () => _selectPotion(index) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: responsive.width * 0.2,
              height: responsive.height * 0.15,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? (_isCorrect == true ? Colors.green : Colors.red)
                      : potion.color,
                  width: isSelected ? 4 : 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    potion.emoji,
                    style: TextStyle(fontSize: responsive.iconSize(40)),
                  ),
                  SizedBox(height: responsive.spacing(8)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.spacing(8),
                      vertical: responsive.spacing(4),
                    ),
                    decoration: BoxDecoration(
                      color: potion.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      potion.value.toString(),
                      style: TextStyle(
                        fontSize: responsive.fontSize(20),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Data classes
class PotionOption {
  final int value;
  final MaterialColor color;
  final String emoji;

  PotionOption({
    required this.value,
    required this.color,
    required this.emoji,
  });
}

class MagicParticle {
  double x, y, vx, vy;
  Color color;
  double size;
  double life;

  MagicParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    this.life = 1.0,
  });

  MagicParticle update() {
    return MagicParticle(
      x: x + vx,
      y: y + vy,
      vx: vx,
      vy: vy + 0.001, // Gravity
      color: color,
      size: size * 0.97,
      life: life - 0.02,
    );
  }
}

// Painters
class ParticlePainter extends CustomPainter {
  final List<MagicParticle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.life * 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

class CauldronPainter extends CustomPainter {
  final double bubbleValue;
  final bool showExplosion;
  final double explosionValue;
  final bool isCorrect;

  CauldronPainter({
    required this.bubbleValue,
    required this.showExplosion,
    required this.explosionValue,
    required this.isCorrect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.7);

    // Draw cauldron body
    final cauldronPath = Path();
    cauldronPath.moveTo(size.width * 0.2, size.height * 0.5);
    cauldronPath.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.7,
      size.width * 0.2,
      size.height * 0.9,
    );
    cauldronPath.lineTo(size.width * 0.8, size.height * 0.9);
    cauldronPath.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.7,
      size.width * 0.8,
      size.height * 0.5,
    );
    cauldronPath.close();

    final cauldronPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.grey.shade800, Colors.grey.shade900],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(cauldronPath, cauldronPaint);

    // Draw potion inside
    final potionRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, size.height * 0.7),
        width: size.width * 0.5,
        height: size.height * 0.3,
      ),
      const Radius.circular(20),
    );

    final potionColor =
        showExplosion ? (isCorrect ? Colors.gold : Colors.grey) : Colors.green;

    final potionPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          potionColor.shade400,
          potionColor.shade700,
        ],
      ).createShader(potionRect.outerRect);

    canvas.drawRRect(potionRect, potionPaint);

    // Draw bubbles
    if (!showExplosion) {
      final bubblePaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.fill;

      for (int i = 0; i < 5; i++) {
        final bubbleY = size.height * 0.65 +
            (sin(bubbleValue * 2 * pi + i) * size.height * 0.1);
        canvas.drawCircle(
          Offset(size.width * (0.3 + i * 0.1), bubbleY),
          size.width * 0.02,
          bubblePaint,
        );
      }
    }

    // Draw explosion effect
    if (showExplosion && explosionValue > 0) {
      final explosionPaint = Paint()
        ..color = (isCorrect ? Colors.yellow : Colors.grey.shade600)
            .withOpacity((1 - explosionValue) * 0.6)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(center.dx, size.height * 0.5),
        size.width * 0.3 * explosionValue,
        explosionPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CauldronPainter oldDelegate) =>
      oldDelegate.bubbleValue != bubbleValue ||
      oldDelegate.showExplosion != showExplosion ||
      oldDelegate.explosionValue != explosionValue;
}

class PouringPotionPainter extends CustomPainter {
  final double pourValue;
  final MaterialColor potionColor;

  PouringPotionPainter({
    required this.pourValue,
    required this.potionColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pourValue == 0) return;

    // Draw pouring stream
    final streamPath = Path();
    final startY = size.height * 0.1;
    final endY = size.height * 0.4 * pourValue;

    streamPath.moveTo(size.width * 0.5 - 5, startY);
    streamPath.lineTo(size.width * 0.5 - 5, endY);
    streamPath.lineTo(size.width * 0.5 + 5, endY);
    streamPath.lineTo(size.width * 0.5 + 5, startY);
    streamPath.close();

    final streamPaint = Paint()
      ..color = potionColor.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    canvas.drawPath(streamPath, streamPaint);
  }

  @override
  bool shouldRepaint(PouringPotionPainter oldDelegate) =>
      oldDelegate.pourValue != pourValue;
}
