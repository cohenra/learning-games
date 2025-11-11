import 'dart:async';
import 'package:flutter/material.dart';
import 'package:learning_fun/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';
import '../../../widgets/kid_back_button.dart';
import '../models/simple_maze.dart';
import '../models/clear_question.dart';
import '../widgets/maze_painter.dart';

/// מסך משחק המבוך החדש - פשוט וברור
class SimpleMazeGameScreen extends StatefulWidget {
  final MazeDifficulty difficulty;

  const SimpleMazeGameScreen({
    super.key,
    this.difficulty = MazeDifficulty.easy,
  });

  @override
  State<SimpleMazeGameScreen> createState() => _SimpleMazeGameScreenState();
}

class _SimpleMazeGameScreenState extends State<SimpleMazeGameScreen> {
  late SimpleMaze _maze;
  late int _playerRow;
  late int _playerCol;
  late Stopwatch _stopwatch;
  Timer? _timer;

  bool _showingQuestion = false;
  ClearQuestion? _currentQuestion;
  QuestionJunction? _pendingJunction;
  String? _selectedAnswer;
  bool? _isCorrect;

  int _starsEarned = 0;
  int _questionsAnswered = 0;
  int _correctAnswers = 0;
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
    _maze = SimpleMaze(difficulty: widget.difficulty);
    _playerRow = _maze.startRow;
    _playerCol = _maze.startCol;

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
    super.dispose();
  }

  void _handleSwipe(DragEndDetails details) {
    if (_showingQuestion) return;

    final velocity = details.velocity.pixelsPerSecond;
    final dx = velocity.dx.abs();
    final dy = velocity.dy.abs();

    int newRow = _playerRow;
    int newCol = _playerCol;

    // קבע כיוון לפי מהירות הגרירה
    if (dx > dy) {
      // תנועה אופקית
      if (velocity.dx > 0) {
        // ימינה
        newCol++;
      } else {
        // שמאלה
        newCol--;
      }
    } else {
      // תנועה אנכית
      if (velocity.dy > 0) {
        // למטה
        newRow++;
      } else {
        // למעלה
        newRow--;
      }
    }

    _tryMove(newRow, newCol);
  }

  void _tryMove(int newRow, int newCol) {
    // בדוק אם זו נקודת שאלה
    if (_maze.isQuestion(newRow, newCol)) {
      final junction = _maze.getJunction(newRow, newCol);
      if (junction != null && !junction.isUnlocked) {
        // הצג שאלה
        _showQuestionDialog(newRow, newCol, junction);
        return;
      }
    }

    // בדוק אם התנועה אפשרית
    if (_maze.canMoveTo(newRow, newCol)) {
      setState(() {
        _playerRow = newRow;
        _playerCol = newCol;
      });

      // בדוק אם הגענו לסיום
      if (_maze.isEnd(newRow, newCol)) {
        _handleVictory();
      }
    }
  }

  void _showQuestionDialog(
      int targetRow, int targetCol, QuestionJunction junction) {
    final l10n = AppLocalizations.of(context)!;
    final isHebrew = l10n.localeName == 'he';

    // יצור שאלה חדשה
    final question = ClearQuestion.generate(isHebrew: isHebrew);

    setState(() {
      _showingQuestion = true;
      _currentQuestion = question;
      _pendingJunction = junction;
    });

    // הקרא את השאלה בקול
    _speak(isHebrew ? question.spokenText : question.spokenTextEn);
  }

  void _handleAnswer(String answer) {
    if (_currentQuestion == null || _selectedAnswer != null) return;

    final isCorrect = answer == _currentQuestion!.correctAnswer;

    setState(() {
      _selectedAnswer = answer;
      _isCorrect = isCorrect;
      _questionsAnswered++;
      if (isCorrect) {
        _correctAnswers++;
        _starsEarned++;
      }
    });

    if (isCorrect) {
      // נכון! פתח את הצומת
      _pendingJunction?.unlock();

      // הקרא "מעולה!"
      _speak("מעולה!");

      // המשך אחרי 1.5 שניות
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _showingQuestion = false;
            _currentQuestion = null;
            _selectedAnswer = null;
            _isCorrect = null;

            // התקדם לצומת
            if (_pendingJunction != null) {
              _playerRow = _pendingJunction!.row;
              _playerCol = _pendingJunction!.col;
              _pendingJunction = null;
            }
          });
        }
      });
    } else {
      // טעות! נסה שוב
      _speak("נסה שוב!");

      // אפס את הבחירה אחרי שנייה
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _selectedAnswer = null;
            _isCorrect = null;
          });
        }
      });
    }
  }

  void _closeQuestion() {
    setState(() {
      _showingQuestion = false;
      _currentQuestion = null;
      _pendingJunction = null;
    });
  }

  void _speak(String text) {
    try {
      final appProvider = context.read<AppProvider>();
      appProvider.speak(text);
    } catch (e) {
      // שקט - לא קריטי
    }
  }

  void _handleVictory() {
    _stopwatch.stop();
    _timer?.cancel();

    // עדכן התקדמות
    final appProvider = context.read<AppProvider>();
    appProvider.markModuleCompleted('maze');

    // הוסף כוכבים
    for (int i = 0; i < _starsEarned; i++) {
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
              const Text('🏆', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                l10n.mazeReachedGoal,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // סטטיסטיקות
              _buildStatRow('⏱️ זמן', _formatTime(_stopwatch.elapsed)),
              const SizedBox(height: 8),
              _buildStatRow('❓ שאלות', '$_questionsAnswered'),
              const SizedBox(height: 8),
              _buildStatRow('✅ נכונות', '$_correctAnswers'),
              const SizedBox(height: 8),
              _buildStatRow('⭐ כוכבים', '$_starsEarned'),

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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(l10n.playAgain),
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(l10n.back),
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

  Widget _buildStatRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;

    // חשב גודל תא שיתאים למסך
    final availableWidth = screenSize.width - 32;
    final availableHeight = screenSize.height - 200; // מקום לכותרת ומידע
    final gridSize = _maze.grid.length;
    final cellSize =
        (availableWidth / gridSize).clamp(0.0, availableHeight / gridSize);

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
                                  const Icon(Icons.timer, size: 16),
                                  const SizedBox(width: 4),
                                  Text(_formatTime(_stopwatch.elapsed)),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.star, size: 16,
                                      color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text('$_starsEarned'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // הנחיה - למעלה בלי רקע
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.swipe, size: 18, color: Colors.black54),
                        const SizedBox(width: 6),
                        Text(
                          l10n.mazeSwipeToMove,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // המבוך - מרכז המסך
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onPanEnd: _handleSwipe,
                        child: Container(
                          width: gridSize * cellSize,
                          height: gridSize * cellSize,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CustomPaint(
                            painter: MazePainter(
                              maze: _maze,
                              playerRow: _playerRow,
                              playerCol: _playerCol,
                              cellSize: cellSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // אוברליי שאלה
              if (_showingQuestion && _currentQuestion != null)
                _buildQuestionOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerContent(String answer) {
    if (_currentQuestion == null) {
      return Text(
        answer,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      );
    }

    // שאלת צבע - הצג ריבוע צבעוני
    if (_currentQuestion!.type == QuestionType.color &&
        _currentQuestion!.colorMap != null) {
      final color = _currentQuestion!.colorMap![answer];
      return Container(
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!, width: 2),
        ),
      );
    }

    // שאלת צורה - הצג איקון גדול
    if (_currentQuestion!.type == QuestionType.shape &&
        _currentQuestion!.shapeMap != null) {
      final icon = _currentQuestion!.shapeMap![answer];
      return Icon(
        icon,
        size: 60,
        color: Colors.blue[700],
      );
    }

    // שאלה טקסטואלית רגילה
    return Text(
      answer,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildQuestionOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // כותרת
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '❓ שאלה',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _closeQuestion,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // השאלה
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      _currentQuestion!.questionText,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // כפתור השמעה חוזרת
                    IconButton(
                      onPressed: () {
                        final l10n = AppLocalizations.of(context)!;
                        final isHebrew = l10n.localeName == 'he';
                        _speak(isHebrew
                            ? _currentQuestion!.spokenText
                            : _currentQuestion!.spokenTextEn);
                      },
                      icon: const Icon(Icons.volume_up, size: 32),
                      color: Colors.blue[700],
                      tooltip: 'השמע שאלה',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // תשובות
              ..._currentQuestion!.answers.map((answer) {
                // קבע צבע גבול לפי מצב התשובה
                Color borderColor = Colors.blue[300]!;
                double borderWidth = 2;
                Color? backgroundColor;

                if (_selectedAnswer == answer) {
                  if (_isCorrect == true) {
                    borderColor = Colors.green[600]!;
                    borderWidth = 3;
                    backgroundColor = Colors.green[50];
                  } else if (_isCorrect == false) {
                    borderColor = Colors.red[600]!;
                    borderWidth = 3;
                    backgroundColor = Colors.red[50];
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _selectedAnswer == null
                          ? () => _handleAnswer(answer)
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: backgroundColor ?? Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: borderColor,
                            width: borderWidth,
                          ),
                        ),
                        child: _buildAnswerContent(answer),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
