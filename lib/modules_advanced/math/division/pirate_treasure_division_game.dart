import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'dart:async';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/kid_button.dart';
import '../../../widgets/kid_back_button.dart';

/// משחק אוצר הפיראטים - הרפתקה עם מפת איים ואוצרות
class PirateTreasureDivisionGame extends StatefulWidget {
  const PirateTreasureDivisionGame({super.key});

  @override
  State<PirateTreasureDivisionGame> createState() =>
      _PirateTreasureDivisionGameState();
}

class _PirateTreasureDivisionGameState
    extends State<PirateTreasureDivisionGame> with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();
  bool _isHebrew = true;

  // Game progression
  int _currentIsland = 0;
  int _currentMission = 0;
  int _totalIslands = 5; // Reduced for better pacing
  int _missionsPerIsland = 5;

  // Collected treasures per island
  Map<int, int> _islandTreasures = {};

  // Current mission state
  String _currentScreen = 'map'; // 'map', 'mission', 'reward'
  int? _totalTreasure;
  int? _pirates;
  int? _correctAnswer;
  List<int> _treasureDistribution = [];
  List<int> _answerOptions = [];
  int? _selectedAnswer;
  bool? _isCorrect;

  // Animations
  late AnimationController _chestOpenController;
  late AnimationController _coinFallController;
  late AnimationController _shipSailController;
  late Animation<double> _chestOpenAnimation;
  late Animation<double> _coinFallAnimation;
  late Animation<double> _shipSailAnimation;

  // Treasure types
  final List<String> _treasureTypes = ['💎', '🪙', '🏺', '👑', '💍'];
  String _currentTreasureType = '💎';

  // Island names
  late List<String> _islandNamesHe;
  late List<String> _islandNamesEn;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initIslandNames();
    _initTts();
    _initAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isHebrew = Localizations.localeOf(context).languageCode == 'he';
      });
    });
  }

  void _initIslandNames() {
    _islandNamesHe = [
      'אי הדקלים',
      'אי האוצר הזהוב',
      'אי הגולגולת',
      'אי הקוקוס',
      'אי המסתורין',
    ];
    _islandNamesEn = [
      'Palm Island',
      'Golden Treasure Isle',
      'Skull Island',
      'Coconut Cay',
      'Mystery Island',
    ];
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage(_isHebrew ? 'he-IL' : 'en-US');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
  }

  void _initAnimations() {
    _chestOpenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _chestOpenAnimation = CurvedAnimation(
      parent: _chestOpenController,
      curve: Curves.easeOutBack,
    );

    _coinFallController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _coinFallAnimation = CurvedAnimation(
      parent: _coinFallController,
      curve: Curves.bounceOut,
    );

    _shipSailController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _shipSailAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _shipSailController, curve: Curves.easeInOut),
    );
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _startMission() {
    // Generate division problem
    final divisors = [2, 3, 4, 5, 6];
    final pirates = divisors[_random.nextInt(divisors.length)];
    final perPirate = _random.nextInt(6) + 2; // 2-7 treasures per pirate
    final total = pirates * perPirate;

    _currentTreasureType = _treasureTypes[_random.nextInt(_treasureTypes.length)];

    setState(() {
      _currentScreen = 'mission';
      _totalTreasure = total;
      _pirates = pirates;
      _correctAnswer = perPirate;
      _treasureDistribution = List.filled(pirates, 0);
      _selectedAnswer = null;
      _isCorrect = null;
    });

    _speak(_isHebrew
        ? 'חלק $_totalTreasure אוצרות באופן שווה בין $_pirates פיראטים'
        : 'Share $_totalTreasure treasures equally among $_pirates pirates');
  }

  void _addTreasureToPirate(int pirateIndex) {
    final totalDistributed = _treasureDistribution.reduce((a, b) => a + b);
    if (totalDistributed < _totalTreasure!) {
      setState(() => _treasureDistribution[pirateIndex]++);
    }
  }

  void _removeTreasureFromPirate(int pirateIndex) {
    if (_treasureDistribution[pirateIndex] > 0) {
      setState(() => _treasureDistribution[pirateIndex]--);
    }
  }

  void _checkDistribution() {
    final totalDistributed = _treasureDistribution.reduce((a, b) => a + b);

    if (totalDistributed < _totalTreasure!) {
      _showSnackBar(
        _isHebrew
            ? 'עדיין יש אוצרות לחלק! נשארו ${_totalTreasure! - totalDistributed}'
            : 'Still have treasures to share! ${_totalTreasure! - totalDistributed} left',
        Colors.orange,
      );
      return;
    }

    if (totalDistributed > _totalTreasure!) {
      _showSnackBar(
        _isHebrew ? 'יותר מדי! יש רק $_totalTreasure אוצרות' : 'Too many! Only $_totalTreasure treasures',
        Colors.red,
      );
      return;
    }

    final allEqual =
        _treasureDistribution.every((count) => count == _treasureDistribution[0]);
    if (!allEqual) {
      _showSnackBar(
        _isHebrew ? 'החלוקה לא שווה! כל פיראט צריך לקבל אותו מספר' : 'Not equal! Each pirate needs the same amount',
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
                  colors: [Colors.amber.shade100, Colors.orange.shade100],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isHebrew
                        ? 'כמה אוצרות קיבל כל פיראט?'
                        : 'How many treasures did each pirate get?',
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
                                  _speak(_isHebrew ? 'מושלם!' : 'Perfect!');
                                } else {
                                  _speak(_isHebrew ? 'לא נכון, נסה שוב' : 'Wrong, try again');
                                }

                                Future.delayed(const Duration(milliseconds: 800), () {
                                  if (_isCorrect!) {
                                    Navigator.pop(context);
                                    _showReward();
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
                                  : [Colors.amber.shade200, Colors.orange.shade300],
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

  void _showReward() {
    setState(() {
      _currentScreen = 'reward';
      _islandTreasures[_currentIsland] =
          (_islandTreasures[_currentIsland] ?? 0) + 1;
      _currentMission++;
    });

    _chestOpenController.forward(from: 0);
    _coinFallController.forward(from: 0);

    _speak(_isHebrew ? 'מצאת אוצר!' : 'You found treasure!');
  }

  void _continueToNextMission() {
    if (_currentMission >= _missionsPerIsland) {
      // Island completed
      _showIslandCompleteDialog();
    } else {
      _startMission();
    }
  }

  void _showIslandCompleteDialog() {
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
              colors: [Colors.yellow.shade100, Colors.amber.shade200],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🏝️ 🎉 🏝️',
                style: TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 16),
              Text(
                _isHebrew ? 'סיימת את ${_islandNamesHe[_currentIsland]}!' : 'Completed ${_islandNamesEn[_currentIsland]}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _isHebrew ? 'אספת ${_islandTreasures[_currentIsland]} אוצרות!' : 'Collected ${_islandTreasures[_currentIsland]} treasures!',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentIsland++;
                    _currentMission = 0;
                    _currentScreen = 'map';
                  });
                  if (_currentIsland >= _totalIslands) {
                    _showGameComplete();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text(
                  _currentIsland < _totalIslands - 1
                      ? (_isHebrew ? 'לאי הבא! ⛵' : 'Next Island! ⛵')
                      : (_isHebrew ? 'המשך' : 'Continue'),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGameComplete() {
    final totalTreasures = _islandTreasures.values.fold(0, (a, b) => a + b);
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
              colors: [Colors.yellow.shade200, Colors.amber.shade300],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏴‍☠️ 👑 🏴‍☠️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                _isHebrew ? 'מלך הפיראטים!' : 'Pirate King!',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                _isHebrew ? 'סיימת את כל האיים!' : 'Completed all islands!',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                _isHebrew ? 'סה"כ אוצרות: $totalTreasures' : 'Total treasures: $totalTreasures',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                        _currentIsland = 0;
                        _currentMission = 0;
                        _islandTreasures.clear();
                        _currentScreen = 'map';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
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
    _chestOpenController.dispose();
    _coinFallController.dispose();
    _shipSailController.dispose();
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade400,
              Colors.cyan.shade300,
              Colors.yellow.shade100,
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
      case 'map':
        return _buildIslandMap(responsive);
      case 'mission':
        return _buildMissionScreen(responsive);
      case 'reward':
        return _buildRewardScreen(responsive);
      default:
        return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildIslandMap(ResponsiveHelper responsive) {
    return Column(
      children: [
        _buildMapHeader(responsive),
        Expanded(
          child: Stack(
            children: [
              // Ocean waves
              CustomPaint(
                painter: OceanPainter(),
                size: Size.infinite,
              ),
              // Islands
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(responsive.spacing(16)),
                  child: Wrap(
                    spacing: responsive.spacing(20),
                    runSpacing: responsive.spacing(20),
                    alignment: WrapAlignment.center,
                    children: List.generate(_totalIslands, (index) {
                      return _buildIslandButton(responsive, index);
                    }),
                  ),
                ),
              ),
              // Sailing ship animation
              AnimatedBuilder(
                animation: _shipSailAnimation,
                builder: (context, child) {
                  return Positioned(
                    bottom: 100,
                    left: MediaQuery.of(context).size.width * 0.1 +
                        _shipSailAnimation.value,
                    child: const Text('⛵', style: TextStyle(fontSize: 40)),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapHeader(ResponsiveHelper responsive) {
    final totalTreasures = _islandTreasures.values.fold(0, (a, b) => a + b);
    return Container(
      padding: EdgeInsets.all(responsive.spacing(12)),
      decoration: BoxDecoration(
        color: Colors.brown.shade700.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          KidBackButton(
            onPressed: () => Navigator.pop(context),
            color: Colors.amber.shade600,
            isHebrew: _isHebrew,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  _isHebrew ? '🏴‍☠️ אוצר הפיראטים 🏴‍☠️' : '🏴‍☠️ Pirate\'s Treasure 🏴‍☠️',
                  style: TextStyle(
                    fontSize: responsive.fontSize(20),
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade100,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  _isHebrew ? 'אוצרות שנאספו: $totalTreasures' : 'Treasures collected: $totalTreasures',
                  style: TextStyle(
                    fontSize: responsive.fontSize(14),
                    color: Colors.yellow.shade200,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: responsive.spacing(48)),
        ],
      ),
    );
  }

  Widget _buildIslandButton(ResponsiveHelper responsive, int index) {
    final isCompleted = (_islandTreasures[index] ?? 0) >= _missionsPerIsland;
    final isLocked = index > _currentIsland;
    final isCurrent = index == _currentIsland;

    return GestureDetector(
      onTap: isLocked
          ? null
          : () {
              setState(() {
                _currentIsland = index;
                _currentMission = 0;
              });
              _startMission();
            },
      child: Container(
        width: 120,
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isLocked
                ? [Colors.grey.shade400, Colors.grey.shade600]
                : isCompleted
                    ? [Colors.green.shade300, Colors.green.shade600]
                    : isCurrent
                        ? [Colors.amber.shade300, Colors.orange.shade500]
                        : [Colors.brown.shade300, Colors.brown.shade600],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCurrent ? Colors.yellow : Colors.brown.shade800,
            width: isCurrent ? 4 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLocked ? '🔒' : isCompleted ? '✅' : '🏝️',
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 8),
            Text(
              _isHebrew ? _islandNamesHe[index] : _islandNamesEn[index],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isLocked)
              Text(
                '${_islandTreasures[index] ?? 0}/$_missionsPerIsland',
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionScreen(ResponsiveHelper responsive) {
    return Column(
      children: [
        _buildMissionHeader(responsive),
        SizedBox(height: responsive.spacing(16)),
        _buildTaskDescription(responsive),
        SizedBox(height: responsive.spacing(16)),
        Expanded(child: _buildPiratesArea(responsive)),
        _buildMissionControls(responsive),
        SizedBox(height: responsive.spacing(16)),
      ],
    );
  }

  Widget _buildMissionHeader(ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(12)),
      decoration: BoxDecoration(
        color: Colors.brown.shade700.withOpacity(0.9),
      ),
      child: Row(
        children: [
          KidBackButton(
            onPressed: () => setState(() => _currentScreen = 'map'),
            color: Colors.amber.shade600,
            isHebrew: _isHebrew,
          ),
          Expanded(
            child: Text(
              _isHebrew
                  ? '${_islandNamesHe[_currentIsland]} - משימה ${_currentMission + 1}'
                  : '${_islandNamesEn[_currentIsland]} - Mission ${_currentMission + 1}',
              style: TextStyle(
                fontSize: responsive.fontSize(18),
                fontWeight: FontWeight.bold,
                color: Colors.amber.shade100,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: responsive.spacing(48)),
        ],
      ),
    );
  }

  Widget _buildTaskDescription(ResponsiveHelper responsive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
      padding: EdgeInsets.all(responsive.spacing(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade600, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _isHebrew
                ? 'חלק את האוצר באופן שווה:'
                : 'Share the treasure equally:',
            style: TextStyle(
              fontSize: responsive.fontSize(18),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.spacing(12)),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: List.generate(
              _totalTreasure!,
              (index) => Text(_currentTreasureType,
                  style: TextStyle(fontSize: responsive.iconSize(24))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPiratesArea(ResponsiveHelper responsive) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          _pirates!,
          (index) => Expanded(child: _buildPirateCard(responsive, index)),
        ),
      ),
    );
  }

  Widget _buildPirateCard(ResponsiveHelper responsive, int pirateIndex) {
    final treasures = _treasureDistribution[pirateIndex];

    return Container(
      margin: EdgeInsets.all(responsive.spacing(4)),
      padding: EdgeInsets.all(responsive.spacing(8)),
      decoration: BoxDecoration(
        color: Colors.brown.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.brown.shade700, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🏴‍☠️', style: TextStyle(fontSize: responsive.iconSize(32))),
          SizedBox(height: responsive.spacing(8)),
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade700, width: 2),
            ),
            child: Center(
              child: Wrap(
                spacing: 2,
                runSpacing: 2,
                alignment: WrapAlignment.center,
                children: List.generate(
                  treasures,
                  (index) => Text(_currentTreasureType,
                      style: TextStyle(fontSize: responsive.iconSize(20))),
                ),
              ),
            ),
          ),
          SizedBox(height: responsive.spacing(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () => _removeTreasureFromPirate(pirateIndex),
                icon: const Icon(Icons.remove_circle),
                color: Colors.red.shade600,
                iconSize: 28,
              ),
              IconButton(
                onPressed: () => _addTreasureToPirate(pirateIndex),
                icon: const Icon(Icons.add_circle),
                color: Colors.green.shade600,
                iconSize: 28,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissionControls(ResponsiveHelper responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
      child: KidButton(
        text: _isHebrew ? 'בדוק חלוקה ✓' : 'Check Division ✓',
        icon: Icons.check_circle,
        onPressed: _checkDistribution,
        color: Colors.green.shade600,
        height: 60,
      ),
    );
  }

  Widget _buildRewardScreen(ResponsiveHelper responsive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _chestOpenAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: TreasureChestPainter(_chestOpenAnimation.value),
              size: const Size(200, 200),
            );
          },
        ),
        SizedBox(height: responsive.spacing(24)),
        AnimatedBuilder(
          animation: _coinFallAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -100 * (1 - _coinFallAnimation.value)),
              child: Opacity(
                opacity: _coinFallAnimation.value,
                child: Text(
                  _currentTreasureType * 5,
                  style: TextStyle(fontSize: responsive.iconSize(60)),
                ),
              ),
            );
          },
        ),
        SizedBox(height: responsive.spacing(24)),
        Text(
          _isHebrew ? '🎉 מצאת אוצר! 🎉' : '🎉 Found Treasure! 🎉',
          style: TextStyle(
            fontSize: responsive.fontSize(28),
            fontWeight: FontWeight.bold,
            color: Colors.amber.shade900,
          ),
        ),
        SizedBox(height: responsive.spacing(32)),
        KidButton(
          text: _isHebrew ? 'המשך להרפתקה! →' : 'Continue Adventure! →',
          icon: Icons.arrow_forward,
          onPressed: _continueToNextMission,
          color: Colors.amber.shade700,
          height: 60,
        ),
      ],
    );
  }
}

// Ocean wave painter
class OceanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.blue.shade300.withOpacity(0.3),
          Colors.cyan.shade200.withOpacity(0.3),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height * 0.7);

    for (double i = 0; i < size.width; i += 50) {
      path.quadraticBezierTo(
        i + 25,
        size.height * 0.65,
        i + 50,
        size.height * 0.7,
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Treasure chest painter
class TreasureChestPainter extends CustomPainter {
  final double openValue;

  TreasureChestPainter(this.openValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Chest bottom
    final bottomPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.brown.shade600, Colors.brown.shade800],
      ).createShader(Rect.fromCenter(center: center, width: 150, height: 80));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, center.dy + 20), width: 150, height: 80),
        const Radius.circular(8),
      ),
      bottomPaint,
    );

    // Chest lid
    canvas.save();
    canvas.translate(center.dx, center.dy - 20);
    canvas.rotate(-openValue * 1.2);
    canvas.translate(-center.dx, -(center.dy - 20));

    final lidPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.brown.shade500, Colors.brown.shade700],
      ).createShader(Rect.fromCenter(center: Offset(center.dx, center.dy - 20), width: 150, height: 40));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, center.dy - 20), width: 150, height: 40),
        const Radius.circular(8),
      ),
      lidPaint,
    );

    canvas.restore();

    // Lock
    final lockPaint = Paint()..color = Colors.yellow.shade700;
    canvas.drawCircle(Offset(center.dx, center.dy), 8, lockPaint);
  }

  @override
  bool shouldRepaint(TreasureChestPainter oldDelegate) =>
      oldDelegate.openValue != openValue;
}
