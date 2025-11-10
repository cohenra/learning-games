/// תא בודד במבוך
enum CellType {
  wall,      // קיר 🧱
  path,      // דרך פתוחה
  junction,  // צומת עם שאלות 📝
  goal,      // יעד 🏆
  start,     // התחלה 🏁
}

/// כיוון תנועה
enum Direction {
  up,
  down,
  left,
  right,
}

/// מיקום במבוך
class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position && row == other.row && col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  /// קבל מיקום חדש לאחר תנועה בכיוון
  Position move(Direction direction) {
    switch (direction) {
      case Direction.up:
        return Position(row - 1, col);
      case Direction.down:
        return Position(row + 1, col);
      case Direction.left:
        return Position(row, col - 1);
      case Direction.right:
        return Position(row, col + 1);
    }
  }

  /// כיוון הפוך
  static Direction oppositeDirection(Direction dir) {
    switch (dir) {
      case Direction.up:
        return Direction.down;
      case Direction.down:
        return Direction.up;
      case Direction.left:
        return Direction.right;
      case Direction.right:
        return Direction.left;
    }
  }

  @override
  String toString() => 'Position($row, $col)';
}

/// תא במבוך
class MazeCell {
  final Position position;
  CellType type;
  bool visited; // לאלגוריתם יצירת מבוך

  MazeCell({
    required this.position,
    this.type = CellType.wall,
    this.visited = false,
  });

  bool get isWalkable =>
      type == CellType.path ||
      type == CellType.junction ||
      type == CellType.goal ||
      type == CellType.start;

  @override
  String toString() => 'MazeCell($position, $type)';
}
