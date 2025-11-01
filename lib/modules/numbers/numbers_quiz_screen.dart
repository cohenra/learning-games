import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/kid_button.dart';
import '../../widgets/reward_animation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// מסך חידון מספרים - שאלות אקראיות עם בחירה מרובה
class NumbersQuizScreen extends StatefulWidget {
  const NumbersQuizScreen({super.key});

  @override
  State<NumbersQuizScreen> createState() => _NumbersQuizScreenState();
}

class _NumbersQuizScreenState extends State<NumbersQuizScreen> {
  final int _totalQuestions = 5;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool? _isCorrect;
  bool _showReward = false;

  late int _correctAnswer;
  late List<int> _options;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    setState(() {
      _correctAnswer = _random.nextInt(10) + 1;
      _options = [_correctAnswer];

      // הוסף 3 תשובות שגויות
      while (_options.length < 4) {
        final wrongOption = _random.nextInt(10) + 1;
        if (!_options.contains(wrongOption)) {
          _options.add(wrongOption);
        }
      }

      // ערבב
      _options.shuffle();

      _selectedAnswer = null;
      _isCorrect = null;
      _showReward = false;
    });
  }

  void _handleAnswer(int answer) {
    if (_selectedAnswer != null) return; // כבר נענה

    final appProvider = context.read<AppProvider>();
    final isCorrect = answer == _correctAnswer;

    setState(() {
      _selectedAnswer = answer;
      _isCorrect = isCorrect;
    });

    // רשום תשובה
    appProvider.recordAnswer('numbers', isCorrect);

    if (isCorrect) {
      setState(() {
        _score++;
        _showReward = true;
      });
      appProvider.addStar('numbers');

      // הסתר את הפרס אחרי 2 שניות
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showReward = false;
          });
        }
      });
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _totalQuestions - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _generateQuestion();
    }
  }

  Color _getButtonColor(int option) {
    if (_selectedAnswer == null) {
      return Colors.blue.shade400;
    }

    if (option == _correctAnswer) {
      return Colors.green.shade500;
    }

    if (option == _selectedAnswer && !_isCorrect!) {
      return Colors.red.shade500;
    }

    return Colors.grey.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';
    final isQuizCompleted = _currentQuestionIndex >= _totalQuestions - 1 &&
        _selectedAnswer != null;

    if (_currentQuestionIndex >= _totalQuestions && _selectedAnswer != null) {
      return _buildCompletionScreen(l10n, isHebrew);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quizMode),
        centerTitle: true,
        backgroundColor: Colors.green.shade600,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.shade50,
                  Colors.blue.shade50,
                  Colors.purple.shade50,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // התקדמות
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${l10n.question} ${_currentQuestionIndex + 1}/$_totalQuestions',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: List.generate(
                            _score,
                            (index) => const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2),
                              child: Text('⭐', style: TextStyle(fontSize: 28)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // שאלה
                  Text(
                    l10n.howMany,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // נקודות המייצגות את המספר
                  Expanded(
                    child: Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: List.generate(
                          _correctAnswer,
                          (index) => Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade400,
                                  Colors.blue.shade600,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.shade200,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // אפשרויות תשובה
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: _options.map((option) {
                        return GestureDetector(
                          onTap: () => _handleAnswer(option),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getButtonColor(option),
                                  _getButtonColor(option).withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _getButtonColor(option)
                                      .withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '$option',
                                style: const TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // משוב וכפתור הבא
                  if (_selectedAnswer != null) ...[
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            _isCorrect! ? l10n.correct : l10n.tryAgain,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: _isCorrect!
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (!isQuizCompleted)
                            KidButton(
                              text: l10n.next,
                              onPressed: _nextQuestion,
                              color: Colors.blue.shade500,
                              width: 200,
                            ),
                          if (isQuizCompleted)
                            KidButton(
                              text: isHebrew ? 'סיום' : 'Finish',
                              onPressed: () {
                                setState(() {
                                  _currentQuestionIndex++;
                                });
                              },
                              color: Colors.green.shade500,
                              width: 200,
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // אנימציית פרס
          if (_showReward)
            Positioned.fill(
              child: RewardAnimation(
                onComplete: () {
                  setState(() {
                    _showReward = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen(AppLocalizations l10n, bool isHebrew) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.yellow.shade100,
              Colors.orange.shade100,
              Colors.pink.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.wellDone,
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  '${l10n.score}: $_score / $_totalQuestions',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                Wrap(
                  children: List.generate(
                    _score,
                    (index) => const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('⭐', style: TextStyle(fontSize: 48)),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                KidButton(
                  text: l10n.playAgain,
                  onPressed: () {
                    setState(() {
                      _currentQuestionIndex = 0;
                      _score = 0;
                      _selectedAnswer = null;
                      _isCorrect = null;
                    });
                    _generateQuestion();
                  },
                  color: Colors.orange.shade500,
                  width: 250,
                ),
                const SizedBox(height: 20),
                KidButton(
                  text: l10n.back,
                  onPressed: () => Navigator.pop(context),
                  color: Colors.blue.shade400,
                  width: 250,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
