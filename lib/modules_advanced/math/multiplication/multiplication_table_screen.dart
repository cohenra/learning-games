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
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.blue,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.blue, width: 2),
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

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Row(
            children: [
              _buildCell('✖️', cellSize, fontSize, isHeader: true),
              for (int col = 1; col <= _maxNumber; col++)
                _buildCell('$col', cellSize, fontSize, isHeader: true),
            ],
          ),
          // Data rows
          for (int row = 1; row <= _maxNumber; row++)
            Row(
              children: [
                _buildCell('$row', cellSize, fontSize, isHeader: true),
                for (int col = 1; col <= _maxNumber; col++)
                  _buildCell('${row * col}', cellSize, fontSize),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCell(String text, double size, double fontSize, {bool isHeader = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isHeader ? Colors.blue.shade100 : Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
