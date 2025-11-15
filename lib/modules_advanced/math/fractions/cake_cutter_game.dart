import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/kid_button.dart';
import '../../../widgets/kid_back_button.dart';

/// משחק חותך עוגות - למד שברים בסיסיים
class CakeCutterGame extends StatefulWidget {
  const CakeCutterGame({super.key});

  @override
  State<CakeCutterGame> createState() => _CakeCutterGameState();
}

class _CakeCutterGameState extends State<CakeCutterGame> {
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();
  bool _isHebrew = true;

  int? _targetPieces; // Number of pieces to cut into
  int _currentCuts = 0; // Number of cuts made
  bool _showQuestion = false;
  String? _selectedAnswer;
  bool? _isCorrect;
  int _score = 0;
  int _round = 1;
  final int _totalRounds = 5;

  // Fraction names in Hebrew and English
  final Map<int, Map<String, String>> _fractionNames = {
    2: {'he': '½ (חצי)', 'en': '½ (half)'},
    3: {'he': '⅓ (שליש)', 'en': '⅓ (third)'},
    4: {'he': '¼ (רבע)', 'en': '¼ (quarter)'},
    5: {'he': '⅕ (חמישית)', 'en': '⅕ (fifth)'},
    6: {'he': '⅙ (שישית)', 'en': '⅙ (sixth)'},
  };

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
    final pieces = [2, 3, 4, 5, 6][_random.nextInt(5)];

    setState(() {
      _targetPieces = pieces;
      _currentCuts = 0;
      _showQuestion = false;
      _selectedAnswer = null;
      _isCorrect = null;
    });

    // Speak the task
    final fractionName = _fractionNames[pieces]![_isHebrew ? 'he' : 'en'];
    _speak(_isHebrew
        ? 'חתוך את העוגה ל-$_targetPieces חלקים שווים. כל חלק הוא $fractionName'
        : 'Cut the cake into $_targetPieces equal pieces. Each piece is $fractionName');
  }

  void _addCut() {
    if (_currentCuts < _targetPieces! - 1) {
      setState(() {
        _currentCuts++;
      });
    }
  }

  void _removeCut() {
    if (_currentCuts > 0) {
      setState(() {
        _currentCuts--;
      });
    }
  }

  void _checkCuts() {
    final pieces = _currentCuts + 1; // Number of pieces = cuts + 1

    if (pieces == _targetPieces) {
      _showQuestionDialog();
    } else if (pieces < _targetPieces!) {
      _showSnackBar(
        _isHebrew
            ? 'צריך עוד חתכים! המטרה: $_targetPieces חלקים'
            : 'Need more cuts! Target: $_targetPieces pieces',
        Colors.orange,
      );
    } else {
      _showSnackBar(
        _isHebrew
            ? 'יותר מדי חתכים! המטרה: $_targetPieces חלקים'
            : 'Too many cuts! Target: $_targetPieces pieces',
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
    final correctAnswer = _fractionNames[_targetPieces]![_isHebrew ? 'he' : 'en']!;
    final options = _generateOptions(_targetPieces!);

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
                  colors: [Colors.pink.shade50, Colors.purple.shade50],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Question
                  Text(
                    _isHebrew
                        ? 'מה גודל כל חלק?'
                        : 'What is the size of each piece?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink.shade700,
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
                    childAspectRatio: 2.5,
                    children: options.map((option) {
                      final isSelected = _selectedAnswer == option;
                      final showResult = _isCorrect != null && isSelected;

                      return GestureDetector(
                        onTap: _isCorrect == null
                            ? () {
                                setDialogState(() {
                                  _selectedAnswer = option;
                                  _isCorrect = option == correctAnswer;
                                });

                                if (_isCorrect!) {
                                  _speak(_isHebrew ? 'נהדר!' : 'Great!');
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
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  option,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
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

  List<String> _generateOptions(int correct) {
    final options = <String>{_fractionNames[correct]![_isHebrew ? 'he' : 'en']!};
    final allFractions = _fractionNames.keys.toList()..shuffle();

    for (final num in allFractions) {
      if (options.length >= 4) break;
      if (num != correct) {
        options.add(_fractionNames[num]![_isHebrew ? 'he' : 'en']!);
      }
    }

    final list = options.toList()..shuffle();
    return list;
  }

  void _showFinalScore() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          _isHebrew ? '🎉 כל הכבוד! 🎉' : '🎉 Well Done! 🎉',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isHebrew ? 'סיימת את המשחק!' : 'You finished the game!',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              _isHebrew ? 'תשובות נכונות:' : 'Correct answers:',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              '$_score / $_totalRounds',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _isHebrew
                  ? 'ציון: ${((_score / _totalRounds) * 100).round()}%'
                  : 'Score: ${((_score / _totalRounds) * 100).round()}%',
              style: TextStyle(
                fontSize: 24,
                color: Colors.pink.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              _isHebrew ? 'יציאה' : 'Exit',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _score = 0;
                _round = 1;
                _startNewRound();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade600,
            ),
            child: Text(
              _isHebrew ? 'שחק שוב' : 'Play Again',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
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
            colors: [Colors.pink.shade50, Colors.purple.shade50],
          ),
        ),
        child: SafeArea(
          child: _targetPieces == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildHeader(responsive),
                    SizedBox(height: responsive.spacing(12)),
                    _buildTask(responsive),
                    SizedBox(height: responsive.spacing(16)),
                    Expanded(child: _buildCake(responsive)),
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
            color: Colors.pink.shade600,
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
        color: Colors.pink.shade100,
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
                  color: Colors.pink.shade800,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: responsive.fontSize(10),
                  color: Colors.pink.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTask(ResponsiveHelper responsive) {
    final fractionName = _fractionNames[_targetPieces]![_isHebrew ? 'he' : 'en'];
    return Container(
      margin: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
      padding: EdgeInsets.all(responsive.spacing(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pink.shade300, width: 2),
      ),
      child: Column(
        children: [
          Text(
            _isHebrew
                ? 'חתוך את העוגה ל-$_targetPieces חלקים שווים'
                : 'Cut the cake into $_targetPieces equal pieces',
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.spacing(4)),
          Text(
            _isHebrew ? 'כל חלק: $fractionName' : 'Each piece: $fractionName',
            style: TextStyle(
              fontSize: responsive.fontSize(14),
              color: Colors.pink.shade700,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCake(ResponsiveHelper responsive) {
    return Center(
      child: CustomPaint(
        size: const Size(280, 280),
        painter: CakePainter(cuts: _currentCuts, targetPieces: _targetPieces!),
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
                  text: _isHebrew ? 'הסר חתך 🗑️' : 'Remove Cut 🗑️',
                  icon: Icons.remove_circle,
                  onPressed: _removeCut,
                  color: Colors.red.shade600,
                  height: 60,
                ),
              ),
              SizedBox(width: responsive.spacing(12)),
              Expanded(
                child: KidButton(
                  text: _isHebrew ? 'הוסף חתך ➕' : 'Add Cut ➕',
                  icon: Icons.add_circle,
                  onPressed: _addCut,
                  color: Colors.blue.shade600,
                  height: 60,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(12)),
          KidButton(
            text: _isHebrew ? 'בדוק חתכים ✓' : 'Check Cuts ✓',
            icon: Icons.check_circle,
            onPressed: _checkCuts,
            color: Colors.green.shade600,
            height: 60,
          ),
        ],
      ),
    );
  }
}

/// Custom painter for drawing a cake with cuts
class CakePainter extends CustomPainter {
  final int cuts;
  final int targetPieces;

  CakePainter({required this.cuts, required this.targetPieces});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Draw cake base (circle)
    final cakePaint = Paint()
      ..color = Colors.pink.shade200
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, cakePaint);

    // Draw frosting (lighter pink circle on top)
    final frostingPaint = Paint()
      ..color = Colors.pink.shade100
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.9, frostingPaint);

    // Draw decorative dots
    final decorationPaint = Paint()
      ..color = Colors.pink.shade400
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final angle = (i * pi * 2) / 12;
      final r = radius * 0.7;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      canvas.drawCircle(Offset(x, y), 4, decorationPaint);
    }

    // Draw cut lines
    final linePaint = Paint()
      ..color = Colors.brown.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (int i = 0; i < cuts + 1; i++) {
      final angle = (i * pi * 2) / targetPieces - pi / 2;
      final endX = center.dx + radius * cos(angle);
      final endY = center.dy + radius * sin(angle);
      canvas.drawLine(center, Offset(endX, endY), linePaint);
    }

    // Draw cake border
    final borderPaint = Paint()
      ..color = Colors.brown.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(CakePainter oldDelegate) {
    return oldDelegate.cuts != cuts || oldDelegate.targetPieces != targetPieces;
  }
}
