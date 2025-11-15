import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/kid_button.dart';
import '../../../widgets/kid_back_button.dart';

/// משחק חלוקת ממתקים - למד חילוק באופן אינטראקטיבי
class ShareTreatsGame extends StatefulWidget {
  const ShareTreatsGame({super.key});

  @override
  State<ShareTreatsGame> createState() => _ShareTreatsGameState();
}

class _ShareTreatsGameState extends State<ShareTreatsGame> {
  final FlutterTts _flutterTts = FlutterTts();
  final Random _random = Random();
  bool _isHebrew = true;

  int? _totalTreats;
  int? _numKids;
  int? _correctAnswer;
  List<int> _treatsPerKid = [];
  bool _showQuestion = false;
  int? _selectedAnswer;
  bool? _isCorrect;
  int _score = 0;
  int _round = 1;
  final int _totalRounds = 5;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isHebrew = Localizations.localeOf(context).languageCode == 'he';
      });
      _startNewRound();
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage(_isHebrew ? 'he-IL' : 'en-US');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _startNewRound() {
    // Generate division problem
    final divisors = [2, 3, 4, 5];
    final numKids = divisors[_random.nextInt(divisors.length)];
    final treatsPerKid = _random.nextInt(5) + 2; // 2-6 treats per kid
    final totalTreats = numKids * treatsPerKid;

    setState(() {
      _totalTreats = totalTreats;
      _numKids = numKids;
      _correctAnswer = treatsPerKid;
      _treatsPerKid = List.filled(numKids, 0);
      _showQuestion = false;
      _selectedAnswer = null;
      _isCorrect = null;
    });

    // Speak the task
    _speak(_isHebrew
        ? 'חלק $_totalTreats ממתקים באופן שווה בין $_numKids ילדים'
        : 'Share $_totalTreats treats equally among $_numKids children');
  }

  void _addTreat(int kidIndex) {
    final totalDistributed = _treatsPerKid.reduce((a, b) => a + b);
    if (totalDistributed < _totalTreats!) {
      setState(() {
        _treatsPerKid[kidIndex]++;
      });
    }
  }

  void _removeTreat(int kidIndex) {
    if (_treatsPerKid[kidIndex] > 0) {
      setState(() {
        _treatsPerKid[kidIndex]--;
      });
    }
  }

  void _checkDistribution() {
    final totalDistributed = _treatsPerKid.reduce((a, b) => a + b);

    if (totalDistributed < _totalTreats!) {
      _showSnackBar(
        _isHebrew
            ? 'עוד לא חילקת את כל הממתקים! נשארו ${_totalTreats! - totalDistributed}'
            : 'You haven\'t shared all treats! ${_totalTreats! - totalDistributed} left',
        Colors.orange,
      );
      return;
    }

    if (totalDistributed > _totalTreats!) {
      _showSnackBar(
        _isHebrew
            ? 'חילקת יותר מדי! יש רק $_totalTreats ממתקים'
            : 'Too many treats! There are only $_totalTreats treats',
        Colors.red,
      );
      return;
    }

    // Check if distribution is equal
    final allEqual = _treatsPerKid.every((count) => count == _treatsPerKid[0]);
    if (!allEqual) {
      _showSnackBar(
        _isHebrew
            ? 'החלוקה לא שווה! כל ילד צריך לקבל אותו מספר'
            : 'Not equal! Each child should get the same amount',
        Colors.red,
      );
      return;
    }

    // Correct distribution!
    _showQuestionDialog();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showQuestionDialog() {
    final options = _generateOptions(_correctAnswer!);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.orange.shade50, Colors.pink.shade50],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Question
                  Text(
                    _isHebrew
                        ? 'כמה ממתקים קיבל כל ילד?'
                        : 'How many treats did each child get?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Answer options in 2x2 grid
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3.0,
                    children: options.map((option) {
                      final isSelected = _selectedAnswer == option;
                      final showResult = _isCorrect != null && isSelected;

                      return GestureDetector(
                        onTap: _isCorrect == null
                            ? () {
                                setDialogState(() {
                                  _selectedAnswer = option;
                                  _isCorrect = option == _correctAnswer;
                                });

                                if (_isCorrect!) {
                                  _speak(_isHebrew ? 'כל הכבוד!' : 'Great job!');
                                } else {
                                  _speak(_isHebrew ? 'נסה שוב' : 'Try again');
                                }

                                Future.delayed(const Duration(milliseconds: 800), () {
                                  if (_isCorrect!) {
                                    Navigator.pop(context);
                                    setState(() {
                                      _score++;
                                      if (_round < _totalRounds) {
                                        _round++;
                                        _startNewRound();
                                      } else {
                                        _showFinalScore();
                                      }
                                    });
                                  } else {
                                    setDialogState(() {
                                      _selectedAnswer = null;
                                      _isCorrect = null;
                                    });
                                  }
                                });
                              }
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: showResult
                                  ? (_isCorrect!
                                      ? [Colors.green.shade400, Colors.green.shade600]
                                      : [Colors.red.shade400, Colors.red.shade600])
                                  : [Colors.blue.shade300, Colors.blue.shade500],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                option.toString(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<int> _generateOptions(int correct) {
    final options = <int>{correct};
    while (options.length < 4) {
      final offset = _random.nextInt(5) - 2;
      final option = (correct + offset).clamp(1, 20);
      options.add(option);
    }
    final list = options.toList()..shuffle();
    return list;
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
              _isHebrew ? 'סיימת את המשחק!' : 'You finished the game!',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              _isHebrew ? 'תשובות נכונות:' : 'Correct answers:',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              '$_score / $_totalRounds',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _isHebrew
                  ? 'ציון: ${((_score / _totalRounds) * 100).round()}%'
                  : 'Score: ${((_score / _totalRounds) * 100).round()}%',
              style: TextStyle(
                fontSize: 24,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              _isHebrew ? 'יציאה' : 'Exit',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _score = 0;
                _round = 1;
                _startNewRound();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
            ),
            child: Text(
              _isHebrew ? 'שחק שוב' : 'Play Again',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    _isHebrew = Localizations.localeOf(context).languageCode == 'he';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange.shade50, Colors.pink.shade50],
          ),
        ),
        child: SafeArea(
          child: _totalTreats == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildHeader(responsive),
                    SizedBox(height: responsive.spacing(12)),
                    _buildTask(responsive),
                    SizedBox(height: responsive.spacing(12)),
                    Expanded(child: _buildKidsArea(responsive)),
                    _buildControls(responsive),
                    SizedBox(height: responsive.spacing(12)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          KidBackButton(
            onPressed: () => Navigator.pop(context),
            color: Colors.orange.shade600,
            isHebrew: _isHebrew,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  responsive,
                  icon: '🎯',
                  value: '$_round/$_totalRounds',
                  label: _isHebrew ? 'סיבוב' : 'Round',
                ),
                _buildStatCard(
                  responsive,
                  icon: '⭐',
                  value: '$_score',
                  label: _isHebrew ? 'נכונות' : 'Score',
                ),
              ],
            ),
          ),
          SizedBox(width: responsive.spacing(48)),
        ],
      ),
    );
  }

  Widget _buildStatCard(ResponsiveHelper responsive,
      {required String icon, required String value, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing(12),
        vertical: responsive.spacing(6),
      ),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: TextStyle(fontSize: responsive.iconSize(20))),
          SizedBox(width: responsive.spacing(6)),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: responsive.fontSize(16),
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: responsive.fontSize(10),
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTask(ResponsiveHelper responsive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
      padding: EdgeInsets.all(responsive.spacing(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade300, width: 2),
      ),
      child: Column(
        children: [
          Text(
            _isHebrew
                ? 'חלק $_totalTreats ממתקים באופן שווה:'
                : 'Share $_totalTreats treats equally:',
            style: TextStyle(
              fontSize: responsive.fontSize(18),
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.spacing(8)),
          // Show remaining treats
          Wrap(
            spacing: 4,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: List.generate(
              _totalTreats!,
              (index) => Text('🍪', style: TextStyle(fontSize: responsive.iconSize(20))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKidsArea(ResponsiveHelper responsive) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          _numKids!,
          (index) => Expanded(
            child: _buildKidPlate(responsive, index),
          ),
        ),
      ),
    );
  }

  Widget _buildKidPlate(ResponsiveHelper responsive, int kidIndex) {
    final treats = _treatsPerKid[kidIndex];

    return Container(
      margin: EdgeInsets.all(responsive.spacing(4)),
      padding: EdgeInsets.all(responsive.spacing(8)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Kid emoji
          Text('🧒', style: TextStyle(fontSize: responsive.iconSize(30))),
          SizedBox(height: responsive.spacing(4)),

          // Plate with treats
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: Center(
              child: Wrap(
                spacing: 2,
                runSpacing: 2,
                alignment: WrapAlignment.center,
                children: List.generate(
                  treats,
                  (index) => Text('🍪', style: TextStyle(fontSize: responsive.iconSize(18))),
                ),
              ),
            ),
          ),
          SizedBox(height: responsive.spacing(4)),

          // Add/Remove buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () => _removeTreat(kidIndex),
                icon: const Icon(Icons.remove_circle),
                color: Colors.red.shade400,
                iconSize: 24,
              ),
              IconButton(
                onPressed: () => _addTreat(kidIndex),
                icon: const Icon(Icons.add_circle),
                color: Colors.blue.shade400,
                iconSize: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls(ResponsiveHelper responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
      child: KidButton(
        text: _isHebrew ? 'בדוק חלוקה ✓' : 'Check Division ✓',
        icon: Icons.check_circle,
        onPressed: _checkDistribution,
        color: Colors.green.shade600,
        height: 60,
      ),
    );
  }
}
