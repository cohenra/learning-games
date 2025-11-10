import 'package:flutter/material.dart';
import 'maze_cell.dart';

/// מצב השחקן במבוך
class PlayerState extends ChangeNotifier {
  Position _currentPosition;
  Direction _facingDirection;
  bool _isMoving;
  int _starsEarned;
  int _questionsAnswered;
  int _correctAnswers;
  DateTime? _startTime;

  PlayerState({
    required Position startPosition,
    Direction facingDirection = Direction.down,
  })  : _currentPosition = startPosition,
        _facingDirection = facingDirection,
        _isMoving = false,
        _starsEarned = 0,
        _questionsAnswered = 0,
        _correctAnswers = 0;

  // Getters
  Position get currentPosition => _currentPosition;
  Direction get facingDirection => _facingDirection;
  bool get isMoving => _isMoving;
  int get starsEarned => _starsEarned;
  int get questionsAnswered => _questionsAnswered;
  int get correctAnswers => _correctAnswers;
  int get wrongAnswers => _questionsAnswered - _correctAnswers;

  Duration? get timeElapsed {
    if (_startTime == null) return null;
    return DateTime.now().difference(_startTime!);
  }

  double get accuracy {
    if (_questionsAnswered == 0) return 0.0;
    return _correctAnswers / _questionsAnswered;
  }

  /// התחל מדידת זמן
  void startTimer() {
    _startTime = DateTime.now();
  }

  /// הזז את השחקן
  Future<void> moveTo(Position newPosition, Direction direction) async {
    _isMoving = true;
    _facingDirection = direction;
    notifyListeners();

    // המתן לסיום אנימציית תנועה
    await Future.delayed(const Duration(milliseconds: 500));

    _currentPosition = newPosition;
    _isMoving = false;
    notifyListeners();
  }

  /// סובב את השחקן (ללא תנועה)
  void face(Direction direction) {
    if (_facingDirection != direction) {
      _facingDirection = direction;
      notifyListeners();
    }
  }

  /// רשום תשובה לשאלה
  void recordAnswer(bool isCorrect) {
    _questionsAnswered++;
    if (isCorrect) {
      _correctAnswers++;
      _starsEarned++;
    }
    notifyListeners();
  }

  /// אפס סטטיסטיקות
  void reset(Position startPosition) {
    _currentPosition = startPosition;
    _facingDirection = Direction.down;
    _isMoving = false;
    _starsEarned = 0;
    _questionsAnswered = 0;
    _correctAnswers = 0;
    _startTime = null;
    notifyListeners();
  }

  /// קבל emoji לפי כיוון
  String get directionEmoji {
    switch (_facingDirection) {
      case Direction.up:
        return '⬆️';
      case Direction.down:
        return '⬇️';
      case Direction.left:
        return '⬅️';
      case Direction.right:
        return '➡️';
    }
  }
}
