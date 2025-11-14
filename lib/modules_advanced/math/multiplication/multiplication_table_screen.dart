import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('לוח כפל'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        color: Colors.blue.shade50,
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'לוח הכפל',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _maxNumber = 5;
                    });
                  },
                  child: const Text('1-5'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _maxNumber = 10;
                    });
                  },
                  child: const Text('1-10'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _maxNumber = 12;
                    });
                  },
                  child: const Text('1-12'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: _buildTable(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    // Calculate cell size based on screen width and number of cells
    final screenWidth = MediaQuery.of(context).size.width;
    final totalCells = _maxNumber + 1; // +1 for header column
    final availableWidth = screenWidth - 40; // margins
    double cellSize = (availableWidth / totalCells).clamp(30.0, 50.0);

    // Adjust font size based on cell size
    double fontSize = cellSize * 0.32;

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
