import 'package:flame/game.dart';

/// Interface משותף למשחקי חידון
/// כל משחק חידון צריך לממש את המתודות האלה
/// כך ש-GameScreen יכול לעבוד איתם באופן גנרי
abstract class BaseQuizGame implements FlameGame {
  /// משמיע מחדש את ההנחיה הנוכחית
  Future<void> replayInstruction();

  /// מחליף מצב סאונד (מושתק/פעיל)
  void toggleSound();

  /// האם הסאונד פעיל
  bool get soundEnabled;
}
