/// מבוך פשוט וקטן שנכנס למסך
class SimpleMaze {
  // מבוך 5x5 קבוע (1 = קיר, 0 = דרך)
  // S = התחלה, E = סיוף, Q = שאלה
  final List<List<String>> grid = [
    ['1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1'],
    ['1', 'S', '0', '0', '1', '0', '0', '0', '0', '0', '1'],
    ['1', '0', '1', '0', '1', '0', '1', '1', '1', '0', '1'],
    ['1', '0', '1', '0', '0', '0', '1', '0', '0', '0', '1'],
    ['1', '0', '1', '1', '1', 'Q', '1', '0', '1', '0', '1'],
    ['1', '0', '0', '0', '0', '0', '0', '0', '1', '0', '1'],
    ['1', '1', '1', '0', '1', '1', '1', 'Q', '1', '0', '1'],
    ['1', '0', '0', '0', '1', '0', '0', '0', '0', '0', '1'],
    ['1', '0', '1', '1', '1', '0', '1', '1', '1', '1', '1'],
    ['1', '0', '0', '0', '0', '0', '0', '0', 'E', '0', '1'],
    ['1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1'],
  ];

  // נקודת התחלה
  final int startRow = 1;
  final int startCol = 1;

  // נקודת סיום
  final int endRow = 9;
  final int endCol = 8;

  // צמתי שאלות
  final List<QuestionJunction> junctions = [
    QuestionJunction(row: 4, col: 5, isUnlocked: false),
    QuestionJunction(row: 6, col: 7, isUnlocked: false),
  ];

  bool isWall(int row, int col) {
    if (row < 0 || row >= grid.length || col < 0 || col >= grid[0].length) {
      return true;
    }
    return grid[row][col] == '1';
  }

  bool isPath(int row, int col) {
    if (row < 0 || row >= grid.length || col < 0 || col >= grid[0].length) {
      return false;
    }
    final cell = grid[row][col];
    return cell == '0' || cell == 'S' || cell == 'E' || cell == 'Q';
  }

  bool isQuestion(int row, int col) {
    return grid[row][col] == 'Q';
  }

  bool isEnd(int row, int col) {
    return grid[row][col] == 'E';
  }

  QuestionJunction? getJunction(int row, int col) {
    try {
      return junctions.firstWhere((j) => j.row == row && j.col == col);
    } catch (e) {
      return null;
    }
  }

  bool canMoveTo(int row, int col) {
    // בדוק אם זה קיר
    if (isWall(row, col)) return false;

    // אם זה שאלה, בדוק אם פתוח
    final junction = getJunction(row, col);
    if (junction != null && !junction.isUnlocked) {
      return false;
    }

    return true;
  }
}

class QuestionJunction {
  final int row;
  final int col;
  bool isUnlocked;

  QuestionJunction({
    required this.row,
    required this.col,
    this.isUnlocked = false,
  });

  void unlock() {
    isUnlocked = true;
  }
}
