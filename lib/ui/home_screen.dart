import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/progress_provider.dart';
import '../ui/game_screen.dart';
import '../games/tap_colors_game.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('לומדים בכיף'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ברוכים הבאים!', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GameScreen(game: TapColorsGame())),
                );
              },
              child: const Text('משחק צבעים'),
            ),
            const SizedBox(height: 20),
            Consumer<ProgressProvider>(
              builder: (context, progress, _) => Text('מטבעות: ${progress.coins}'),
            ),
          ],
        ),
      ),
    );
  }
}
