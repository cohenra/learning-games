import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/progress_provider.dart';
import '../ui/game_screen.dart';
import '../games/tap_colors_game.dart';
import '../games/quiz_letters_game.dart';
import '../games/learn_letters_game.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // רקע בז' חמים
      appBar: AppBar(
        title: const Text(
          'לומדים בכיף 🎮',
          style: TextStyle(fontWeight: FontWeight.bold),
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 4,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // כותרת ברוכים הבאים
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.purple, Colors.blue],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '🌟',
                      style: TextStyle(fontSize: 40),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'ברוכים הבאים!',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '🌟',
                      style: TextStyle(fontSize: 40),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // מונה מטבעות
              Consumer<ProgressProvider>(
                builder: (context, progress, _) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.amber, width: 3),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '🪙',
                        style: TextStyle(fontSize: 28),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'מטבעות: ${progress.coins}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ===== מודול אותיות =====
              _buildSectionTitle(context, 'אותיות עבריות 🔤'),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildGameCard(
                      context,
                      title: 'לומדים אותיות',
                      subtitle: 'הכירו את האותיות',
                      icon: Icons.abc,
                      colors: [Colors.red, Colors.orange],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LearnLettersGame(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildGameCard(
                      context,
                      title: 'חידון אותיות',
                      subtitle: 'מצא את האות הנכונה',
                      icon: Icons.quiz,
                      colors: [Colors.purple, Colors.pink],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GameScreen(game: QuizLettersGame()),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ===== מודול צבעים =====
              _buildSectionTitle(context, 'צבעים 🎨'),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildGameCard(
                      context,
                      title: 'חידון צבעים',
                      subtitle: 'מצא את הצבע הנכון',
                      icon: Icons.color_lens,
                      colors: [Colors.blue, Colors.cyan],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GameScreen(game: TapColorsGame()),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildGameCard(
                      context,
                      title: 'בקרוב...',
                      subtitle: 'משחקי צבעים נוספים',
                      icon: Icons.lock,
                      colors: [Colors.grey, Colors.grey],
                      onTap: null, // נעול
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ===== מודול מספרים (נעול) =====
              _buildSectionTitle(context, 'מספרים 🔢'),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildGameCard(
                      context,
                      title: 'בקרוב...',
                      subtitle: 'משחקי מספרים',
                      icon: Icons.lock,
                      colors: [Colors.grey, Colors.grey],
                      onTap: null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildGameCard(
                      context,
                      title: 'בקרוב...',
                      subtitle: 'חידון מספרים',
                      icon: Icons.lock,
                      colors: [Colors.grey, Colors.grey],
                      onTap: null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ===== מודול צורות (נעול) =====
              _buildSectionTitle(context, 'צורות 🔷'),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildGameCard(
                      context,
                      title: 'בקרוב...',
                      subtitle: 'משחקי צורות',
                      icon: Icons.lock,
                      colors: [Colors.grey, Colors.grey],
                      onTap: null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildGameCard(
                      context,
                      title: 'בקרוב...',
                      subtitle: 'חידון צורות',
                      icon: Icons.lock,
                      colors: [Colors.grey, Colors.grey],
                      onTap: null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback? onTap,
  }) {
    final isLocked = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // אייקון רקע גדול
            Positioned(
              bottom: -10,
              right: -10,
              child: Opacity(
                opacity: 0.2,
                child: Icon(
                  icon,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            ),

            // תוכן הכרטיס
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    size: 40,
                    color: Colors.white,
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),

            // אייקון נעילה
            if (isLocked)
              const Center(
                child: Icon(
                  Icons.lock,
                  size: 50,
                  color: Colors.white70,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
