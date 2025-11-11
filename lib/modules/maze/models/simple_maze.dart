enum MazeDifficulty { easy, medium, hard }

/// מבוך פשוט וקטן שנכנס למסך
class SimpleMaze {
  late final List<List<String>> grid;
  late final int startRow;
  late final int startCol;
  late final int endRow;
  late final int endCol;
  late final List<QuestionJunction> junctions;

  SimpleMaze({MazeDifficulty difficulty = MazeDifficulty.easy}) {
    switch (difficulty) {
      case MazeDifficulty.easy:
        _initEasyMaze();
        break;
      case MazeDifficulty.medium:
        _initMediumMaze();
        break;
      case MazeDifficulty.hard:
        _initHardMaze();
        break;
    }
  }

  void _initEasyMaze() {
    // מבוך 7x7 קטן וקל (1 = קיר, 0 = דרך, S = התחלה, E = סיוף, Q = שאלה)
    grid = [
      ['1', '1', '1', '1', '1', '1', '1'],
      ['1', 'S', '0', '0', '1', '0', '1'],
      ['1', '0', '1', 'Q', '0', '0', '1'],
      ['1', '0', '0', '0', '1', '0', '1'],
      ['1', '1', '1', '0', '1', '0', '1'],
      ['1', '0', '0', '0', '0', 'E', '1'],
      ['1', '1', '1', '1', '1', '1', '1'],
    ];
    startRow = 1;
    startCol = 1;
    endRow = 5;
    endCol = 5;
    junctions = [
      QuestionJunction(row: 2, col: 3, isUnlocked: false),
    ];
  }

  void _initMediumMaze() {
    // מבוך 9x9 בינוני (1 = קיר, 0 = דרך, S = התחלה, E = סיוף, Q = שאלה)
    grid = [
      ['1', '1', '1', '1', '1', '1', '1', '1', '1'],
      ['1', 'S', '0', '0', '1', '0', '0', '0', '1'],
      ['1', '0', '1', '0', '1', '0', '1', 'Q', '1'],
      ['1', '0', '1', '0', '0', '0', '1', '0', '1'],
      ['1', '0', '1', '1', '1', 'Q', '0', '0', '1'],
      ['1', '0', '0', '0', '0', '0', '1', '0', '1'],
      ['1', '1', '1', '0', '1', '0', '1', '0', '1'],
      ['1', '0', '0', '0', '1', '0', '0', 'E', '1'],
      ['1', '1', '1', '1', '1', '1', '1', '1', '1'],
    ];
    startRow = 1;
    startCol = 1;
    endRow = 7;
    endCol = 7;
    junctions = [
      QuestionJunction(row: 2, col: 7, isUnlocked: false),
      QuestionJunction(row: 4, col: 5, isUnlocked: false),
    ];
  }

  void _initHardMaze() {
    // מבוך 11x11 מורכב וקשה (1 = קיר, 0 = דרך, S = התחלה, E = סיוף, Q = שאלה)
    grid = [
      ['1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1'],
      ['1', 'S', '0', '0', '1', '0', '0', '0', '0', '0', '1'],
      ['1', '0', '1', '0', '1', '0', '1', '1', '1', '0', '1'],
      ['1', '0', '1', '0', '0', '0', '1', '0', '0', '0', '1'],
      ['1', '0', '1', '1', '1', 'Q', '1', '0', '1', 'Q', '1'],
      ['1', '0', '0', '0', '0', '0', '0', '0', '1', '0', '1'],
      ['1', '1', '1', '0', '1', '1', '1', 'Q', '1', '0', '1'],
      ['1', '0', '0', '0', '1', '0', '0', '0', '0', '0', '1'],
      ['1', '0', '1', '1', '1', '0', '1', '1', '1', '1', '1'],
      ['1', '0', '0', '0', '0', '0', '0', '0', 'E', '0', '1'],
      ['1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1'],
    ];
    startRow = 1;
    startCol = 1;
    endRow = 9;
    endCol = 8;
    junctions = [
      QuestionJunction(row: 4, col: 5, isUnlocked: false),
      QuestionJunction(row: 4, col: 9, isUnlocked: false),
      QuestionJunction(row: 6, col: 7, isUnlocked: false),
    ];
  }

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
