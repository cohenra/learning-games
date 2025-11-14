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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: _buildTable(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
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
              _buildCell('✖️', isHeader: true),
              for (int col = 1; col <= _maxNumber; col++)
                _buildCell('$col', isHeader: true),
            ],
          ),
          // Data rows
          for (int row = 1; row <= _maxNumber; row++)
            Row(
              children: [
                _buildCell('$row', isHeader: true),
                for (int col = 1; col <= _maxNumber; col++)
                  _buildCell('${row * col}'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCell(String text, {bool isHeader = false}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isHeader ? Colors.blue.shade100 : Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
