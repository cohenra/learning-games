import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/kid_button.dart';
import '../../../widgets/kid_back_button.dart';
import '../../../widgets/reward_animation.dart';

/// לוח כפל אינטראקטיבי - לחיצה על תא מציגה שאלה
class MultiplicationTableScreen extends StatefulWidget {
  const MultiplicationTableScreen({super.key});

  @override
  State<MultiplicationTableScreen> createState() =>
      _MultiplicationTableScreenState();
}

class _MultiplicationTableScreenState extends State<MultiplicationTableScreen>
    with SingleTickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();

  bool _isHebrew = true;
  int _maxNumber = 5; // Start with 1-5, can increase to 10 or 12
  int? _selectedRow;
  int? _selectedCol;
  bool _showQuestion = false;
  List<int> _answerOptions = [];
  int? _selectedAnswer;
  bool? _isCorrect;
  Map<String, bool> _completedCells = {}; // Track completed cells

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initTts();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isHebrew = Localizations.localeOf(context).languageCode == 'he';
      });
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    final lang = _isHebrew ? 'he-IL' : 'en-US';
    await _flutterTts.setLanguage(lang);
    await _flutterTts.speak(text);
  }

  void _onCellTap(int row, int col) {
    final cellKey = '$row-$col';

    setState(() {
      _selectedRow = row;
      _selectedCol = col;
      _showQuestion = true;
      _selectedAnswer = null;
      _isCorrect = null;
    });

    _generateAnswerOptions(row, col);
    _animationController.forward(from: 0);

    // Speak the question
    _speak(_isHebrew
        ? 'כמה זה $row כפול $col?'
        : 'What is $row times $col?');
  }

  void _generateAnswerOptions(int row, int col) {
    final correctAnswer = row * col;
    final options = <int>{correctAnswer};

    // Generate 3 wrong answers
    while (options.length < 4) {
      final randomOffset = (correctAnswer * 0.5).toInt() + 1;
      final wrongAnswer = correctAnswer + (options.length - 2) * randomOffset;
      if (wrongAnswer > 0 && wrongAnswer != correctAnswer) {
        options.add(wrongAnswer);
      }
    }

    setState(() {
      _answerOptions = options.toList()..shuffle();
    });
  }

  void _checkAnswer(int answer) {
    final correctAnswer = _selectedRow! * _selectedCol!;
    final isCorrect = answer == correctAnswer;

    setState(() {
      _selectedAnswer = answer;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      _speak(_isHebrew ? 'כל הכבוד! נכון!' : 'Great! Correct!');
      final cellKey = '$_selectedRow-$_selectedCol';
      setState(() {
        _completedCells[cellKey] = true;
      });

      // Close question after 1.5 seconds
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _showQuestion = false;
            _selectedRow = null;
            _selectedCol = null;
          });
        }
      });
    } else {
      _speak(_isHebrew ? 'נסה שוב' : 'Try again');
    }
  }

  void _changeDifficulty(int max) {
    setState(() {
      _maxNumber = max;
      _completedCells.clear();
      _showQuestion = false;
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
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
            colors: [Colors.blue.shade50, Colors.purple.shade50],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.all(responsive.spacing(12)),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Text(
                                _isHebrew
                                    ? 'לוח הכפל האינטראקטיבי'
                                    : 'Interactive Multiplication Table',
                                style: TextStyle(
                                  fontSize: responsive.fontSize(20),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: responsive.spacing(8)),
                              Text(
                                _isHebrew
                                    ? 'לחץ על תא כדי לתרגל'
                                    : 'Tap a cell to practice',
                                style: TextStyle(
                                  fontSize: responsive.fontSize(14),
                                  color: Colors.grey.shade600,
                                ),
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
                            color: Colors.blue.shade600,
                            isHebrew: _isHebrew,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Difficulty selector
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.spacing(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDifficultyButton(5, '1-5', Colors.green, responsive),
                        SizedBox(width: responsive.spacing(8)),
                        _buildDifficultyButton(10, '1-10', Colors.orange, responsive),
                        SizedBox(width: responsive.spacing(8)),
                        _buildDifficultyButton(12, '1-12', Colors.red, responsive),
                      ],
                    ),
                  ),

                  SizedBox(height: responsive.spacing(16)),

                  // Multiplication Table
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: _buildMultiplicationTable(responsive),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: responsive.spacing(16)),
                ],
              ),

              // Question Overlay
              if (_showQuestion)
                _buildQuestionOverlay(responsive),

              // Reward animation
              if (_isCorrect == true)
                const RewardAnimation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(
    int max,
    String label,
    Color color,
    ResponsiveHelper responsive,
  ) {
    final isSelected = _maxNumber == max;
    return InkWell(
      onTap: () => _changeDifficulty(max),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.spacing(16),
          vertical: responsive.spacing(8),
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: responsive.fontSize(16),
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  Widget _buildMultiplicationTable(ResponsiveHelper responsive) {
    return Container(
      margin: EdgeInsets.all(responsive.spacing(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row (x)
          Row(
            children: [
              _buildHeaderCell('✖️', responsive, isCorner: true),
              for (int col = 1; col <= _maxNumber; col++)
                _buildHeaderCell('$col', responsive),
            ],
          ),
          // Data rows
          for (int row = 1; row <= _maxNumber; row++)
            Row(
              children: [
                _buildHeaderCell('$row', responsive),
                for (int col = 1; col <= _maxNumber; col++)
                  _buildTableCell(row, col, responsive),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, ResponsiveHelper responsive,
      {bool isCorner = false}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isCorner ? Colors.purple.shade100 : Colors.blue.shade100,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: responsive.fontSize(16),
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(int row, int col, ResponsiveHelper responsive) {
    final cellKey = '$row-$col';
    final isCompleted = _completedCells[cellKey] == true;
    final product = row * col;

    return InkWell(
      onTap: () => _onCellTap(row, col),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isCompleted
              ? Colors.green.shade100
              : Colors.white,
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '$product',
                style: TextStyle(
                  fontSize: responsive.fontSize(14),
                  fontWeight: FontWeight.bold,
                  color: isCompleted
                      ? Colors.green.shade700
                      : Colors.grey.shade600,
                ),
              ),
            ),
            if (isCompleted)
              Positioned(
                top: 2,
                right: 2,
                child: Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.green.shade700,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionOverlay(ResponsiveHelper responsive) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: ScaleTransition(
          scale: _animationController,
          child: Container(
            margin: EdgeInsets.all(responsive.spacing(20)),
            padding: EdgeInsets.all(responsive.spacing(24)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Question
                Text(
                  '$_selectedRow ✖️ $_selectedCol = ?',
                  style: TextStyle(
                    fontSize: responsive.fontSize(36),
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),

                SizedBox(height: responsive.spacing(32)),

                // Answer options (2x2 grid)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: _answerOptions.length,
                  itemBuilder: (context, index) {
                    final option = _answerOptions[index];
                    final isSelected = _selectedAnswer == option;
                    final correctAnswer = _selectedRow! * _selectedCol!;

                    Color? bgColor;
                    if (isSelected) {
                      bgColor = _isCorrect! ? Colors.green : Colors.red;
                    }

                    return InkWell(
                      onTap: _isCorrect == null
                          ? () => _checkAnswer(option)
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: bgColor ?? Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: bgColor ?? Colors.blue.shade300,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$option',
                            style: TextStyle(
                              fontSize: responsive.fontSize(32),
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                if (_isCorrect != null) ...[
                  SizedBox(height: responsive.spacing(20)),
                  Text(
                    _isCorrect!
                        ? (_isHebrew ? '🎉 מצוין!' : '🎉 Excellent!')
                        : (_isHebrew ? '❌ נסה שוב' : '❌ Try again'),
                    style: TextStyle(
                      fontSize: responsive.fontSize(24),
                      fontWeight: FontWeight.bold,
                      color: _isCorrect! ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
