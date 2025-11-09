import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/kid_button.dart';
import '../../widgets/kid_back_button.dart';
import '../../widgets/reward_animation.dart';
import '../../utils/responsive_helper.dart';

/// מסך חידון בעלי חיים - שאלות אקראיות עם בחירה מרובה
class AnimalsQuizScreen extends StatefulWidget {
  const AnimalsQuizScreen({super.key});

  @override
  State<AnimalsQuizScreen> createState() => _AnimalsQuizScreenState();
}

class _AnimalsQuizScreenState extends State<AnimalsQuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;
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
        _correctAnswers++;
        _showReward = true;
      }
    });

    final appProvider = context.read<AppProvider>();
    if (_isCorrect!) {
      appProvider.speak(_isHebrew ? 'מצוין!' : 'Excellent!');
    } else {
      appProvider.speak(_isHebrew ? 'לא נכון, נסה שוב' : 'Wrong, try again');
    }

    // המשך לשאלה הבאה אחרי עיכוב (ללא הגבלה)
    if (_isCorrect!) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _currentQuestionIndex++;
          });
          _generateQuestion();
        }
      });
    }
  }

  void _showFinalScore() {
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
              _isHebrew ? 'תשובות נכונות:' : 'Correct answers:',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              '$_correctAnswers',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _isHebrew ? 'כוכבים:' : 'Stars:',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              '⭐ $_score',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(_isHebrew ? 'חזרה לתפריט' : 'Back to Menu'),
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
        leading: KidBackButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.green.shade600,
          isHebrew: _isHebrew,
        ),
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
                          _isHebrew ? 'שאלה ${_currentQuestionIndex + 1}' : 'Question ${_currentQuestionIndex + 1}',
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

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: KidButton(
                              text: _isHebrew ? 'שמע שוב 🔊' : 'Hear Again 🔊',
                              icon: Icons.volume_up,
                              onPressed: _speakQuestion,
                              color: Colors.blue,
                              height: 60,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: KidButton(
                              text: _isHebrew ? 'סיום 🏁' : 'Finish 🏁',
                              icon: Icons.check_circle,
                              onPressed: _showFinalScore,
                              color: Colors.red,
                              height: 60,
                            ),
                          ),
                        ),
                      ],
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
