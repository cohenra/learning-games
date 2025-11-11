import 'package:flutter/material.dart';
import '../models/simple_maze.dart';

/// ציור המבוך עם קירות עבים
class MazePainter extends CustomPainter {
  final SimpleMaze maze;
  final int playerRow;
  final int playerCol;
  final double cellSize;

  MazePainter({
    required this.maze,
    required this.playerRow,
    required this.playerCol,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final wallPaint = Paint()
      ..color = const Color(0xFF2C3E50) // כחול כהה לקירות
      ..style = PaintingStyle.fill;

    final pathPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final questionPaint = Paint()
      ..color = const Color(0xFFFFF9C4) // צהוב בהיר לשאלות
      ..style = PaintingStyle.fill;

    final startPaint = Paint()
      ..color = const Color(0xFFC8E6C9) // ירוק בהיר להתחלה
      ..style = PaintingStyle.fill;

    final endPaint = Paint()
      ..color = const Color(0xFFFFCDD2) // אדום בהיר לסיום
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // צייר כל תא
    for (int row = 0; row < maze.grid.length; row++) {
      for (int col = 0; col < maze.grid[row].length; col++) {
        final rect = Rect.fromLTWH(
          col * cellSize,
          row * cellSize,
          cellSize,
          cellSize,
        );

        final cell = maze.grid[row][col];

        // בחר צבע לפי סוג התא
        Paint paint;
        if (cell == '1') {
          paint = wallPaint;
        } else if (cell == 'S') {
          paint = startPaint;
        } else if (cell == 'E') {
          paint = endPaint;
        } else if (cell == 'Q') {
          final junction = maze.getJunction(row, col);
          if (junction != null && !junction.isUnlocked) {
            paint = questionPaint;
          } else {
            paint = pathPaint;
          }
        } else {
          paint = pathPaint;
        }

        canvas.drawRect(rect, paint);

        // צייר קווי grid דקים
        if (cell != '1') {
          canvas.drawRect(rect, gridPaint);
        }
      }
    }

    // צייר קווי קיר עבים
    _drawThickWalls(canvas);

    // צייר את השחקן
    _drawPlayer(canvas);

    // צייר אייקונים
    _drawIcons(canvas);
  }

  void _drawThickWalls(Canvas canvas) {
    final wallBorderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (int row = 0; row < maze.grid.length; row++) {
      for (int col = 0; col < maze.grid[row].length; col++) {
        if (maze.grid[row][col] != '1') continue;

        final x = col * cellSize;
        final y = row * cellSize;

        // בדוק גבולות עם דרכים
        // למעלה
        if (row > 0 && maze.grid[row - 1][col] != '1') {
          canvas.drawLine(
            Offset(x, y),
            Offset(x + cellSize, y),
            wallBorderPaint,
          );
        }
        // למטה
        if (row < maze.grid.length - 1 && maze.grid[row + 1][col] != '1') {
          canvas.drawLine(
            Offset(x, y + cellSize),
            Offset(x + cellSize, y + cellSize),
            wallBorderPaint,
          );
        }
        // שמאל
        if (col > 0 && maze.grid[row][col - 1] != '1') {
          canvas.drawLine(
            Offset(x, y),
            Offset(x, y + cellSize),
            wallBorderPaint,
          );
        }
        // ימין
        if (col < maze.grid[row].length - 1 &&
            maze.grid[row][col + 1] != '1') {
          canvas.drawLine(
            Offset(x + cellSize, y),
            Offset(x + cellSize, y + cellSize),
            wallBorderPaint,
          );
        }
      }
    }
  }

  void _drawPlayer(Canvas canvas) {
    final playerPaint = Paint()
      ..color = const Color(0xFF2196F3) // כחול לשחקן
      ..style = PaintingStyle.fill;

    final playerShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final centerX = (playerCol + 0.5) * cellSize;
    final centerY = (playerRow + 0.5) * cellSize;
    final radius = cellSize * 0.35;

    // צל
    canvas.drawCircle(
      Offset(centerX + 2, centerY + 2),
      radius,
      playerShadowPaint,
    );

    // גוף
    canvas.drawCircle(
      Offset(centerX, centerY),
      radius,
      playerPaint,
    );

    // עיניים
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(centerX - radius * 0.3, centerY - radius * 0.2),
      radius * 0.2,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(centerX + radius * 0.3, centerY - radius * 0.2),
      radius * 0.2,
      eyePaint,
    );

    // אישונים
    final pupilPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(centerX - radius * 0.3, centerY - radius * 0.2),
      radius * 0.1,
      pupilPaint,
    );
    canvas.drawCircle(
      Offset(centerX + radius * 0.3, centerY - radius * 0.2),
      radius * 0.1,
      pupilPaint,
    );

    // פה
    final smilePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final smilePath = Path()
      ..moveTo(centerX - radius * 0.3, centerY + radius * 0.2)
      ..quadraticBezierTo(
        centerX,
        centerY + radius * 0.4,
        centerX + radius * 0.3,
        centerY + radius * 0.2,
      );

    canvas.drawPath(smilePath, smilePaint);
  }

  void _drawIcons(Canvas canvas) {
    // אייקון התחלה
    final startIcon = TextPainter(
      text: const TextSpan(
        text: '🏁',
        style: TextStyle(fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    startIcon.paint(
      canvas,
      Offset(
        maze.startCol * cellSize + (cellSize - startIcon.width) / 2,
        maze.startRow * cellSize + (cellSize - startIcon.height) / 2,
      ),
    );

    // אייקון סיום
    final endIcon = TextPainter(
      text: const TextSpan(
        text: '🏆',
        style: TextStyle(fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    endIcon.paint(
      canvas,
      Offset(
        maze.endCol * cellSize + (cellSize - endIcon.width) / 2,
        maze.endRow * cellSize + (cellSize - endIcon.height) / 2,
      ),
    );

    // אייקוני שאלות
    for (final junction in maze.junctions) {
      if (!junction.isUnlocked) {
        final questionIcon = TextPainter(
          text: const TextSpan(
            text: '❓',
            style: TextStyle(fontSize: 20),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        questionIcon.paint(
          canvas,
          Offset(
            junction.col * cellSize + (cellSize - questionIcon.width) / 2,
            junction.row * cellSize + (cellSize - questionIcon.height) / 2,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(MazePainter oldDelegate) {
    return oldDelegate.playerRow != playerRow ||
        oldDelegate.playerCol != playerCol ||
        oldDelegate.maze != maze;
  }
}
