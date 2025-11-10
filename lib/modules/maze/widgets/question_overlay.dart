import 'package:flutter/material.dart';
import '../models/maze_question.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// אוברליי שאלה עם אנימציות
class QuestionOverlay extends StatefulWidget {
  final MazeQuestion question;
  final Function(bool isCorrect, String selectedAnswer) onAnswered;
  final VoidCallback onClose;

  const QuestionOverlay({
    super.key,
    required this.question,
    required this.onAnswered,
    required this.onClose,
  });

  @override
  State<QuestionOverlay> createState() => _QuestionOverlayState();
}

class _QuestionOverlayState extends State<QuestionOverlay>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _shakeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shakeAnimation;

  String? _selectedAnswer;
  bool? _isCorrect;
  bool _showingResult = false;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _handleAnswer(String answer) {
    if (_showingResult) return;

    setState(() {
      _selectedAnswer = answer;
      _isCorrect = answer == widget.question.correctAnswer;
      _showingResult = true;
    });

    if (_isCorrect!) {
      // אנימציית הצלחה
      _slideController.reverse();
      Future.delayed(const Duration(milliseconds: 400), () {
        widget.onAnswered(true, answer);
      });
    } else {
      // אנימציית טעות - רעידה
      _shakeController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 800), () {
          setState(() {
            _selectedAnswer = null;
            _isCorrect = null;
            _showingResult = false;
          });
          _shakeController.reset();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: Colors.black54,
      child: Center(
        child: SlideTransition(
          position: _slideAnimation,
          child: AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              final shake = _isCorrect == false
                  ? ((_shakeAnimation.value * 4) % 1.0 - 0.5) * 10
                  : 0.0;

              return Transform.translate(
                offset: Offset(shake, 0),
                child: child,
              );
            },
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
                      Expanded(
                        child: Text(
                          l10n.mazeUnlockDirection,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: widget.onClose,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // השאלה
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.question.question,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // תשובות
                  ...widget.question.answers.map((answer) {
                    return _buildAnswerButton(answer);
                  }),

                  // משוב
                  if (_showingResult && _isCorrect != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: _buildFeedback(l10n),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerButton(String answer) {
    final isSelected = _selectedAnswer == answer;
    final showResult = _showingResult && isSelected;

    Color backgroundColor;
    Color textColor = Colors.black87;

    if (showResult) {
      if (_isCorrect!) {
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[900]!;
      } else {
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[900]!;
      }
    } else if (isSelected) {
      backgroundColor = Colors.blue[100]!;
    } else {
      backgroundColor = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showingResult ? null : () => _handleAnswer(answer),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.blue[400]! : Colors.grey[300]!,
                width: isSelected ? 3 : 2,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    answer,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (showResult)
                  Icon(
                    _isCorrect! ? Icons.check_circle : Icons.cancel,
                    color: _isCorrect! ? Colors.green[700] : Colors.red[700],
                    size: 28,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback(AppLocalizations l10n) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: _isCorrect! ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isCorrect! ? Colors.green[300]! : Colors.red[300]!,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isCorrect! ? Icons.celebration : Icons.refresh,
                  color: _isCorrect! ? Colors.green[700] : Colors.red[700],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  _isCorrect! ? l10n.correct : l10n.tryAgain,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isCorrect! ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
