import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../widgets/kid_back_button.dart';
import 'maze_game_screen.dart';

enum MazeDifficulty {
  easy,
  medium,
  hard,
}

/// מסך תפריט משחק המבוך
class MazeMenuScreen extends StatefulWidget {
  const MazeMenuScreen({super.key});

  @override
  State<MazeMenuScreen> createState() => _MazeMenuScreenState();
}

class _MazeMenuScreenState extends State<MazeMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  MazeDifficulty _selectedDifficulty = MazeDifficulty.easy;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startGame() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MazeGameScreen(
          difficulty: _selectedDifficulty,
        ),
      ),
    );
  }

  int _getMazeSize(MazeDifficulty difficulty) {
    switch (difficulty) {
      case MazeDifficulty.easy:
        return 7; // 7x7 grid
      case MazeDifficulty.medium:
        return 9; // 9x9 grid
      case MazeDifficulty.hard:
        return 11; // 11x11 grid
    }
  }

  int _getJunctionCount(MazeDifficulty difficulty) {
    switch (difficulty) {
      case MazeDifficulty.easy:
        return 3;
      case MazeDifficulty.medium:
        return 5;
      case MazeDifficulty.hard:
        return 8;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isHebrew = l10n.localeName == 'he';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[400]!,
              Colors.purple[400]!,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // כותרת עם כפתור חזרה
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const KidBackButton(),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            l10n.mazeTitle,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: isHebrew ? TextAlign.right : TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // תיאור
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      l10n.mazeDescription,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // בחירת רמת קושי
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.mazeSelectDifficulty,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // כפתורי רמות קושי
                          _buildDifficultyButton(
                            difficulty: MazeDifficulty.easy,
                            label: l10n.mazeEasy,
                            icon: Icons.sentiment_very_satisfied,
                            color: Colors.green,
                          ),

                          const SizedBox(height: 16),

                          _buildDifficultyButton(
                            difficulty: MazeDifficulty.medium,
                            label: l10n.mazeMedium,
                            icon: Icons.sentiment_satisfied,
                            color: Colors.orange,
                          ),

                          const SizedBox(height: 16),

                          _buildDifficultyButton(
                            difficulty: MazeDifficulty.hard,
                            label: l10n.mazeHard,
                            icon: Icons.sentiment_neutral,
                            color: Colors.red,
                          ),

                          const SizedBox(height: 40),

                          // כפתור התחלה
                          ElevatedButton(
                            onPressed: _startGame,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.play_arrow, size: 32),
                                const SizedBox(width: 12),
                                Text(
                                  l10n.mazeStart,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton({
    required MazeDifficulty difficulty,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedDifficulty == difficulty;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedDifficulty = difficulty;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey[400],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_getMazeSize(difficulty)}x${_getMazeSize(difficulty)} • ${_getJunctionCount(difficulty)} צמתים',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 32,
              ),
          ],
        ),
      ),
    );
  }
}
