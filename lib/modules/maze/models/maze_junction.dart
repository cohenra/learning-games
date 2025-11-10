import 'maze_cell.dart';
import 'maze_question.dart';

/// צומת במבוך עם שאלות לכל כיוון
class MazeJunction {
  final Position position;
  final Map<Direction, MazeQuestion> directionQuestions;
  final Map<Direction, bool> unlockedDirections;

  MazeJunction({
    required this.position,
    required this.directionQuestions,
  }) : unlockedDirections = {
          for (var dir in directionQuestions.keys) dir: false,
        };

  /// בדוק אם כיוון פתוח
  bool isDirectionUnlocked(Direction direction) {
    return unlockedDirections[direction] ?? false;
  }

  /// פתח כיוון
  void unlockDirection(Direction direction) {
    if (directionQuestions.containsKey(direction)) {
      unlockedDirections[direction] = true;
    }
  }

  /// קבל שאלה לכיוון
  MazeQuestion? getQuestion(Direction direction) {
    return directionQuestions[direction];
  }

  /// כיוונים זמינים (יש דרך אבל לא בהכרח פתוח)
  List<Direction> get availableDirections => directionQuestions.keys.toList();

  /// כיוונים נעולים
  List<Direction> get lockedDirections =>
      availableDirections.where((dir) => !isDirectionUnlocked(dir)).toList();

  /// האם כל הכיוונים פתוחים
  bool get isFullyUnlocked =>
      unlockedDirections.values.every((unlocked) => unlocked);
}
