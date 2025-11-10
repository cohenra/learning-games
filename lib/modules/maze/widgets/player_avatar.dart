import 'package:flutter/material.dart';
import '../models/maze_cell.dart';

/// ווידג'ט דמות השחקן המונפשת
class PlayerAvatar extends StatefulWidget {
  final Direction facingDirection;
  final bool isMoving;
  final Color color;
  final double size;

  const PlayerAvatar({
    super.key,
    required this.facingDirection,
    this.isMoving = false,
    this.color = Colors.blue,
    this.size = 40,
  });

  @override
  State<PlayerAvatar> createState() => _PlayerAvatarState();
}

class _PlayerAvatarState extends State<PlayerAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _walkController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _walkController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0.0, end: 4.0).animate(
      CurvedAnimation(parent: _walkController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _walkController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PlayerAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMoving && !oldWidget.isMoving) {
      _walkController.repeat(reverse: true);
    } else if (!widget.isMoving && oldWidget.isMoving) {
      _walkController.stop();
    }
  }

  double _getRotation() {
    switch (widget.facingDirection) {
      case Direction.up:
        return 0;
      case Direction.right:
        return 1.5708; // 90 degrees
      case Direction.down:
        return 3.14159; // 180 degrees
      case Direction.left:
        return -1.5708; // -90 degrees
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _walkController,
      builder: (context, child) {
        return Transform.translate(
          offset: widget.isMoving
              ? Offset(0, -_bounceAnimation.value)
              : Offset.zero,
          child: Transform.rotate(
            angle: _getRotation(),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    widget.color.withOpacity(0.9),
                    widget.color,
                    widget.color.withOpacity(0.7),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // גוף הדמות
                  Icon(
                    Icons.circle,
                    size: widget.size * 0.6,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  // עיניים
                  Positioned(
                    top: widget.size * 0.3,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildEye(),
                        SizedBox(width: widget.size * 0.15),
                        _buildEye(),
                      ],
                    ),
                  ),
                  // פה מחייך
                  Positioned(
                    bottom: widget.size * 0.25,
                    child: Container(
                      width: widget.size * 0.3,
                      height: widget.size * 0.15,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black87,
                            width: 2,
                          ),
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEye() {
    return Container(
      width: widget.size * 0.12,
      height: widget.size * 0.12,
      decoration: const BoxDecoration(
        color: Colors.black87,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: widget.size * 0.06,
          height: widget.size * 0.06,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
