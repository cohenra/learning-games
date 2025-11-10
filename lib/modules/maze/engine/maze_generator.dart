import 'dart:math';
import '../models/maze_cell.dart';
import '../models/maze_grid.dart';
import '../models/maze_question.dart';

/// מנוע יצירת מבוך אקראי
class MazeGenerator {
  final Random _random = Random();

  /// צור מבוך חדש
  MazeGrid generate({
    required int rows,
    required int cols,
    required int junctionCount,
    required bool isHebrew,
  }) {
    // וודא שיש מספר אי-זוגי של שורות ועמודות (טוב יותר לאלגוריתם)
    rows = rows | 1;
    cols = cols | 1;

    final maze = MazeGrid(rows: rows, cols: cols);

    // 1. קבע נקודות התחלה וסיום
    maze.startPosition = Position(1, 1);
    maze.goalPosition = Position(rows - 2, cols - 2);

    // 2. צור מסלול ראשי באמצעות DFS
    _carvePath(maze, maze.startPosition);

    // 3. סמן את ההתחלה והסיום
    maze.setCellType(maze.startPosition, CellType.start);
    maze.setCellType(maze.goalPosition, CellType.goal);

    // 4. הוסף צמתים עם שאלות
    _addJunctions(maze, junctionCount, isHebrew);

    // 5. פתח כיוון אחד בכל צומת (כדי שהמשחק יהיה אפשרי)
    _unlockInitialPaths(maze);

    return maze;
  }

  /// חצוב מסלול במבוך באמצעות DFS
  void _carvePath(MazeGrid maze, Position start) {
    final stack = <Position>[start];
    final visited = <Position>{};

    while (stack.isNotEmpty) {
      final current = stack.last;

      if (!visited.contains(current)) {
        visited.add(current);
        maze.setCellType(current, CellType.path);
      }

      // קבל כיוונים אקראיים
      final directions = _getShuffledDirections();
      bool foundUnvisited = false;

      for (final dir in directions) {
        final next = current.move(dir);

        // בדוק אם התא הבא תקף ולא בקצה
        if (!maze.isValidPosition(next)) continue;
        if (next.row <= 0 ||
            next.row >= maze.rows - 1 ||
            next.col <= 0 ||
            next.col >= maze.cols - 1) continue;

        // בדוק אם התא הבא לא ביקרנו בו
        if (!visited.contains(next)) {
          // חצוב דרך
          maze.setCellType(next, CellType.path);
          stack.add(next);
          foundUnvisited = true;
          break;
        }
      }

      if (!foundUnvisited) {
        stack.removeLast();
      }
    }
  }

  /// הוסף צמתים עם שאלות
  void _addJunctions(MazeGrid maze, int count, bool isHebrew) {
    final pathCells = <Position>[];

    // מצא את כל תאי הדרך (לא התחלה/סיום)
    for (int row = 1; row < maze.rows - 1; row++) {
      for (int col = 1; col < maze.cols - 1; col++) {
        final pos = Position(row, col);
        final cell = maze.getCell(pos);
        if (cell != null && cell.type == CellType.path) {
          // בדוק אם יש לפחות 2 כיוונים פתוחים
          final walkableNeighbors = maze.getWalkableNeighbors(pos);
          if (walkableNeighbors.length >= 2) {
            pathCells.add(pos);
          }
        }
      }
    }

    // בחר צמתים אקראיים
    pathCells.shuffle(_random);
    final selectedJunctions = pathCells.take(min(count, pathCells.length));

    // הוסף שאלות לכל צומת
    for (final pos in selectedJunctions) {
      final questions = _generateJunctionQuestions(maze, pos, isHebrew);
      if (questions.isNotEmpty) {
        maze.addJunction(pos, questions);
      }
    }
  }

  /// צור שאלות לצומת
  Map<Direction, MazeQuestion> _generateJunctionQuestions(
    MazeGrid maze,
    Position pos,
    bool isHebrew,
  ) {
    final questions = <Direction, MazeQuestion>{};
    final topics = QuestionTopic.values.toList()..shuffle(_random);
    int topicIndex = 0;

    // בדוק כל כיוון
    for (final dir in Direction.values) {
      final next = pos.move(dir);
      if (maze.isWalkable(next)) {
        // צור שאלה אקראית
        final topic = topics[topicIndex % topics.length];
        questions[dir] = MazeQuestion.generateRandom(topic, isHebrew: isHebrew);
        topicIndex++;
      }
    }

    return questions;
  }

  /// פתח כיוון התחלתי אחד בכל צומת
  void _unlockInitialPaths(MazeGrid maze) {
    for (final junction in maze.junctions.values) {
      if (junction.availableDirections.isNotEmpty) {
        // פתח כיוון אקראי אחד
        final randomDir =
            junction.availableDirections[_random.nextInt(junction.availableDirections.length)];
        junction.unlockDirection(randomDir);
      }
    }
  }

  /// קבל כיוונים מעורבבים
  List<Direction> _getShuffledDirections() {
    final dirs = Direction.values.toList();
    dirs.shuffle(_random);
    return dirs;
  }
}
