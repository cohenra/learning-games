import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// לוח כפל אינטראקטיבי - גרסה מינימלית לבדיקה
class MultiplicationTableScreen extends StatefulWidget {
  const MultiplicationTableScreen({super.key});

  @override
  State<MultiplicationTableScreen> createState() =>
      _MultiplicationTableScreenState();
}

class _MultiplicationTableScreenState extends State<MultiplicationTableScreen> {
  int _maxNumber = 5;
  Set<String> _completedCells = {}; // Track completed cells (e.g., "2-3")

  @override
  void initState() {
    super.initState();
    // Hide system UI (navigation bar)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore system UI when leaving
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('לוח כפל'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        color: Colors.blue.shade50,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Difficulty buttons on the left
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDifficultyButton('1-5', 5),
                    const SizedBox(height: 12),
                    _buildDifficultyButton('1-10', 10),
                    const SizedBox(height: 12),
                    _buildDifficultyButton('1-12', 12),
                  ],
                ),
                const SizedBox(width: 16),
                // Table on the right
                Expanded(
                  child: Center(
                    child: _buildTable(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(String label, int maxNum) {
    final isSelected = _maxNumber == maxNum;
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _maxNumber = maxNum;
            _completedCells.clear(); // Reset progress when changing difficulty
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.blue,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    // Calculate cell size based on available space
    final size = MediaQuery.of(context).size;
    final availableWidth = size.width - 160; // margins + buttons
    final availableHeight = size.height - 150; // app bar + padding

    final totalCells = _maxNumber + 1; // +1 for header column

    // Calculate max cell size that fits both width and height
    double cellSizeFromWidth = availableWidth / totalCells;
    double cellSizeFromHeight = availableHeight / totalCells;
    double cellSize = (cellSizeFromWidth < cellSizeFromHeight
        ? cellSizeFromWidth
        : cellSizeFromHeight).clamp(25.0, 45.0);

    // Adjust font size based on cell size
    double fontSize = (cellSize * 0.35).clamp(10.0, 16.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCell('✖️', cellSize, fontSize, isHeader: true),
            for (int col = 1; col <= _maxNumber; col++)
              _buildCell('$col', cellSize, fontSize, isHeader: true),
          ],
        ),
        // Data rows
        for (int row = 1; row <= _maxNumber; row++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCell('$row', cellSize, fontSize, isHeader: true),
              for (int col = 1; col <= _maxNumber; col++)
                _buildCell('${row * col}', cellSize, fontSize, row: row, col: col),
            ],
          ),
      ],
    );
  }

  Widget _buildCell(String text, double size, double fontSize, {bool isHeader = false, int? row, int? col}) {
    final cellKey = row != null && col != null ? '$row-$col' : null;
    final isCompleted = cellKey != null && _completedCells.contains(cellKey);
    final isClickable = !isHeader && row != null && col != null;

    return GestureDetector(
      onTap: isClickable ? () => _onCellTap(row!, col!) : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isCompleted
              ? Colors.green.shade100
              : (isHeader ? Colors.blue.shade100 : Colors.white),
          border: Border.all(
            color: isCompleted ? Colors.green.shade300 : Colors.grey.shade300,
            width: isCompleted ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted ? Colors.green.shade700 : Colors.black87,
                ),
              ),
            ),
            if (isCompleted)
              Positioned(
                top: 2,
                right: 2,
                child: Icon(
                  Icons.check_circle,
                  size: size * 0.25,
                  color: Colors.green.shade700,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onCellTap(int row, int col) {
    final correctAnswer = row * col;
    final options = _generateOptions(correctAnswer);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildQuestionDialog(row, col, correctAnswer, options),
    );
  }

  List<int> _generateOptions(int correctAnswer) {
    final options = <int>{correctAnswer};

    // Generate 3 wrong answers
    while (options.length < 4) {
      int wrongAnswer;
      final random = (correctAnswer * 0.4).toInt() + 1;

      if (options.length == 1) {
        wrongAnswer = correctAnswer + random;
      } else if (options.length == 2) {
        wrongAnswer = correctAnswer - random;
      } else {
        wrongAnswer = correctAnswer + (random * 2);
      }

      if (wrongAnswer > 0 && wrongAnswer <= 144) {
        options.add(wrongAnswer);
      }
    }

    final list = options.toList()..shuffle();
    return list;
  }

  Widget _buildQuestionDialog(int row, int col, int correctAnswer, List<int> options) {
    int? selectedAnswer;
    bool? isCorrect;

    return StatefulBuilder(
      builder: (context, setDialogState) {
        final screenSize = MediaQuery.of(context).size;
        final dialogWidth = screenSize.width * 0.85;
        final dialogHeight = screenSize.height * 0.6;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: dialogWidth,
            height: dialogHeight,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Question
                Text(
                  '$row ✖️ $col = ?',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 24),

                // Answer options
                Expanded(
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.8,
                    children: options.map((option) {
                      final isSelected = selectedAnswer == option;
                      Color? bgColor;

                      if (isSelected && isCorrect != null) {
                        bgColor = isCorrect! ? Colors.green : Colors.red;
                      }

                      return ElevatedButton(
                        onPressed: selectedAnswer == null
                            ? () {
                                setDialogState(() {
                                  selectedAnswer = option;
                                  isCorrect = option == correctAnswer;
                                });

                                if (isCorrect!) {
                                  setState(() {
                                    _completedCells.add('$row-$col');
                                  });

                                  Future.delayed(const Duration(milliseconds: 800), () {
                                    if (mounted) {
                                      Navigator.pop(context);
                                    }
                                  });
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bgColor ?? Colors.blue.shade50,
                          foregroundColor: isSelected && isCorrect != null
                              ? Colors.white
                              : Colors.blue.shade700,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: bgColor ?? Colors.blue.shade300,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Text(
                          '$option',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                if (isCorrect != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    isCorrect! ? '🎉 מצוין!' : '❌ נסה שוב',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isCorrect! ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
