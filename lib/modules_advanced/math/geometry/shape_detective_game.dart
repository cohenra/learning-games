import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/kid_button.dart';
import '../../../widgets/kid_back_button.dart';

/// משחק בלש הצורות - זהה צורות גיאומטריות
class ShapeDetectiveGame extends StatefulWidget {
  const ShapeDetectiveGame({super.key});

  @override
  State<ShapeDetectiveGame> createState() => _ShapeDetectiveGameState();
}

class _ShapeDetectiveGameState extends State<ShapeDetectiveGame> {
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();
  bool _isHebrew = true;

  String? _currentShape;
  String? _selectedAnswer;
  bool? _isCorrect;
  int _score = 0;
  int _round = 1;
  final int _totalRounds = 10;

  final Map<String, Map<String, String>> _shapes = {
    'circle': {'he': 'עיגול', 'en': 'Circle'},
    'square': {'he': 'ריבוע', 'en': 'Square'},
    'triangle': {'he': 'משולש', 'en': 'Triangle'},
    'rectangle': {'he': 'מלבן', 'en': 'Rectangle'},
    'pentagon': {'he': 'מחומש', 'en': 'Pentagon'},
    'hexagon': {'he': 'משושה', 'en': 'Hexagon'},
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
    final shapeKeys = _shapes.keys.toList()..shuffle();
    final shape = shapeKeys.first;

    setState(() {
      _currentShape = shape;
      _selectedAnswer = null;
      _isCorrect = null;
    });

    // Speak the task
    _speak(_isHebrew ? 'איזו צורה זאת?' : 'What shape is this?');
  }

  void _checkAnswer(String answer) {
    final correctAnswer = _shapes[_currentShape]![_isHebrew ? 'he' : 'en']!;
    final isCorrect = answer == correctAnswer;

    setState(() {
      _selectedAnswer = answer;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      _speak(_isHebrew ? 'נכון! ${_shapes[_currentShape]!['he']}' : 'Correct! ${_shapes[_currentShape]!['en']}');
      setState(() {
        _score++;
      });
    } else {
      _speak(_isHebrew ? 'לא נכון. זה ${_shapes[_currentShape]!['he']}' : 'Incorrect. This is ${_shapes[_currentShape]!['en']}');
    }

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_round < _totalRounds) {
        setState(() {
          _round++;
        });
        _startNewRound();
      } else {
        _showFinalScore();
      }
    });
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
                color: Colors.blue.shade700,
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
              backgroundColor: Colors.blue.shade600,
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
            colors: [Colors.blue.shade50, Colors.cyan.shade50],
          ),
        ),
        child: SafeArea(
          child: _currentShape == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildHeader(responsive),
                    SizedBox(height: responsive.spacing(12)),
                    _buildTask(responsive),
                    SizedBox(height: responsive.spacing(16)),
                    Expanded(child: _buildShape(responsive)),
                    SizedBox(height: responsive.spacing(16)),
                    _buildAnswers(responsive),
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
            color: Colors.blue.shade600,
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
        color: Colors.blue.shade100,
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
                  color: Colors.blue.shade800,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: responsive.fontSize(10),
                  color: Colors.blue.shade700,
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
        border: Border.all(color: Colors.blue.shade300, width: 2),
      ),
      child: Text(
        _isHebrew ? 'איזו צורה זאת?' : 'What shape is this?',
        style: TextStyle(
          fontSize: responsive.fontSize(20),
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildShape(ResponsiveHelper responsive) {
    return Expanded(
      child: Center(
        child: CustomPaint(
          size: const Size(180, 180),
          painter: ShapePainter(
            shape: _currentShape!,
            color: Colors.blue.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildAnswers(ResponsiveHelper responsive) {
    final options = _generateOptions();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 3.5,
        children: options.map((option) {
          final isSelected = _selectedAnswer == option;
          final correctAnswer = _shapes[_currentShape]![_isHebrew ? 'he' : 'en']!;
          final isCorrectOption = option == correctAnswer;
          final showResult = _isCorrect != null;

          return GestureDetector(
            onTap: _isCorrect == null ? () => _checkAnswer(option) : null,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade300, Colors.blue.shade500],
                ),
                borderRadius: BorderRadius.circular(12),
                border: showResult && isCorrectOption
                    ? Border.all(color: Colors.green.shade700, width: 3)
                    : null,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(
                        option,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Opacity(
                      opacity: (showResult && isSelected) ? 1.0 : 0.0,
                      child: Icon(
                        (showResult && isSelected && _isCorrect!) ? Icons.check_circle : Icons.cancel,
                        color: (showResult && isSelected && _isCorrect!) ? Colors.green.shade700 : Colors.red.shade700,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<String> _generateOptions() {
    final correctAnswer = _shapes[_currentShape]![_isHebrew ? 'he' : 'en']!;
    final options = <String>{correctAnswer};

    final allShapes = _shapes.values
        .map((shape) => shape[_isHebrew ? 'he' : 'en']!)
        .toList()
      ..shuffle();

    for (final shape in allShapes) {
      if (options.length >= 4) break;
      options.add(shape);
    }

    final list = options.toList()..shuffle();
    return list;
  }
}

/// Custom painter for drawing shapes
class ShapePainter extends CustomPainter {
  final String shape;
  final Color color;

  ShapePainter({required this.shape, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    switch (shape) {
      case 'circle':
        canvas.drawCircle(center, radius, paint);
        canvas.drawCircle(center, radius, strokePaint);
        break;

      case 'square':
        final rect = Rect.fromCenter(
          center: center,
          width: radius * 1.4,
          height: radius * 1.4,
        );
        canvas.drawRect(rect, paint);
        canvas.drawRect(rect, strokePaint);
        break;

      case 'triangle':
        _drawPolygon(canvas, center, radius, 3, paint, strokePaint);
        break;

      case 'rectangle':
        final rect = Rect.fromCenter(
          center: center,
          width: radius * 1.8,
          height: radius * 1.2,
        );
        canvas.drawRect(rect, paint);
        canvas.drawRect(rect, strokePaint);
        break;

      case 'pentagon':
        _drawPolygon(canvas, center, radius, 5, paint, strokePaint);
        break;

      case 'hexagon':
        _drawPolygon(canvas, center, radius, 6, paint, strokePaint);
        break;
    }
  }

  void _drawPolygon(Canvas canvas, Offset center, double radius, int sides,
      Paint fillPaint, Paint strokePaint) {
    final path = Path();
    final angle = (2 * pi) / sides;
    final startAngle = -pi / 2;

    for (int i = 0; i <= sides; i++) {
      final x = center.dx + radius * cos(startAngle + angle * i);
      final y = center.dy + radius * sin(startAngle + angle * i);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(ShapePainter oldDelegate) {
    return oldDelegate.shape != shape || oldDelegate.color != color;
  }
}
