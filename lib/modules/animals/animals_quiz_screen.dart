import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/kid_button.dart';
import '../../widgets/reward_animation.dart';
import '../../utils/responsive_helper.dart';

/// מסך חידון בעלי חיים - שאלות אקראיות עם בחירה מרובה
class AnimalsQuizScreen extends StatefulWidget {
  const AnimalsQuizScreen({super.key});

  @override
  State<AnimalsQuizScreen> createState() => _AnimalsQuizScreenState();
}

class _AnimalsQuizScreenState extends State<AnimalsQuizScreen> {
  final int _totalQuestions = 10;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool? _isCorrect;
  bool _showReward = false;
  bool _isHebrew = true;

  late int _correctAnswerIndex;
  late List<Map<String, String>> _options;

  final Random _random = Random();

  // 12 בעלי חיים
  final List<Map<String, String>> _allAnimals = [
    {'emoji': '🐕', 'nameHe': 'כלב', 'nameEn': 'Dog'},
    {'emoji': '🐈', 'nameHe': 'חתול', 'nameEn': 'Cat'},
    {'emoji': '🐰', 'nameHe': 'ארנב', 'nameEn': 'Rabbit'},
    {'emoji': '🐘', 'nameHe': 'פיל', 'nameEn': 'Elephant'},
    {'emoji': '🦁', 'nameHe': 'אריה', 'nameEn': 'Lion'},
    {'emoji': '🐄', 'nameHe': 'פרה', 'nameEn': 'Cow'},
    {'emoji': '🐴', 'nameHe': 'סוס', 'nameEn': 'Horse'},
    {'emoji': '🐦', 'nameHe': 'ציפור', 'nameEn': 'Bird'},
    {'emoji': '🐟', 'nameHe': 'דג', 'nameEn': 'Fish'},
    {'emoji': '🐻', 'nameHe': 'דוב', 'nameEn': 'Bear'},
    {'emoji': '🐵', 'nameHe': 'קוף', 'nameEn': 'Monkey'},
    {'emoji': '🐢', 'nameHe': 'צב', 'nameEn': 'Turtle'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isHebrew = Localizations.localeOf(context).languageCode == 'he';
      });
      _generateQuestion();
    });
  }

  void _generateQuestion() {
    setState(() {
      // בחר בעל חיים נכון אקראי
      _correctAnswerIndex = _random.nextInt(_allAnimals.length);
      _options = [_allAnimals[_correctAnswerIndex]];

      // הוסף 3 בעלי חיים שגויים
      while (_options.length < 4) {
        final wrongIndex = _random.nextInt(_allAnimals.length);
        final wrongAnimal = _allAnimals[wrongIndex];
        if (!_options.any((a) => a['emoji'] == wrongAnimal['emoji'])) {
          _options.add(wrongAnimal);
        }
      }

      // ערבב
      _options.shuffle();

      _selectedAnswer = null;
      _isCorrect = null;
      _showReward = false;
    });

    // דבר את השאלה
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakQuestion();
    });
  }

  void _speakQuestion() {
    final appProvider = context.read<AppProvider>();
    final animalName = _isHebrew
        ? _allAnimals[_correctAnswerIndex]['nameHe']!
        : _allAnimals[_correctAnswerIndex]['nameEn']!;

    final question = _isHebrew
        ? 'היכן ה$animalName?'
        : 'Where is the $animalName?';

    appProvider.speak(question);
  }

  void _checkAnswer(int selectedIndex) {
    if (_selectedAnswer != null) return; // כבר נבחרה תשובה

    setState(() {
      _selectedAnswer = selectedIndex;
      _isCorrect = _options[selectedIndex]['emoji'] ==
          _allAnimals[_correctAnswerIndex]['emoji'];

      if (_isCorrect!) {
        _score += 10;
        _showReward = true;
      }
    });

    final appProvider = context.read<AppProvider>();
    if (_isCorrect!) {
      appProvider.speak(_isHebrew ? 'מצוין!' : 'Excellent!');
    } else {
      appProvider.speak(_isHebrew ? 'לא נכון, נסה שוב' : 'Wrong, try again');
    }

    // המשך לשאלה הבאה אחרי עיכוב
    if (_isCorrect!) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          if (_currentQuestionIndex < _totalQuestions - 1) {
            setState(() {
              _currentQuestionIndex++;
            });
            _generateQuestion();
          } else {
            _showFinalScore();
          }
        }
      });
    }
  }

  void _showFinalScore() {
    final percentage = ((_score / (_totalQuestions * 10)) * 100).round();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          _isHebrew ? '🎉 כל הכבוד! 🎉' : '🎉 Well Done! 🎉',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isHebrew ? 'סיימת את החידון!' : 'You finished the quiz!',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              _isHebrew ? 'הניקוד שלך:' : 'Your score:',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              '$_score/${_totalQuestions * 10}',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: percentage >= 70 ? Colors.green : Colors.orange,
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 24,
                color: percentage >= 70 ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(_isHebrew ? 'סיום' : 'Exit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentQuestionIndex = 0;
                _score = 0;
              });
              _generateQuestion();
            },
            child: Text(_isHebrew ? 'שחק שוב' : 'Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isHebrew ? 'חידון 🎮' : 'Quiz 🎮'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50,
              Colors.blue.shade50,
              Colors.yellow.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Progress and score
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_currentQuestionIndex + 1}/$_totalQuestions',
                          style: TextStyle(
                            fontSize: responsive.fontSize(24),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '⭐ $_score',
                          style: TextStyle(
                            fontSize: responsive.fontSize(24),
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Question
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _isHebrew
                          ? 'היכן ה${_allAnimals[_correctAnswerIndex]['nameHe']}?'
                          : 'Where is the ${_allAnimals[_correctAnswerIndex]['nameEn']}?',
                      style: TextStyle(
                        fontSize: responsive.fontSize(32),
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Options
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final availableHeight = constraints.maxHeight;
                        final availableWidth = constraints.maxWidth;

                        const padding = 20.0;
                        const spacing = 20.0;

                        // 4 items in 2x2 grid
                        final rowCount = 2;

                        // Calculate card dimensions
                        final totalVerticalSpacing = spacing + (padding * 2);
                        final cardHeight = (availableHeight - totalVerticalSpacing) / rowCount;

                        final totalHorizontalSpacing = spacing + (padding * 2);
                        final cardWidth = (availableWidth - totalHorizontalSpacing) / 2;

                        final aspectRatio = cardWidth / cardHeight;

                        return GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(padding),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: spacing,
                            mainAxisSpacing: spacing,
                            childAspectRatio: aspectRatio,
                          ),
                          itemCount: _options.length,
                          itemBuilder: (context, index) {
                            return _buildOptionCard(index);
                          },
                        );
                      },
                    ),
                  ),

                  // Repeat question button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: KidButton(
                      text: _isHebrew ? 'שמע שוב 🔊' : 'Hear Again 🔊',
                      icon: Icons.volume_up,
                      onPressed: _speakQuestion,
                      color: Colors.blue,
                      width: responsive.width(80),
                      height: 60,
                    ),
                  ),
                ],
              ),

              // Reward animation
              if (_showReward)
                const Positioned.fill(
                  child: RewardAnimation(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(int index) {
    final option = _options[index];
    final isSelected = _selectedAnswer == index;
    final isCorrectOption = option['emoji'] == _allAnimals[_correctAnswerIndex]['emoji'];

    Color borderColor = Colors.green.shade200;
    if (isSelected) {
      borderColor = _isCorrect! ? Colors.green : Colors.red;
    }

    return GestureDetector(
      onTap: () => _checkAnswer(index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 4 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 3,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  option['emoji']!,
                  style: const TextStyle(fontSize: 60),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              flex: 1,
              child: Text(
                _isHebrew ? option['nameHe']! : option['nameEn']!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected && _isCorrect!)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Icon(Icons.check_circle, color: Colors.green, size: 32),
              ),
            if (isSelected && !_isCorrect!)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Icon(Icons.cancel, color: Colors.red, size: 32),
              ),
          ],
        ),
      ),
    );
  }
}
