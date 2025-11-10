import 'dart:math';
import 'maze_cell.dart';
import 'maze_junction.dart';
import 'maze_question.dart';

/// Grid של המבוך
class MazeGrid {
  final int rows;
  final int cols;
  late List<List<MazeCell>> grid;
  late Position startPosition;
  late Position goalPosition;
  final Map<Position, MazeJunction> junctions = {};

  MazeGrid({
    required this.rows,
    required this.cols,
  }) {
    _initializeGrid();
  }

  /// אתחול Grid עם קירות
  void _initializeGrid() {
    grid = List.generate(
      rows,
      (row) => List.generate(
        cols,
        (col) => MazeCell(
          position: Position(row, col),
          type: CellType.wall,
        ),
      ),
    );
  }

  /// קבל תא במיקום
  MazeCell? getCell(Position pos) {
    if (isValidPosition(pos)) {
      return grid[pos.row][pos.col];
    }
    return null;
  }

  /// קבע סוג תא
  void setCellType(Position pos, CellType type) {
    if (isValidPosition(pos)) {
      grid[pos.row][pos.col].type = type;
    }
  }

  /// בדוק אם מיקום תקף
  bool isValidPosition(Position pos) {
    return pos.row >= 0 && pos.row < rows && pos.col >= 0 && pos.col < cols;
  }

  /// בדוק אם אפשר ללכת למיקום
  bool isWalkable(Position pos) {
    final cell = getCell(pos);
    return cell != null && cell.isWalkable;
  }

  /// קבל שכנים הליכים
  List<Position> getWalkableNeighbors(Position pos) {
    final neighbors = <Position>[];
    for (final dir in Direction.values) {
      final newPos = pos.move(dir);
      if (isWalkable(newPos)) {
        neighbors.add(newPos);
      }
    }
    return neighbors;
  }

  /// הוסף צומת
  void addJunction(Position pos, Map<Direction, MazeQuestion> questions) {
    setCellType(pos, CellType.junction);
    junctions[pos] = MazeJunction(
      position: pos,
      directionQuestions: questions,
    );
  }

  /// קבל צומת
  MazeJunction? getJunction(Position pos) {
    return junctions[pos];
  }

  /// בדוק אם אפשר לזוז בכיוון מהמיקום הנוכחי
  bool canMove(Position from, Direction direction) {
    final to = from.move(direction);

    // בדוק אם היעד תקף והליך
    if (!isWalkable(to)) return false;

    // אם זה צומת, בדוק אם הכיוון פתוח
    final junction = getJunction(from);
    if (junction != null) {
      return junction.isDirectionUnlocked(direction);
    }

    return true;
  }

  /// הדפס את המבוך (לדיבוג)
  void printMaze() {
    for (int row = 0; row < rows; row++) {
      String line = '';
      for (int col = 0; col < cols; col++) {
        final cell = grid[row][col];
        switch (cell.type) {
          case CellType.wall:
            line += '🧱 ';
            break;
          case CellType.path:
            line += '   ';
            break;
          case CellType.junction:
            line += '📝 ';
            break;
          case CellType.start:
            line += '🏁 ';
            break;
          case CellType.goal:
            line += '🏆 ';
            break;
        }
      }
      print(line);
    }
  }
}
