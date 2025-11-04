import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/base_quiz_game.dart';

class GameScreen extends StatefulWidget {
  final BaseQuizGame game;
  const GameScreen({super.key, required this.game});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _muted = false;

  @override
  Widget build(BuildContext context) {
    final game = widget.game;

    return Scaffold(
      backgroundColor: const Color(0xFF0FA3B1),
      body: SafeArea(
        child: Stack(
          children: [
            // המשחק עצמו
            Positioned.fill(
              child: GameWidget(game: game),
            ),

            // כפתור השמעת ההנחיה (ימין-עליון)
            Positioned(
              top: 10,
              right: 10,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.85),
                  foregroundColor: Colors.black87,
                ),
                onPressed: () async {
                  HapticFeedback.selectionClick();
                  await game.replayInstruction();
                },
                icon: const Icon(Icons.record_voice_over),
                label: const Text(
                  'השמע שוב',
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),

            // כפתור השתקה (שמאל-עליון)
            Positioned(
              top: 10,
              left: 10,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.85),
                  foregroundColor: Colors.black87,
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _muted = !_muted;
                    game.toggleSound();
                  });
                },
                icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
                label: Text(
                  _muted ? 'מושתק' : 'סאונד פועל',
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
