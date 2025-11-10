import 'package:flutter/material.dart';
import '../models/maze_cell.dart';

/// כפתור כיוון עם אנימציות
class DirectionButton extends StatefulWidget {
  final Direction direction;
  final bool isEnabled;
  final bool isLocked;
  final VoidCallback? onPressed;
  final String? label;

  const DirectionButton({
    super.key,
    required this.direction,
    this.isEnabled = true,
    this.isLocked = false,
    this.onPressed,
    this.label,
  });

  @override
  State<DirectionButton> createState() => _DirectionButtonState();
}

class _DirectionButtonState extends State<DirectionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  IconData _getIcon() {
    switch (widget.direction) {
      case Direction.up:
        return Icons.arrow_upward;
      case Direction.down:
        return Icons.arrow_downward;
      case Direction.left:
        return Icons.arrow_back;
      case Direction.right:
        return Icons.arrow_forward;
    }
  }

  Color _getColor() {
    if (!widget.isEnabled) {
      return Colors.grey[400]!;
    } else if (widget.isLocked) {
      return Colors.red[400]!;
    } else {
      return Colors.blue[600]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.isEnabled) {
          setState(() => _isPressed = true);
        }
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      onTap: widget.isEnabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isEnabled && !widget.isLocked
                ? _scaleAnimation.value
                : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              transform: Matrix4.identity()
                ..scale(_isPressed ? 0.9 : 1.0),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isEnabled
                        ? [
                            _getColor().withOpacity(0.8),
                            _getColor(),
                          ]
                        : [
                            Colors.grey[300]!,
                            Colors.grey[400]!,
                          ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _getColor().withOpacity(0.3),
                      blurRadius: _isPressed ? 5 : 10,
                      spreadRadius: _isPressed ? 1 : 3,
                      offset: Offset(0, _isPressed ? 2 : 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // אייקון ראשי
                    Icon(
                      _getIcon(),
                      size: 36,
                      color: Colors.white,
                    ),
                    // נעילה
                    if (widget.isLocked)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red[700],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    // תווית
                    if (widget.label != null && widget.label!.isNotEmpty)
                      Positioned(
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.label!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
