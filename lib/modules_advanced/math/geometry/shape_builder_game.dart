import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/kid_button.dart';
import '../../../widgets/kid_back_button.dart';

/// משחק בונה צורות - בנה צורות לפי מספר צלעות/קודקודים
class ShapeBuilderGame extends StatefulWidget {
  const ShapeBuilderGame({super.key});

  @override
  State<ShapeBuilderGame> createState() => _ShapeBuilderGameState();
}

class _ShapeBuilderGameState extends State<ShapeBuilderGame> {
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();
  bool _isHebrew = true;

  int? _targetSides;
  String? _selectedShape;
  bool? _isCorrect;
  int _score = 0;
  int _round = 1;
  final int _totalRounds = 8;

  final Map<int, Map<String, String>> _shapesBySides = {
    3: {'shape': 'triangle', 'he': 'משולש', 'en': 'Triangle'},
    4: {'shape': 'square', 'he': 'ריבוע/מלבן', 'en': 'Square/Rectangle'},
    5: {'shape': 'pentagon', 'he': 'מחומש', 'en': 'Pentagon'},
    6: {'shape': 'hexagon', 'he': 'משושה', 'en': 'Hexagon'},
  };

  final List<Map<String, dynamic>> _allShapes = [
    {'shape': 'circle', 'sides': 0, 'he': 'עיגול', 'en': 'Circle'},
    {'shape': 'triangle', 'sides': 3, 'he': 'משולש', 'en': 'Triangle'},
    {'shape': 'square', 'sides': 4, 'he': 'ריבוע', 'en': 'Square'},
    {'shape': 'rectangle', 'sides': 4, 'he': 'מלבן', 'en': 'Rectangle'},
    {'shape': 'pentagon', 'sides': 5, 'he': 'מחומש', 'en': 'Pentagon'},
    {'shape': 'hexagon', 'sides': 6, 'he': 'משושה', 'en': 'Hexagon'},
  ];

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
    final sides = [3, 4, 5, 6][_random.nextInt(4)];

    setState(() {
      _targetSides = sides;
      _selectedShape = null;
      _isCorrect = null;
    });

    // Speak the task
    _speak(_isHebrew
        ? 'בחר צורה עם $_targetSides צלעות'
        : 'Choose a shape with $_targetSides sides');
  }

  void _checkAnswer(String shape) {
    final shapeData = _allShapes.firstWhere((s) => s['shape'] == shape);
    final isCorrect = shapeData['sides'] == _targetSides;

    setState(() {
      _selectedShape = shape;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      _speak(_isHebrew ? 'מצוין! ${shapeData['he']} יש $_targetSides צלעות' : 'Great! ${shapeData['en']} has $_targetSides sides');
      setState(() {
        _score++;
      });
    } else {
      final correctShape = _shapesBySides[_targetSides]!;
      _speak(_isHebrew ? 'לא נכון. ${correctShape['he']} יש $_targetSides צלעות' : 'Incorrect. ${correctShape['en']} has $_targetSides sides');
    }

    Future.delayed(const Duration(milliseconds: 2000), () {
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
                color: Colors.green.shade700,
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
              backgroundColor: Colors.green.shade600,
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
            colors: [Colors.green.shade50, Colors.teal.shade50],
          ),
        ),
        child: SafeArea(
          child: _targetSides == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildHeader(responsive),
                    SizedBox(height: responsive.spacing(10)),
                    _buildTask(responsive),
                    SizedBox(height: responsive.spacing(16)),
                    Expanded(
                      child: Center(
                        child: _buildShapeOptions(responsive),
                      ),
                    ),
                    SizedBox(height: responsive.spacing(8)),
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
            color: Colors.green.shade600,
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
        color: Colors.green.shade100,
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
                  color: Colors.green.shade800,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: responsive.fontSize(10),
                  color: Colors.green.shade700,
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
        border: Border.all(color: Colors.green.shade300, width: 2),
      ),
      child: Column(
        children: [
          Text(
            _isHebrew ? 'בחר צורה עם:' : 'Choose a shape with:',
            style: TextStyle(
              fontSize: responsive.fontSize(18),
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.spacing(6)),
          Text(
            '$_targetSides ${_isHebrew ? 'צלעות' : 'sides'}',
            style: TextStyle(
              fontSize: responsive.fontSize(32),
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShapeOptions(ResponsiveHelper responsive) {
    final options = _generateShapeOptions();
    final correctShapes = _allShapes.where((s) => s['sides'] == _targetSides).map((s) => s['shape']).toSet();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 400),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.4,
        children: options.map((shapeData) {
        final shape = shapeData['shape'] as String;
        final isSelected = _selectedShape == shape;
        final isCorrectOption = correctShapes.contains(shape);
        final showResult = _isCorrect != null;

        return GestureDetector(
          onTap: _isCorrect == null ? () => _checkAnswer(shape) : null,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: showResult && isCorrectOption
                    ? Colors.green.shade600
                    : Colors.green.shade300,
                width: showResult && isCorrectOption ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 3,
                      child: Center(
                        child: CustomPaint(
                          size: const Size(65, 65),
                          painter: ShapeOptionPainter(
                            shape: shape,
                            color: Colors.green.shade400,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          shapeData[_isHebrew ? 'he' : 'en'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                if (showResult && isSelected)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Icon(
                      _isCorrect! ? Icons.check_circle : Icons.cancel,
                      color: _isCorrect! ? Colors.green.shade700 : Colors.red.shade700,
                      size: 28,
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

  List<Map<String, dynamic>> _generateShapeOptions() {
    final options = <Map<String, dynamic>>[];

    // Add correct answer
    final correctShapes = _allShapes.where((s) => s['sides'] == _targetSides).toList();
    options.add(correctShapes[_random.nextInt(correctShapes.length)]);

    // Add wrong answers
    final wrongShapes = _allShapes.where((s) => s['sides'] != _targetSides).toList()..shuffle();

    for (final shape in wrongShapes) {
      if (options.length >= 4) break;
      options.add(shape);
    }

    return options..shuffle();
  }
}

/// Custom painter for shape options
class ShapeOptionPainter extends CustomPainter {
  final String shape;
  final Color color;

  ShapeOptionPainter({required this.shape, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 15;

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
          width: radius * 1.6,
          height: radius * 1.0,
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
  bool shouldRepaint(ShapeOptionPainter oldDelegate) {
    return oldDelegate.shape != shape || oldDelegate.color != color;
  }
}
