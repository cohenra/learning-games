import 'dart:math';

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
    final random = Random();
    switch (difficulty) {
      case MazeDifficulty.easy:
        // בחר אחד מ-3 מבוכים שונים
        final mazeIndex = random.nextInt(3);
        switch (mazeIndex) {
          case 0:
            _initEasyMaze1();
            break;
          case 1:
            _initEasyMaze2();
            break;
          case 2:
            _initEasyMaze3();
            break;
        }
        break;
      case MazeDifficulty.medium:
        // בחר אחד מ-3 מבוכים שונים
        final mazeIndex = random.nextInt(3);
        switch (mazeIndex) {
          case 0:
            _initMediumMaze1();
            break;
          case 1:
            _initMediumMaze2();
            break;
          case 2:
            _initMediumMaze3();
            break;
        }
        break;
      case MazeDifficulty.hard:
        // בחר אחד מ-3 מבוכים שונים
        final mazeIndex = random.nextInt(3);
        switch (mazeIndex) {
          case 0:
            _initHardMaze1();
            break;
          case 1:
            _initHardMaze2();
            break;
          case 2:
            _initHardMaze3();
            break;
        }
        break;
    }
  }

  // מבוכים קלים - 7x7 עם 2 שאלות
  void _initEasyMaze1() {
    grid = [
      ['1', '1', '1', '1', '1', '1', '1'],
      ['1', 'S', '0', 'Q', '1', '0', '1'],
      ['1', '0', '1', '0', '1', '0', '1'],
      ['1', '0', '0', '0', '0', '0', '1'],
      ['1', '1', '1', '0', '1', 'Q', '1'],
      ['1', '0', '0', '0', '0', 'E', '1'],
      ['1', '1', '1', '1', '1', '1', '1'],
    ];
    startRow = 1;
    startCol = 1;
    endRow = 5;
    endCol = 5;
    junctions = [
      QuestionJunction(row: 1, col: 3, isUnlocked: false),
      QuestionJunction(row: 4, col: 5, isUnlocked: false),
    ];
  }

  void _initEasyMaze2() {
    grid = [
      ['1', '1', '1', '1', '1', '1', '1'],
      ['1', 'S', '0', '0', '0', '0', '1'],
      ['1', '1', '1', 'Q', '1', '0', '1'],
      ['1', '0', '0', '0', '0', '0', '1'],
      ['1', '0', '1', '1', '1', '1', '1'],
      ['1', '0', 'Q', '0', '0', 'E', '1'],
      ['1', '1', '1', '1', '1', '1', '1'],
    ];
    startRow = 1;
    startCol = 1;
    endRow = 5;
    endCol = 5;
    junctions = [
      QuestionJunction(row: 2, col: 3, isUnlocked: false),
      QuestionJunction(row: 5, col: 2, isUnlocked: false),
    ];
  }

  void _initEasyMaze3() {
    grid = [
      ['1', '1', '1', '1', '1', '1', '1'],
      ['1', 'S', '0', '0', '1', '0', '1'],
      ['1', '0', '1', '0', '1', '0', '1'],
      ['1', 'Q', '1', '0', '0', '0', '1'],
      ['1', '0', '0', '0', '1', 'Q', '1'],
      ['1', '0', '1', '0', '0', 'E', '1'],
      ['1', '1', '1', '1', '1', '1', '1'],
    ];
    startRow = 1;
    startCol = 1;
    endRow = 5;
    endCol = 5;
    junctions = [
      QuestionJunction(row: 3, col: 1, isUnlocked: false),
      QuestionJunction(row: 4, col: 5, isUnlocked: false),
    ];
  }

  // מבוכים בינוניים - 9x9 עם 4 שאלות
  void _initMediumMaze1() {
    grid = [
      ['1', '1', '1', '1', '1', '1', '1', '1', '1'],
      ['1', 'S', '0', 'Q', '1', '0', '0', '0', '1'],
      ['1', '0', '1', '0', '1', '0', '1', 'Q', '1'],
      ['1', '0', '1', '0', '0', '0', '1', '0', '1'],
      ['1', '0', '0', '0', '1', 'Q', '0', '0', '1'],
      ['1', '1', '1', '0', '1', '0', '1', '0', '1'],
      ['1', '0', '0', '0', '0', '0', '1', '0', '1'],
      ['1', '0', '1', 'Q', '1', '0', '0', 'E', '1'],
      ['1', '1', '1', '1', '1', '1', '1', '1', '1'],
    ];
    startRow = 1;
    startCol = 1;
    endRow = 7;
    endCol = 7;
    junctions = [
      QuestionJunction(row: 1, col: 3, isUnlocked: false),
      QuestionJunction(row: 2, col: 7, isUnlocked: false),
      QuestionJunction(row: 4, col: 5, isUnlocked: false),
      QuestionJunction(row: 7, col: 3, isUnlocked: false),
    ];
  }

  void _initMediumMaze2() {
    grid = [
      ['1', '1', '1', '1', '1', '1', '1', '1', '1'],
      ['1', 'S', '0', '0', '0', '0', 'Q', '0', '1'],
      ['1', '1', '1', '0', '1', '1', '1', '0', '1'],
      ['1', '0', 'Q', '0', '1', '0', '0', '0', '1'],
      ['1', '0', '1', '0', '0', '0', '1', '0', '1'],
      ['1', '0', '1', '1', '1', 'Q', '1', '0', '1'],
      ['1', '0', '0', '0', '0', '0', '0', '0', '1'],
      ['1', '0', '1', '0', '1', '1', '1', 'Q', '1'],
      ['1', '1', '1', '1', '1', '0', '0', 'E', '1'],
    ];
    startRow = 1;
    startCol = 1;
    endRow = 8;
    endCol = 7;
    junctions = [
      QuestionJunction(row: 1, col: 6, isUnlocked: false),
      QuestionJunction(row: 3, col: 2, isUnlocked: false),
      QuestionJunction(row: 5, col: 5, isUnlocked: false),
      QuestionJunction(row: 7, col: 7, isUnlocked: false),
    ];
  }

  void _initMediumMaze3() {
    grid = [
      ['1', '1', '1', '1', '1', '1', '1', '1', '1'],
      ['1', 'S', '0', '0', '1', '0', '0', 'Q', '1'],
      ['1', '0', '1', '0', '1', '0', '1', '0', '1'],
      ['1', 'Q', '1', '0', '0', '0', '1', '0', '1'],
      ['1', '0', '0', '0', '1', '0', '0', '0', '1'],
      ['1', '0', '1', 'Q', '1', '1', '1', '0', '1'],
      ['1', '0', '1', '0', '0', '0', '0', '0', '1'],
      ['1', '0', '0', '0', '1', '0', '1', 'Q', '1'],
      ['1', '1', '1', '1', '1', '1', '0', 'E', '1'],
    ];
    startRow = 1;
    startCol = 1;
    endRow = 8;
    endCol = 7;
    junctions = [
      QuestionJunction(row: 1, col: 7, isUnlocked: false),
      QuestionJunction(row: 3, col: 1, isUnlocked: false),
      QuestionJunction(row: 5, col: 3, isUnlocked: false),
      QuestionJunction(row: 7, col: 7, isUnlocked: false),
    ];
  }

  // מבוכים קשים - 11x11 עם 6 שאלות
  void _initHardMaze1() {
    grid = [
      ['1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1'],
      ['1', 'S', '0', 'Q', '1', '0', '0', '0', '0', '0', '1'],
      ['1', '0', '1', '0', '1', '0', '1', '1', '1', 'Q', '1'],
      ['1', '0', '1', '0', '0', '0', '1', '0', '0', '0', '1'],
      ['1', '0', '0', '0', '1', 'Q', '0', '0', '1', '0', '1'],
      ['1', '1', '1', '0', '1', '0', '1', '0', '1', '0', '1'],
      ['1', '0', 'Q', '0', '0', '0', '1', '0', '0', '0', '1'],
      ['1', '0', '1', '1', '1', 'Q', '1', '1', '1', '0', '1'],
      ['1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '1'],
      ['1', '0', '1', '0', '1', '1', '1', '0', '1', 'Q', '1'],
      ['1', '1', '1', '1', '1', '0', '0', '0', '0', 'E', '1'],
    ];
    startRow = 1;
    startCol = 1;
    endRow = 10;
    endCol = 9;
    junctions = [
      QuestionJunction(row: 1, col: 3, isUnlocked: false),
      QuestionJunction(row: 2, col: 9, isUnlocked: false),
      QuestionJunction(row: 4, col: 5, isUnlocked: false),
      QuestionJunction(row: 6, col: 2, isUnlocked: false),
      QuestionJunction(row: 7, col: 5, isUnlocked: false),
      QuestionJunction(row: 9, col: 9, isUnlocked: false),
    ];
  }

  void _initHardMaze2() {
    grid = [
      ['1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1'],
      ['1', 'S', '0', '0', '0', 'Q', '0', '0', '1', '0', '1'],
      ['1', '1', '1', '0', '1', '1', '1', '0', '1', '0', '1'],
      ['1', '0', 'Q', '0', '1', '0', '0', '0', '0', '0', '1'],
      ['1', '0', '1', '0', '0', '0', '1', '1', '1', 'Q', '1'],
      ['1', '0', '1', '1', '1', '0', '1', '0', '0', '0', '1'],
      ['1', '0', '0', '0', 'Q', '0', '0', '0', '1', '0', '1'],
      ['1', '0', '1', '0', '1', '1', '1', 'Q', '1', '0', '1'],
      ['1', '0', '1', '0', '0', '0', '0', '0', '0', '0', '1'],
      ['1', '0', '0', '0', '1', '0', '1', '1', '1', 'Q', '1'],
      ['1', '1', '1', '1', '1', '1', '0', '0', '0', 'E', '1'],
    ];
    startRow = 1;
    startCol = 1;
    endRow = 10;
    endCol = 9;
    junctions = [
      QuestionJunction(row: 1, col: 5, isUnlocked: false),
      QuestionJunction(row: 3, col: 2, isUnlocked: false),
      QuestionJunction(row: 4, col: 9, isUnlocked: false),
      QuestionJunction(row: 6, col: 4, isUnlocked: false),
      QuestionJunction(row: 7, col: 7, isUnlocked: false),
      QuestionJunction(row: 9, col: 9, isUnlocked: false),
    ];
  }

  void _initHardMaze3() {
    grid = [
      ['1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1'],
      ['1', 'S', '0', '0', '1', '0', 'Q', '0', '0', '0', '1'],
      ['1', '0', '1', '0', '1', '0', '1', '1', '1', 'Q', '1'],
      ['1', 'Q', '1', '0', '0', '0', '1', '0', '0', '0', '1'],
      ['1', '0', '0', '0', '1', '0', '0', '0', '1', '0', '1'],
      ['1', '0', '1', 'Q', '1', '1', '1', '0', '1', '0', '1'],
      ['1', '0', '1', '0', '0', '0', '0', '0', '1', '0', '1'],
      ['1', '0', '0', '0', '1', '0', '1', 'Q', '1', '0', '1'],
      ['1', '1', '1', '0', '1', '0', '1', '0', '0', '0', '1'],
      ['1', '0', '0', '0', '0', '0', '0', '0', '1', 'Q', '1'],
      ['1', '1', '1', '1', '1', '1', '1', '1', '0', 'E', '1'],
    ];
    startRow = 1;
    startCol = 1;
    endRow = 10;
    endCol = 9;
    junctions = [
      QuestionJunction(row: 1, col: 6, isUnlocked: false),
      QuestionJunction(row: 2, col: 9, isUnlocked: false),
      QuestionJunction(row: 3, col: 1, isUnlocked: false),
      QuestionJunction(row: 5, col: 3, isUnlocked: false),
      QuestionJunction(row: 7, col: 7, isUnlocked: false),
      QuestionJunction(row: 9, col: 9, isUnlocked: false),
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
