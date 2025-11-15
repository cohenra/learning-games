import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/kid_button.dart';
import '../../../widgets/kid_back_button.dart';

/// משחק שברי שוקולד - למד לזהות ולייצר שברים
class ChocolateFractionsGame extends StatefulWidget {
  const ChocolateFractionsGame({super.key});

  @override
  State<ChocolateFractionsGame> createState() => _ChocolateFractionsGameState();
}

class _ChocolateFractionsGameState extends State<ChocolateFractionsGame> {
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();
  bool _isHebrew = true;

  int? _denominator; // מכנה - total parts
  int? _numerator; // מונה - colored parts
  int _selectedSquares = 0;
  bool _showQuestion = false;
  String? _selectedAnswer;
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
    // Generate fraction
    final denominators = [2, 3, 4, 5, 6];
    final denominator = denominators[_random.nextInt(denominators.length)];
    final numerator = _random.nextInt(denominator - 1) + 1; // 1 to (denominator-1)

    setState(() {
      _denominator = denominator;
      _numerator = numerator;
      _selectedSquares = 0;
      _showQuestion = false;
      _selectedAnswer = null;
      _isCorrect = null;
    });

    // Speak the task
    _speak(_isHebrew
        ? 'סמן $_numerator מתוך $_denominator ריבועים. זה השבר $_numerator/$_denominator'
        : 'Mark $_numerator out of $_denominator squares. That is the fraction $_numerator/$_denominator');
  }

  void _toggleSquare(int index) {
    setState(() {
      if (index < _selectedSquares) {
        // Deselect: remove all from this index onward
        _selectedSquares = index;
      } else if (index == _selectedSquares) {
        // Select this square
        _selectedSquares++;
      }
    });
  }

  void _reset() {
    setState(() {
      _selectedSquares = 0;
    });
  }

  void _checkSelection() {
    if (_selectedSquares == _numerator) {
      _showQuestionDialog();
    } else if (_selectedSquares < _numerator!) {
      _showSnackBar(
        _isHebrew
            ? 'צריך עוד ריבועים! המטרה: $_numerator/$_denominator'
            : 'Need more squares! Target: $_numerator/$_denominator',
        Colors.orange,
      );
    } else {
      _showSnackBar(
        _isHebrew
            ? 'יותר מדי ריבועים! המטרה: $_numerator/$_denominator'
            : 'Too many squares! Target: $_numerator/$_denominator',
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
    final correctAnswer = '$_numerator/$_denominator';
    final options = _generateOptions(_numerator!, _denominator!);

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
                  colors: [Colors.brown.shade50, Colors.orange.shade50],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Question
                  Text(
                    _isHebrew
                        ? 'איזה שבר סימנת?'
                        : 'Which fraction did you mark?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade700,
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
                                  _isCorrect = option == correctAnswer;
                                });

                                if (_isCorrect!) {
                                  _speak(_isHebrew ? 'מצוין!' : 'Excellent!');
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
                                option,
                                style: const TextStyle(
                                  fontSize: 28,
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

  List<String> _generateOptions(int num, int denom) {
    final options = <String>{'$num/$denom'};

    // Generate wrong options
    while (options.length < 4) {
      int wrongNum, wrongDenom;

      if (_random.nextBool()) {
        // Wrong numerator, same denominator
        wrongNum = _random.nextInt(denom - 1) + 1;
        wrongDenom = denom;
      } else {
        // Different fraction altogether
        wrongDenom = [2, 3, 4, 5, 6][_random.nextInt(5)];
        wrongNum = _random.nextInt(wrongDenom - 1) + 1;
      }

      if (wrongNum != num || wrongDenom != denom) {
        options.add('$wrongNum/$wrongDenom');
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
                color: Colors.brown.shade700,
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
              backgroundColor: Colors.brown.shade600,
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
            colors: [Colors.brown.shade50, Colors.orange.shade50],
          ),
        ),
        child: SafeArea(
          child: _denominator == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildHeader(responsive),
                    SizedBox(height: responsive.spacing(12)),
                    _buildTask(responsive),
                    SizedBox(height: responsive.spacing(12)),
                    Expanded(child: _buildChocolateBar(responsive)),
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
            color: Colors.brown.shade600,
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
        color: Colors.brown.shade100,
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
                  color: Colors.brown.shade800,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: responsive.fontSize(10),
                  color: Colors.brown.shade700,
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
        border: Border.all(color: Colors.brown.shade300, width: 2),
      ),
      child: Column(
        children: [
          Text(
            _isHebrew
                ? 'סמן את השבר:'
                : 'Mark the fraction:',
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.spacing(6)),
          Text(
            '$_numerator/$_denominator',
            style: TextStyle(
              fontSize: responsive.fontSize(36),
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.spacing(4)),
          Text(
            _isHebrew
                ? '$_numerator מתוך $_denominator'
                : '$_numerator out of $_denominator',
            style: TextStyle(
              fontSize: responsive.fontSize(14),
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChocolateBar(ResponsiveHelper responsive) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(responsive.spacing(16)),
        child: _buildGrid(responsive),
      ),
    );
  }

  Widget _buildGrid(ResponsiveHelper responsive) {
    // Determine grid layout based on denominator
    int cols, rows;
    if (_denominator == 2) {
      cols = 2;
      rows = 1;
    } else if (_denominator == 3) {
      cols = 3;
      rows = 1;
    } else if (_denominator == 4) {
      cols = 2;
      rows = 2;
    } else if (_denominator == 5) {
      cols = 5;
      rows = 1;
    } else { // 6
      cols = 3;
      rows = 2;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1.0,
      ),
      itemCount: _denominator,
      itemBuilder: (context, index) {
        final isSelected = index < _selectedSquares;
        return GestureDetector(
          onTap: () => _toggleSquare(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? Colors.brown.shade400 : Colors.brown.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.brown.shade600,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                isSelected ? '🍫' : '',
                style: TextStyle(fontSize: responsive.iconSize(32)),
              ),
            ),
          ),
        );
      },
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
                  text: _isHebrew ? 'אפס 🔄' : 'Reset 🔄',
                  icon: Icons.refresh,
                  onPressed: _reset,
                  color: Colors.orange.shade600,
                  height: 60,
                ),
              ),
              SizedBox(width: responsive.spacing(12)),
              Expanded(
                child: KidButton(
                  text: _isHebrew ? 'בדוק ✓' : 'Check ✓',
                  icon: Icons.check_circle,
                  onPressed: _checkSelection,
                  color: Colors.green.shade600,
                  height: 60,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
