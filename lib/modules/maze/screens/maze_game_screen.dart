import 'dart:async';
import 'package:flutter/material.dart';
import 'package:learning_fun/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';
import '../../../widgets/kid_back_button.dart';
import '../engine/maze_generator.dart';
import '../models/maze_cell.dart';
import '../models/maze_grid.dart';
import '../models/maze_junction.dart';
import '../models/player_state.dart';
import '../widgets/direction_button.dart';
import '../widgets/maze_view.dart';
import '../widgets/question_overlay.dart';
import 'maze_menu_screen.dart';

/// מסך משחק המבוך
class MazeGameScreen extends StatefulWidget {
  final MazeDifficulty difficulty;

  const MazeGameScreen({
    super.key,
    required this.difficulty,
  });

  @override
  State<MazeGameScreen> createState() => _MazeGameScreenState();
}

class _MazeGameScreenState extends State<MazeGameScreen> {
  late MazeGrid _maze;
  late PlayerState _playerState;
  late Stopwatch _stopwatch;
  Timer? _timer;

  bool _showingQuestion = false;
  Direction? _pendingDirection;
  MazeJunction? _currentJunction;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initializeGame();
      _initialized = true;
    }
  }

  void _initializeGame() {
    final l10n = AppLocalizations.of(context)!;
    final isHebrew = l10n.localeName == 'he';

    // צור מבוך חדש
    final generator = MazeGenerator();
    final size = _getMazeSize();
    final junctionCount = _getJunctionCount();

    _maze = generator.generate(
      rows: size,
      cols: size,
      junctionCount: junctionCount,
      isHebrew: isHebrew,
    );

    // אתחל שחקן
    _playerState = PlayerState(
      startPosition: _maze.startPosition,
    );

    // התחל טיימר
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    _playerState.dispose();
    super.dispose();
  }

  int _getMazeSize() {
    switch (widget.difficulty) {
      case MazeDifficulty.easy:
        return 7;
      case MazeDifficulty.medium:
        return 9;
      case MazeDifficulty.hard:
        return 11;
    }
  }

  int _getJunctionCount() {
    switch (widget.difficulty) {
      case MazeDifficulty.easy:
        return 3;
      case MazeDifficulty.medium:
        return 5;
      case MazeDifficulty.hard:
        return 8;
    }
  }

  void _handleDirectionPressed(Direction direction) {
    if (_playerState.isMoving || _showingQuestion) return;

    final currentPos = _playerState.currentPosition;
    final nextPos = currentPos.move(direction);

    // בדוק אם התנועה אפשרית
    if (!_maze.canMove(currentPos, direction)) {
      // בדוק אם זה צומת עם שאלה
      final junction = _maze.junctions[currentPos];
      if (junction != null && !junction.isDirectionUnlocked(direction)) {
        _showQuestion(direction, junction);
      }
      return;
    }

    // בצע תנועה
    _playerState.moveTo(nextPos, direction);
  }

  void _showQuestion(Direction direction, MazeJunction junction) {
    final question = junction.getQuestion(direction);
    if (question == null) return;

    setState(() {
      _showingQuestion = true;
      _pendingDirection = direction;
      _currentJunction = junction;
    });
  }

  void _handleQuestionAnswered(bool isCorrect, String selectedAnswer) {
    if (isCorrect && _currentJunction != null && _pendingDirection != null) {
      // פתח את הכיוון
      _currentJunction!.unlockDirection(_pendingDirection!);

      // עדכן ניקוד
      _playerState.recordAnswer(true);

      // בצע את התנועה
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          final nextPos = _playerState.currentPosition.move(_pendingDirection!);
          _playerState.moveTo(nextPos, _pendingDirection!);
        }
      });
    } else {
      _playerState.recordAnswer(false);
    }

    setState(() {
      _showingQuestion = false;
      _pendingDirection = null;
      _currentJunction = null;
    });
  }

  void _closeQuestion() {
    setState(() {
      _showingQuestion = false;
      _pendingDirection = null;
      _currentJunction = null;
    });
  }

  void _handleGoalReached() {
    _stopwatch.stop();
    _timer?.cancel();

    // עדכן התקדמות
    final appProvider = context.read<AppProvider>();
    appProvider.markModuleCompleted('maze');

    // הוסף כוכבים
    for (int i = 0; i < _playerState.starsEarned; i++) {
      appProvider.addStar('maze');
    }

    _showVictoryDialog();
  }

  void _showVictoryDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.amber[100]!,
                Colors.orange[100]!,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // אייקון ניצחון
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Transform.rotate(
                      angle: value * 6.28, // סיבוב מלא
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.amber[400],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                l10n.mazeReachedGoal,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // סטטיסטיקות
              _buildStatRow(
                l10n.mazeTimeElapsed,
                _formatTime(_stopwatch.elapsed),
                Icons.timer,
              ),
              const SizedBox(height: 12),
              _buildStatRow(
                l10n.mazeQuestionsAnswered,
                '${_playerState.questionsAnswered}',
                Icons.quiz,
              ),
              const SizedBox(height: 12),
              _buildStatRow(
                l10n.mazeCorrectAnswers,
                '${_playerState.correctAnswers}',
                Icons.check_circle,
              ),
              const SizedBox(height: 12),
              _buildStatRow(
                l10n.mazeStars,
                '${_playerState.starsEarned} ⭐',
                Icons.star,
              ),

              const SizedBox(height: 24),

              // כפתורים
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _initializeGame();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.playAgain,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.back,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  bool _isDirectionEnabled(Direction direction) {
    final currentPos = _playerState.currentPosition;
    final nextPos = currentPos.move(direction);

    // בדוק אם התא הבא תקף
    if (!_maze.isValidPosition(nextPos)) return false;

    // בדוק אם התא הבא ניתן להליכה
    if (!_maze.isWalkable(nextPos)) return false;

    return true;
  }

  bool _isDirectionLocked(Direction direction) {
    final currentPos = _playerState.currentPosition;
    final junction = _maze.junctions[currentPos];

    if (junction == null) return false;

    return !junction.isDirectionUnlocked(direction) &&
        junction.directionQuestions.containsKey(direction);
  }

  String _getDirectionLabel(Direction direction, AppLocalizations l10n) {
    switch (direction) {
      case Direction.up:
        return l10n.mazeMoveUp;
      case Direction.down:
        return l10n.mazeMoveDown;
      case Direction.left:
        return l10n.mazeMoveLeft;
      case Direction.right:
        return l10n.mazeMoveRight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    final cellSize = (screenSize.width - 40) / _maze.cols;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[100]!,
              Colors.purple[100]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // כותרת ומידע עליון
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const KidBackButton(),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.mazeTitle,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.timer, size: 16, color: Colors.grey[700]),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatTime(_stopwatch.elapsed),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(Icons.star, size: 16, color: Colors.amber[700]),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_playerState.starsEarned}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // המבוך
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: MazeView(
                            maze: _maze,
                            playerState: _playerState,
                            cellSize: cellSize,
                            onGoalReached: _handleGoalReached,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // כפתורי כיוון
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // למעלה
                        DirectionButton(
                          direction: Direction.up,
                          isEnabled: _isDirectionEnabled(Direction.up),
                          isLocked: _isDirectionLocked(Direction.up),
                          onPressed: () => _handleDirectionPressed(Direction.up),
                        ),
                        const SizedBox(height: 12),
                        // שמאל, מרכז, ימין
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DirectionButton(
                              direction: Direction.left,
                              isEnabled: _isDirectionEnabled(Direction.left),
                              isLocked: _isDirectionLocked(Direction.left),
                              onPressed: () => _handleDirectionPressed(Direction.left),
                            ),
                            const SizedBox(width: 80),
                            DirectionButton(
                              direction: Direction.right,
                              isEnabled: _isDirectionEnabled(Direction.right),
                              isLocked: _isDirectionLocked(Direction.right),
                              onPressed: () => _handleDirectionPressed(Direction.right),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // למטה
                        DirectionButton(
                          direction: Direction.down,
                          isEnabled: _isDirectionEnabled(Direction.down),
                          isLocked: _isDirectionLocked(Direction.down),
                          onPressed: () => _handleDirectionPressed(Direction.down),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // אוברליי שאלה
              if (_showingQuestion &&
                  _currentJunction != null &&
                  _pendingDirection != null)
                QuestionOverlay(
                  question: _currentJunction!.getQuestion(_pendingDirection!)!,
                  isHebrew: l10n.localeName == 'he',
                  onAnswered: _handleQuestionAnswered,
                  onClose: _closeQuestion,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
