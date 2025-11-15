import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/kid_button.dart';
import '../../../widgets/kid_back_button.dart';
import '../../../widgets/reward_animation.dart';

/// משחק מסיבת פיצה - למד חילוק באמצעות חיתוך פיצות
class PizzaPartyGame extends StatefulWidget {
  const PizzaPartyGame({super.key});

  @override
  State<PizzaPartyGame> createState() => _PizzaPartyGameState();
}

class _PizzaPartyGameState extends State<PizzaPartyGame> {
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();
  bool _isHebrew = true;

  int? _targetSlices;
  int _currentSlices = 1; // Start with whole pizza (1 piece)
  bool _showQuestion = false;
  int? _selectedAnswer;
  bool? _isCorrect;
  int _score = 0;
  int _round = 1;
  final int _totalRounds = 5;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isHebrew = Localizations.localeOf(context).languageCode == 'he';
      });
      _startNewRound();
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage(_isHebrew ? 'he-IL' : 'en-US');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _startNewRound() {
    final slicesOptions = [2, 3, 4, 5, 6, 8];
    final targetSlices = slicesOptions[_random.nextInt(slicesOptions.length)];

    setState(() {
      _targetSlices = targetSlices;
      _currentSlices = 1;
      _showQuestion = false;
      _selectedAnswer = null;
      _isCorrect = null;
    });

    // Speak the task
    _speak(_isHebrew
        ? 'חתוך את הפיצה ל-$_targetSlices פלחים שווים'
        : 'Cut the pizza into $_targetSlices equal slices');
  }

  void _addSlice() {
    if (_currentSlices < 12) {
      setState(() {
        _currentSlices++;
      });
    }
  }

  void _removeSlice() {
    if (_currentSlices > 1) {
      setState(() {
        _currentSlices--;
      });
    }
  }

  void _checkSlices() {
    if (_currentSlices == _targetSlices) {
      _showQuestionDialog();
    } else if (_currentSlices < _targetSlices!) {
      _showSnackBar(
        _isHebrew
            ? 'צריך עוד פלחים! המטרה: $_targetSlices פלחים'
            : 'Need more slices! Target: $_targetSlices slices',
        Colors.orange,
      );
    } else {
      _showSnackBar(
        _isHebrew
            ? 'יותר מדי פלחים! המטרה: $_targetSlices פלחים'
            : 'Too many slices! Target: $_targetSlices slices',
        Colors.red,
      );
    }
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
    final options = _generateOptions(_targetSlices!);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.red.shade50, Colors.orange.shade50],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Question
                  Text(
                    _isHebrew
                        ? 'לכמה פלחים חילקת את הפיצה?'
                        : 'How many slices did you divide the pizza into?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Answer options in 2x2 grid
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3.0,
                    children: options.map((option) {
                      final isSelected = _selectedAnswer == option;
                      final showResult = _isCorrect != null && isSelected;

                      return GestureDetector(
                        onTap: _isCorrect == null
                            ? () {
                                setDialogState(() {
                                  _selectedAnswer = option;
                                  _isCorrect = option == _targetSlices;
                                });

                                if (_isCorrect!) {
                                  _speak(_isHebrew ? 'מעולה!' : 'Excellent!');
                                } else {
                                  _speak(_isHebrew ? 'נסה שוב' : 'Try again');
                                }

                                Future.delayed(const Duration(milliseconds: 800), () {
                                  if (_isCorrect!) {
                                    Navigator.pop(context);
                                    setState(() {
                                      _score++;
                                      if (_round < _totalRounds) {
                                        _round++;
                                        _startNewRound();
                                      } else {
                                        _showFinalScore();
                                      }
                                    });
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
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: showResult
                                  ? (_isCorrect!
                                      ? [Colors.green.shade400, Colors.green.shade600]
                                      : [Colors.red.shade400, Colors.red.shade600])
                                  : [Colors.blue.shade300, Colors.blue.shade500],
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
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
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
      final option = (correct + offset).clamp(2, 12);
      options.add(option);
    }
    final list = options.toList()..shuffle();
    return list;
  }

  void _showFinalScore() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RewardAnimation(
        score: _score,
        totalQuestions: _totalRounds,
        onPlayAgain: () {
          Navigator.pop(context);
          setState(() {
            _score = 0;
            _round = 1;
            _startNewRound();
          });
        },
        onExit: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
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
            colors: [Colors.red.shade50, Colors.orange.shade50],
          ),
        ),
        child: SafeArea(
          child: _targetSlices == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildHeader(responsive),
                    SizedBox(height: responsive.spacing(12)),
                    _buildTask(responsive),
                    SizedBox(height: responsive.spacing(16)),
                    Expanded(child: _buildPizza(responsive)),
                    SizedBox(height: responsive.spacing(16)),
                    _buildControls(responsive),
                    SizedBox(height: responsive.spacing(12)),
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          KidBackButton(
            onPressed: () => Navigator.pop(context),
            color: Colors.red.shade600,
            isHebrew: _isHebrew,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  responsive,
                  icon: '🎯',
                  value: '$_round/$_totalRounds',
                  label: _isHebrew ? 'סיבוב' : 'Round',
                ),
                _buildStatCard(
                  responsive,
                  icon: '⭐',
                  value: '$_score',
                  label: _isHebrew ? 'נכונות' : 'Score',
                ),
              ],
            ),
          ),
          SizedBox(width: responsive.spacing(48)),
        ],
      ),
    );
  }

  Widget _buildStatCard(ResponsiveHelper responsive,
      {required String icon, required String value, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing(12),
        vertical: responsive.spacing(6),
      ),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: TextStyle(fontSize: responsive.iconSize(20))),
          SizedBox(width: responsive.spacing(6)),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: responsive.fontSize(16),
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: responsive.fontSize(10),
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTask(ResponsiveHelper responsive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
      padding: EdgeInsets.all(responsive.spacing(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade300, width: 2),
      ),
      child: Column(
        children: [
          Text(
            _isHebrew
                ? 'חתוך את הפיצה ל-$_targetSlices פלחים שווים'
                : 'Cut the pizza into $_targetSlices equal slices',
            style: TextStyle(
              fontSize: responsive.fontSize(18),
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.spacing(4)),
          Text(
            _isHebrew ? 'פלחים נוכחיים: $_currentSlices' : 'Current slices: $_currentSlices',
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPizza(ResponsiveHelper responsive) {
    return Center(
      child: CustomPaint(
        size: const Size(280, 280),
        painter: PizzaPainter(slices: _currentSlices),
      ),
    );
  }

  Widget _buildControls(ResponsiveHelper responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: KidButton(
                  text: _isHebrew ? 'הסר פלח 🗑️' : 'Remove Slice 🗑️',
                  icon: Icons.remove_circle,
                  onPressed: _removeSlice,
                  color: Colors.red.shade600,
                  height: 60,
                ),
              ),
              SizedBox(width: responsive.spacing(12)),
              Expanded(
                child: KidButton(
                  text: _isHebrew ? 'הוסף פלח ➕' : 'Add Slice ➕',
                  icon: Icons.add_circle,
                  onPressed: _addSlice,
                  color: Colors.blue.shade600,
                  height: 60,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(12)),
          KidButton(
            text: _isHebrew ? 'בדוק פלחים ✓' : 'Check Slices ✓',
            icon: Icons.check_circle,
            onPressed: _checkSlices,
            color: Colors.green.shade600,
            height: 60,
          ),
        ],
      ),
    );
  }
}

/// Custom painter for drawing a pizza with slices
class PizzaPainter extends CustomPainter {
  final int slices;

  PizzaPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Draw pizza base
    final pizzaPaint = Paint()
      ..color = Colors.orange.shade300
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, pizzaPaint);

    // Draw pizza border (crust)
    final crustPaint = Paint()
      ..color = Colors.brown.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(center, radius, crustPaint);

    // Draw cheese pattern (yellow dots)
    final cheesePaint = Paint()
      ..color = Colors.yellow.shade600
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final angle = (i * pi * 2) / 20;
      final r = radius * 0.6;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      canvas.drawCircle(Offset(x, y), 4, cheesePaint);
    }

    // Draw pepperoni
    final pepperoniPaint = Paint()
      ..color = Colors.red.shade700
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final angle = (i * pi * 2) / 12 + 0.5;
      final r = radius * 0.4;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      canvas.drawCircle(Offset(x, y), 8, pepperoniPaint);
    }

    // Draw slice lines
    final linePaint = Paint()
      ..color = Colors.brown.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (int i = 0; i < slices; i++) {
      final angle = (i * pi * 2) / slices - pi / 2;
      final endX = center.dx + radius * cos(angle);
      final endY = center.dy + radius * sin(angle);
      canvas.drawLine(center, Offset(endX, endY), linePaint);
    }
  }

  @override
  bool shouldRepaint(PizzaPainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}
