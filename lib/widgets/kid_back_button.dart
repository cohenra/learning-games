import 'package:flutter/material.dart';

/// כפתור חזרה ידידותי לילדים - גדול, צבעוני ונראה יותר כמו כפתור
class KidBackButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final bool isHebrew;

  const KidBackButton({
    super.key,
    this.onPressed,
    this.color,
    this.isHebrew = true,
  });

  @override
  State<KidBackButton> createState() => _KidBackButtonState();
}

class _KidBackButtonState extends State<KidBackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? Colors.blue.shade400;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                buttonColor,
                buttonColor.withOpacity(0.7),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: buttonColor.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
          child: Center(
            child: Icon(
              widget.isHebrew ? Icons.arrow_forward : Icons.arrow_back,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
      ),
    );
  }
}
