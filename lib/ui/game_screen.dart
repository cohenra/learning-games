import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../games/floating_balloons_game.dart';

class GameScreen extends StatefulWidget {
  // We can switch this to FloatingBalloonsGame
  final FloatingBalloonsGame? game;

  // Or we can just create it inside if not passed, but usually it is passed or created here.
  // The original code passed TapColorsGame. We will adapt.

  const GameScreen({super.key, this.game});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _muted = false;
  late FloatingBalloonsGame _gameInstance;

  @override
  void initState() {
    super.initState();
    _gameInstance = widget.game ?? FloatingBalloonsGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB), // Sky blue background
      body: SafeArea(
        child: Stack(
          children: [
            // The Game
            Positioned.fill(
              child: GameWidget(game: _gameInstance),
            ),

            // Replay Instruction Button (Top Right)
            Positioned(
              top: 10,
              right: 10,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.85),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () async {
                  HapticFeedback.selectionClick();
                  await _gameInstance.replayInstruction();
                },
                icon: const Icon(Icons.record_voice_over),
                label: const Text(
                  'השמע שוב',
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),

            // Mute Button (Top Left)
            Positioned(
              top: 10,
              left: 10,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.85),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _muted = !_muted;
                    _gameInstance.toggleSound();
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
