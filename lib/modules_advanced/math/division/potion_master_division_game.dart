import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'dart:async';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/kid_button.dart';
import '../../../widgets/kid_back_button.dart';

/// משחק קוסם השיקויים - מעבדה קסומה ללימוד חילוק
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
  String _currentScreen = 'menu'; // 'menu', 'lab', 'book', 'success'
  int _currentPotionIndex = 0;
  final int _totalPotions = 15;

  // Potion collection
  Map<int, bool> _collectedPotions = {};

  // Current potion state
  int? _totalIngredients;
  int? _vials;
  int? _correctAnswer;
  List<int> _vialDistribution = [];
  int? _selectedAnswer;
  bool? _isCorrect;

  // Potion definitions
  late List<PotionRecipe> _potionRecipes;

  // Animations
  late AnimationController _bubbleController;
  late AnimationController _sparkleController;
  late AnimationController _stirController;
  late AnimationController _successController;
  late Animation<double> _bubbleAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _stirAnimation;
  late Animation<double> _successAnimation;

  // Particles
  List<MagicParticle> _magicParticles = [];
  Timer? _particleTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initPotionRecipes();
    _initTts();
    _initAnimations();
    _startParticleGeneration();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isHebrew = Localizations.localeOf(context).languageCode == 'he';
      });
    });
  }

  void _initPotionRecipes() {
    _potionRecipes = [
      PotionRecipe('שיקוי הכוכבים', 'Starlight Potion', Colors.purple, '✨', '⭐'),
      PotionRecipe('שיקוי הקפיצה', 'Bounce Potion', Colors.green, '🍀', '🌿'),
      PotionRecipe('שיקוי האש', 'Fire Potion', Colors.red, '🔥', '🌶️'),
      PotionRecipe('שיקוי הקרח', 'Ice Potion', Colors.blue, '❄️', '💎'),
      PotionRecipe('שיקוי החכמה', 'Wisdom Potion', Colors.indigo, '📚', '🔮'),
      PotionRecipe('שיקוי המהירות', 'Speed Potion', Colors.yellow, '⚡', '🏃'),
      PotionRecipe('שיקוי הכוח', 'Strength Potion', Colors.orange, '💪', '🦁'),
      PotionRecipe('שיקוי הריפוי', 'Healing Potion', Colors.pink, '💖', '🌸'),
      PotionRecipe('שיקוי הזהב', 'Gold Potion', Colors.amber, '💰', '🪙'),
      PotionRecipe('שיקוי השינה', 'Sleep Potion', Colors.deepPurple, '😴', '🌙'),
      PotionRecipe('שיקוי הפרחים', 'Flower Potion', Colors.lightGreen, '🌺', '🌻'),
      PotionRecipe('שיקוי הקשת', 'Rainbow Potion', Colors.teal, '🌈', '🦄'),
      PotionRecipe('שיקוי התעופה', 'Flight Potion', Colors.cyan, '🪶', '🕊️'),
      PotionRecipe('שיקוי האור', 'Light Potion', Colors.lime, '💡', '🌟'),
      PotionRecipe('שיקוי הקסם', 'Magic Potion', Colors.deepOrange, '🎭', '✨'),
    ];
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage(_isHebrew ? 'he-IL' : 'en-US');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
  }

  void _initAnimations() {
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _bubbleAnimation = Tween<double>(begin: 0, end: 1).animate(_bubbleController);

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _sparkleAnimation = Tween<double>(begin: 0, end: 1).animate(_sparkleController);

    _stirController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _stirAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _stirController, curve: Curves.easeInOut),
    );

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _successAnimation = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );
  }

  void _startParticleGeneration() {
    _particleTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted || _currentScreen != 'lab') return;

      setState(() {
        _magicParticles.add(MagicParticle(
          x: _random.nextDouble(),
          y: _random.nextDouble() * 0.6 + 0.2,
          vx: (_random.nextDouble() - 0.5) * 0.003,
          vy: -_random.nextDouble() * 0.005,
          color: _currentPotion.color,
          size: _random.nextDouble() * 4 + 2,
        ));

        _magicParticles = _magicParticles.map((p) => p.update()).toList();
        _magicParticles.removeWhere((p) => p.life <= 0);
      });
    });
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  PotionRecipe get _currentPotion => _potionRecipes[_currentPotionIndex];

  void _startPotionBrewing() {
    // Generate division problem
    final divisors = [2, 3, 4, 5, 6];
    final vials = divisors[_random.nextInt(divisors.length)];
    final perVial = _random.nextInt(6) + 2;
    final total = vials * perVial;

    setState(() {
      _currentScreen = 'lab';
      _totalIngredients = total;
      _vials = vials;
      _correctAnswer = perVial;
      _vialDistribution = List.filled(vials, 0);
      _selectedAnswer = null;
      _isCorrect = null;
    });

    _speak(_isHebrew
        ? 'חלק $_total מרכיבים קסומים ל-$_vials מבחנות'
        : 'Divide $_total magic ingredients into $_vials vials');
  }

  void _addIngredientToVial(int vialIndex) {
    final totalDistributed = _vialDistribution.reduce((a, b) => a + b);
    if (totalDistributed < _totalIngredients!) {
      setState(() => _vialDistribution[vialIndex]++);
    }
  }

  void _removeIngredientFromVial(int vialIndex) {
    if (_vialDistribution[vialIndex] > 0) {
      setState(() => _vialDistribution[vialIndex]--);
    }
  }

  void _brewPotion() {
    final totalDistributed = _vialDistribution.reduce((a, b) => a + b);

    if (totalDistributed < _totalIngredients!) {
      _showSnackBar(
        _isHebrew
            ? 'חסרים מרכיבים! נשארו ${_totalIngredients! - totalDistributed}'
            : 'Missing ingredients! ${_totalIngredients! - totalDistributed} left',
        Colors.orange,
      );
      return;
    }

    if (totalDistributed > _totalIngredients!) {
      _showSnackBar(
        _isHebrew ? 'יותר מדי! יש רק $_totalIngredients מרכיבים' : 'Too many! Only $_totalIngredients ingredients',
        Colors.red,
      );
      return;
    }

    final allEqual =
        _vialDistribution.every((count) => count == _vialDistribution[0]);
    if (!allEqual) {
      _showSnackBar(
        _isHebrew ? 'לא שווה! כל מבחנה צריכה אותו מספר' : 'Not equal! Each vial needs the same amount',
        Colors.red,
      );
      return;
    }

    // Success!
    _showQuestionDialog();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showQuestionDialog() {
    final options = _generateOptions(_correctAnswer!);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _currentPotion.color.shade100,
                    _currentPotion.color.shade200,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isHebrew
                        ? 'כמה מרכיבים בכל מבחנה?'
                        : 'How many ingredients per vial?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.5,
                    children: options.map((option) {
                      final isSelected = _selectedAnswer == option;
                      final showResult = _isCorrect != null && isSelected;

                      return GestureDetector(
                        onTap: _isCorrect == null
                            ? () {
                                setDialogState(() {
                                  _selectedAnswer = option;
                                  _isCorrect = option == _correctAnswer;
                                });

                                if (_isCorrect!) {
                                  _speak(_isHebrew ? 'קסם מושלם!' : 'Perfect magic!');
                                } else {
                                  _speak(_isHebrew ? 'לא נכון, נסה שוב' : 'Wrong, try again');
                                }

                                Future.delayed(const Duration(milliseconds: 800), () {
                                  if (_isCorrect!) {
                                    Navigator.pop(context);
                                    _showSuccess();
                                  } else {
                                    setDialogState(() {
                                      _selectedAnswer = null;
                                      _isCorrect = null;
                                    });
                                  }
                                });
                              }
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: showResult
                                  ? (_isCorrect!
                                      ? [Colors.green.shade400, Colors.green.shade600]
                                      : [Colors.red.shade400, Colors.red.shade600])
                                  : [_currentPotion.color.shade300, _currentPotion.color.shade500],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              option.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<int> _generateOptions(int correct) {
    final options = <int>{correct};
    while (options.length < 4) {
      final offset = _random.nextInt(5) - 2;
      final option = (correct + offset).clamp(1, 20);
      options.add(option);
    }
    return options.toList()..shuffle();
  }

  void _showSuccess() {
    setState(() {
      _currentScreen = 'success';
      _collectedPotions[_currentPotionIndex] = true;
    });
    _successController.forward(from: 0);
    _speak(_isHebrew ? 'הכנת שיקוי קסום!' : 'You brewed a magic potion!');
  }

  void _nextPotion() {
    if (_currentPotionIndex < _totalPotions - 1) {
      setState(() {
        _currentPotionIndex++;
        _currentScreen = 'menu';
      });
    } else {
      _showGameComplete();
    }
  }

  void _showGameComplete() {
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
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                _isHebrew
                    ? 'אספת ${_collectedPotions.length} שיקויים!'
                    : 'Collected ${_collectedPotions.length} potions!',
                style: const TextStyle(fontSize: 18),
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
                        _currentPotionIndex = 0;
                        _collectedPotions.clear();
                        _currentScreen = 'menu';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade600,
                    ),
                    child: Text(_isHebrew ? 'התחל מחדש' : 'Start Over'),
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
    _particleTimer?.cancel();
    _flutterTts.stop();
    _bubbleController.dispose();
    _sparkleController.dispose();
    _stirController.dispose();
    _successController.dispose();
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
          child: _buildCurrentScreen(responsive),
        ),
      ),
    );
  }

  Widget _buildCurrentScreen(ResponsiveHelper responsive) {
    switch (_currentScreen) {
      case 'menu':
        return _buildMenuScreen(responsive);
      case 'lab':
        return _buildLabScreen(responsive);
      case 'book':
        return _buildPotionBookScreen(responsive);
      case 'success':
        return _buildSuccessScreen(responsive);
      default:
        return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildMenuScreen(ResponsiveHelper responsive) {
    return Column(
      children: [
        _buildMenuHeader(responsive),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(responsive.spacing(16)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(responsive.spacing(24)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _currentPotion.color.shade300.withOpacity(0.3),
                          _currentPotion.color.shade600.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.purple.shade300, width: 3),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _isHebrew ? _currentPotion.nameHe : _currentPotion.nameEn,
                          style: TextStyle(
                            fontSize: responsive.fontSize(28),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: responsive.spacing(16)),
                        Text(
                          '${_currentPotion.emoji} ${_currentPotion.ingredient}',
                          style: TextStyle(fontSize: responsive.iconSize(60)),
                        ),
                        SizedBox(height: responsive.spacing(16)),
                        Text(
                          _isHebrew
                              ? 'שיקוי ${_currentPotionIndex + 1} מתוך $_totalPotions'
                              : 'Potion ${_currentPotionIndex + 1} of $_totalPotions',
                          style: TextStyle(
                            fontSize: responsive.fontSize(16),
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: responsive.spacing(32)),
                  KidButton(
                    text: _isHebrew ? 'התחל לבשל! 🧪' : 'Start Brewing! 🧪',
                    icon: Icons.science,
                    onPressed: _startPotionBrewing,
                    color: _currentPotion.color,
                    height: 60,
                  ),
                  SizedBox(height: responsive.spacing(16)),
                  KidButton(
                    text: _isHebrew ? 'ספר השיקויים 📖' : 'Potion Book 📖',
                    icon: Icons.menu_book,
                    onPressed: () => setState(() => _currentScreen = 'book'),
                    color: Colors.amber.shade700,
                    height: 60,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuHeader(ResponsiveHelper responsive) {
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
            child: Text(
              _isHebrew ? '🧙‍♂️ קוסם השיקויים 🧙‍♀️' : '🧙‍♂️ Potion Master 🧙‍♀️',
              style: TextStyle(
                fontSize: responsive.fontSize(20),
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade100,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: responsive.spacing(48)),
        ],
      ),
    );
  }

  Widget _buildLabScreen(ResponsiveHelper responsive) {
    return Stack(
      children: [
        if (_magicParticles.isNotEmpty)
          CustomPaint(
            painter: MagicParticlePainter(_magicParticles),
            size: Size.infinite,
          ),
        Column(
          children: [
            _buildLabHeader(responsive),
            SizedBox(height: responsive.spacing(16)),
            _buildIngredientDisplay(responsive),
            SizedBox(height: responsive.spacing(16)),
            Expanded(child: _buildVialsArea(responsive)),
            _buildBrewButton(responsive),
            SizedBox(height: responsive.spacing(16)),
          ],
        ),
      ],
    );
  }

  Widget _buildLabHeader(ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(12)),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade800.withOpacity(0.9),
      ),
      child: Row(
        children: [
          KidBackButton(
            onPressed: () => setState(() => _currentScreen = 'menu'),
            color: Colors.purple.shade300,
            isHebrew: _isHebrew,
          ),
          Expanded(
            child: Text(
              _isHebrew ? _currentPotion.nameHe : _currentPotion.nameEn,
              style: TextStyle(
                fontSize: responsive.fontSize(18),
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade100,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: responsive.spacing(48)),
        ],
      ),
    );
  }

  Widget _buildIngredientDisplay(ResponsiveHelper responsive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
      padding: EdgeInsets.all(responsive.spacing(16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade800.withOpacity(0.7),
            Colors.indigo.shade800.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade300, width: 2),
      ),
      child: Column(
        children: [
          Text(
            _isHebrew ? 'מרכיבים קסומים:' : 'Magic Ingredients:',
            style: TextStyle(
              fontSize: responsive.fontSize(18),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: responsive.spacing(12)),
          AnimatedBuilder(
            animation: _sparkleAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: 0.7 + 0.3 * sin(_sparkleAnimation.value * 2 * pi),
                child: child,
              );
            },
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: List.generate(
                _totalIngredients!,
                (index) => Text(
                  _currentPotion.ingredient,
                  style: TextStyle(fontSize: responsive.iconSize(24)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVialsArea(ResponsiveHelper responsive) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          _vials!,
          (index) => Expanded(child: _buildVial(responsive, index)),
        ),
      ),
    );
  }

  Widget _buildVial(ResponsiveHelper responsive, int vialIndex) {
    final ingredients = _vialDistribution[vialIndex];

    return Container(
      margin: EdgeInsets.all(responsive.spacing(4)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _bubbleAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: VialPainter(
                  fillLevel: ingredients / 10,
                  color: _currentPotion.color,
                  bubbleValue: _bubbleAnimation.value,
                ),
                size: const Size(60, 120),
              );
            },
          ),
          SizedBox(height: responsive.spacing(8)),
          Text(
            ingredients.toString(),
            style: TextStyle(
              fontSize: responsive.fontSize(20),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: responsive.spacing(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () => _removeIngredientFromVial(vialIndex),
                icon: const Icon(Icons.remove_circle),
                color: Colors.red.shade300,
                iconSize: 28,
              ),
              IconButton(
                onPressed: () => _addIngredientToVial(vialIndex),
                icon: const Icon(Icons.add_circle),
                color: Colors.green.shade300,
                iconSize: 28,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrewButton(ResponsiveHelper responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
      child: KidButton(
        text: _isHebrew ? 'בשל שיקוי! ✨' : 'Brew Potion! ✨',
        icon: Icons.auto_fix_high,
        onPressed: _brewPotion,
        color: _currentPotion.color,
        height: 60,
      ),
    );
  }

  Widget _buildSuccessScreen(ResponsiveHelper responsive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _successAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _successAnimation.value,
              child: child,
            );
          },
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _currentPotion.color.shade300,
                  _currentPotion.color.shade600,
                  _currentPotion.color.shade900,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _currentPotion.color.withOpacity(0.6),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text(
                _currentPotion.emoji,
                style: TextStyle(fontSize: responsive.iconSize(80)),
              ),
            ),
          ),
        ),
        SizedBox(height: responsive.spacing(32)),
        Text(
          _isHebrew ? '✨ קסם מושלם! ✨' : '✨ Perfect Magic! ✨',
          style: TextStyle(
            fontSize: responsive.fontSize(32),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: responsive.spacing(16)),
        Text(
          _isHebrew ? _currentPotion.nameHe : _currentPotion.nameEn,
          style: TextStyle(
            fontSize: responsive.fontSize(24),
            color: _currentPotion.color.shade200,
          ),
        ),
        SizedBox(height: responsive.spacing(48)),
        KidButton(
          text: _isHebrew ? 'שיקוי הבא! →' : 'Next Potion! →',
          icon: Icons.arrow_forward,
          onPressed: _nextPotion,
          color: _currentPotion.color,
          height: 60,
        ),
      ],
    );
  }

  Widget _buildPotionBookScreen(ResponsiveHelper responsive) {
    return Column(
      children: [
        _buildBookHeader(responsive),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(responsive.spacing(16)),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: responsive.isTablet ? 4 : 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: _totalPotions,
            itemBuilder: (context, index) {
              final potion = _potionRecipes[index];
              final collected = _collectedPotions[index] ?? false;

              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: collected
                        ? [potion.color.shade300, potion.color.shade600]
                        : [Colors.grey.shade600, Colors.grey.shade800],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: collected ? potion.color.shade200 : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      collected ? potion.emoji : '❓',
                      style: TextStyle(fontSize: responsive.iconSize(40)),
                    ),
                    SizedBox(height: responsive.spacing(8)),
                    Text(
                      collected
                          ? (_isHebrew ? potion.nameHe : potion.nameEn)
                          : '???',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookHeader(ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(12)),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade800.withOpacity(0.9),
      ),
      child: Row(
        children: [
          KidBackButton(
            onPressed: () => setState(() => _currentScreen = 'menu'),
            color: Colors.purple.shade300,
            isHebrew: _isHebrew,
          ),
          Expanded(
            child: Text(
              _isHebrew ? '📖 ספר השיקויים 📖' : '📖 Potion Book 📖',
              style: TextStyle(
                fontSize: responsive.fontSize(20),
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade100,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: responsive.spacing(48)),
        ],
      ),
    );
  }
}

// Potion recipe data class
class PotionRecipe {
  final String nameHe;
  final String nameEn;
  final MaterialColor color;
  final String emoji;
  final String ingredient;

  PotionRecipe(this.nameHe, this.nameEn, this.color, this.emoji, this.ingredient);
}

// Magic particle class
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
      vy: vy,
      color: color,
      size: size * 0.97,
      life: life - 0.015,
    );
  }
}

// Magic particle painter
class MagicParticlePainter extends CustomPainter {
  final List<MagicParticle> particles;

  MagicParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.life * 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(MagicParticlePainter oldDelegate) => true;
}

// Vial painter with bubbles
class VialPainter extends CustomPainter {
  final double fillLevel;
  final Color color;
  final double bubbleValue;

  VialPainter({
    required this.fillLevel,
    required this.color,
    required this.bubbleValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final vialRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.2, 20, size.width * 0.6, size.height - 40),
      const Radius.circular(8),
    );

    // Vial outline
    final outlinePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(vialRect, outlinePaint);

    // Potion fill
    if (fillLevel > 0) {
      final fillHeight = (size.height - 60) * fillLevel;
      final fillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.2 + 3,
          size.height - 40 - fillHeight,
          size.width * 0.6 - 6,
          fillHeight,
        ),
        const Radius.circular(6),
      );

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.shade300.withOpacity(0.7),
            color.shade600,
          ],
        ).createShader(fillRect.outerRect);

      canvas.drawRRect(fillRect, fillPaint);

      // Bubbles
      final bubblePaint = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.fill;

      for (int i = 0; i < 3; i++) {
        final bubbleY = size.height -
            40 -
            (fillHeight * 0.3) -
            (sin(bubbleValue * 2 * pi + i) * 10);
        canvas.drawCircle(
          Offset(size.width * 0.5 + (i - 1) * 10, bubbleY),
          3,
          bubblePaint,
        );
      }
    }

    // Cork/cap
    final capPaint = Paint()
      ..color = Colors.brown.shade700
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.3, 10, size.width * 0.4, 15),
        const Radius.circular(4),
      ),
      capPaint,
    );
  }

  @override
  bool shouldRepaint(VialPainter oldDelegate) {
    return oldDelegate.fillLevel != fillLevel ||
        oldDelegate.bubbleValue != bubbleValue;
  }
}
