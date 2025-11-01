import 'dart:math';
import 'package:flutter/material.dart';

/// אנימציית פרס עם קונפטי וכוכבים
class RewardAnimation extends StatefulWidget {
  final VoidCallback? onComplete;

  const RewardAnimation({super.key, this.onComplete});

  @override
  State<RewardAnimation> createState() => _RewardAnimationState();
}

class _RewardAnimationState extends State<RewardAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _particlesController;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // אנימציה מרכזית
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // אנימציית חלקיקים
    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // צור חלקיקים
    for (int i = 0; i < 30; i++) {
      _particles.add(Particle(
        emoji: _getRandomEmoji(),
        startX: 0,
        startY: 0,
        endX: (_random.nextDouble() - 0.5) * 400,
        endY: -_random.nextDouble() * 300,
        rotation: _random.nextDouble() * 2 * pi,
      ));
    }

    _controller.forward();
    _particlesController.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  String _getRandomEmoji() {
    final emojis = ['⭐', '✨', '🌟', '💫', '🎉', '🎊', '👏', '💯'];
    return emojis[_random.nextInt(emojis.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // טקסט מרכזי
        Center(
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
              curve: Curves.elasticOut,
            ),
            child: const Text(
              '🎉',
              style: TextStyle(fontSize: 120),
            ),
          ),
        ),

        // חלקיקים
        ...List.generate(_particles.length, (index) {
          return AnimatedBuilder(
            animation: _particlesController,
            builder: (context, child) {
              final particle = _particles[index];
              final progress = _particlesController.value;

              final x = particle.startX + (particle.endX * progress);
              final y = particle.startY + (particle.endY * progress);
              final opacity = 1 - progress;

              return Positioned(
                left: MediaQuery.of(context).size.width / 2 + x,
                top: MediaQuery.of(context).size.height / 2 + y,
                child: Transform.rotate(
                  angle: particle.rotation * progress,
                  child: Opacity(
                    opacity: opacity,
                    child: Text(
                      particle.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}

class Particle {
  final String emoji;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double rotation;

  Particle({
    required this.emoji,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.rotation,
  });
}
