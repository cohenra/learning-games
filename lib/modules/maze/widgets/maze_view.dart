import 'package:flutter/material.dart';
import '../models/maze_cell.dart';
import '../models/maze_grid.dart';
import '../models/player_state.dart';
import 'player_avatar.dart';

/// ווידג'ט הצגת המבוך עם אנימציות
class MazeView extends StatefulWidget {
  final MazeGrid maze;
  final PlayerState playerState;
  final double cellSize;
  final VoidCallback? onGoalReached;

  const MazeView({
    super.key,
    required this.maze,
    required this.playerState,
    this.cellSize = 50,
    this.onGoalReached,
  });

  @override
  State<MazeView> createState() => _MazeViewState();
}

class _MazeViewState extends State<MazeView>
    with SingleTickerProviderStateMixin {
  late AnimationController _moveController;
  Position? _animationStart;
  Position? _animationEnd;

  @override
  void initState() {
    super.initState();
    _moveController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    widget.playerState.addListener(_onPlayerStateChanged);
  }

  @override
  void dispose() {
    _moveController.dispose();
    widget.playerState.removeListener(_onPlayerStateChanged);
    super.dispose();
  }

  void _onPlayerStateChanged() {
    if (widget.playerState.isMoving) {
      setState(() {
        _animationStart = _animationEnd ?? widget.playerState.currentPosition;
        _animationEnd = widget.playerState.currentPosition;
      });
      _moveController.forward(from: 0.0);

      // בדוק אם הגענו ליעד
      if (widget.playerState.currentPosition == widget.maze.goalPosition) {
        Future.delayed(const Duration(milliseconds: 500), () {
          widget.onGoalReached?.call();
        });
      }
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalWidth = widget.maze.cols * widget.cellSize;
    final totalHeight = widget.maze.rows * widget.cellSize;

    return Container(
      width: totalWidth,
      height: totalHeight,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[400]!, width: 3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // רקע המבוך
            _buildMazeBackground(),

            // רשת המבוך
            _buildMazeGrid(),

            // השחקן המונפש
            AnimatedBuilder(
              animation: _moveController,
              builder: (context, child) {
                return _buildAnimatedPlayer();
              },
            ),

            // נקודת ההתחלה
            _buildMarker(
              widget.maze.startPosition,
              Icons.play_circle,
              Colors.green,
            ),

            // נקודת היעד
            _buildMarker(
              widget.maze.goalPosition,
              Icons.emoji_events,
              Colors.amber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMazeBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[100]!,
            Colors.grey[200]!,
            Colors.grey[100]!,
          ],
        ),
      ),
    );
  }

  Widget _buildMazeGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.maze.cols,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
      ),
      itemCount: widget.maze.rows * widget.maze.cols,
      itemBuilder: (context, index) {
        final row = index ~/ widget.maze.cols;
        final col = index % widget.maze.cols;
        final position = Position(row, col);
        final cell = widget.maze.getCell(position);

        if (cell == null) return const SizedBox.shrink();

        return _buildCell(cell, position);
      },
    );
  }

  Widget _buildCell(MazeCell cell, Position position) {
    Color cellColor;
    Widget? decoration;

    switch (cell.type) {
      case CellType.wall:
        cellColor = Colors.grey[800]!;
        decoration = _buildWallDecoration();
        break;
      case CellType.path:
        cellColor = Colors.white.withOpacity(0.8);
        break;
      case CellType.junction:
        cellColor = Colors.blue[50]!;
        decoration = _buildJunctionDecoration(position);
        break;
      case CellType.start:
        cellColor = Colors.green[100]!;
        break;
      case CellType.goal:
        cellColor = Colors.amber[100]!;
        break;
    }

    return Container(
      width: widget.cellSize,
      height: widget.cellSize,
      decoration: BoxDecoration(
        color: cellColor,
        border: Border.all(
          color: cell.type == CellType.wall
              ? Colors.grey[900]!
              : Colors.grey[300]!,
          width: 0.5,
        ),
      ),
      child: decoration,
    );
  }

  Widget _buildWallDecoration() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[700]!,
            Colors.grey[800]!,
            Colors.grey[900]!,
          ],
        ),
      ),
      child: CustomPaint(
        painter: BrickWallPainter(),
      ),
    );
  }

  Widget _buildJunctionDecoration(Position position) {
    final junction = widget.maze.junctions[position];
    if (junction == null) return const SizedBox.shrink();

    // הצג נעילות בכיוונים השונים
    return Stack(
      children: [
        // אינדיקטור של צומת
        Center(
          child: Container(
            width: widget.cellSize * 0.4,
            height: widget.cellSize * 0.4,
            decoration: BoxDecoration(
              color: Colors.blue[300]!.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // נעילות בכיוונים
        ...junction.lockedDirections.map((dir) {
          return _buildLockIndicator(dir);
        }),
      ],
    );
  }

  Widget _buildLockIndicator(Direction direction) {
    Alignment alignment;
    switch (direction) {
      case Direction.up:
        alignment = Alignment.topCenter;
        break;
      case Direction.down:
        alignment = Alignment.bottomCenter;
        break;
      case Direction.left:
        alignment = Alignment.centerLeft;
        break;
      case Direction.right:
        alignment = Alignment.centerRight;
        break;
    }

    return Align(
      alignment: alignment,
      child: Icon(
        Icons.lock,
        size: widget.cellSize * 0.25,
        color: Colors.red[400],
      ),
    );
  }

  Widget _buildAnimatedPlayer() {
    final start = _animationStart ?? widget.playerState.currentPosition;
    final end = widget.playerState.currentPosition;

    final startX = start.col * widget.cellSize;
    final startY = start.row * widget.cellSize;
    final endX = end.col * widget.cellSize;
    final endY = end.row * widget.cellSize;

    final currentX = startX + (endX - startX) * _moveController.value;
    final currentY = startY + (endY - startY) * _moveController.value;

    return Positioned(
      left: currentX,
      top: currentY,
      child: Container(
        width: widget.cellSize,
        height: widget.cellSize,
        alignment: Alignment.center,
        child: PlayerAvatar(
          facingDirection: widget.playerState.facingDirection,
          isMoving: widget.playerState.isMoving,
          color: Colors.blue[600]!,
          size: widget.cellSize * 0.7,
        ),
      ),
    );
  }

  Widget _buildMarker(Position position, IconData icon, Color color) {
    return Positioned(
      left: position.col * widget.cellSize,
      top: position.row * widget.cellSize,
      child: Container(
        width: widget.cellSize,
        height: widget.cellSize,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: widget.cellSize * 0.5,
          color: color.withOpacity(0.6),
        ),
      ),
    );
  }
}

/// ציור טקסטורת קיר לבנים
class BrickWallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // קווי לבנים אופקיים
    for (double y = 0; y < size.height; y += size.height / 3) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // קווי לבנים אנכיים (מעוקבים)
    bool offset = false;
    for (double y = 0; y < size.height; y += size.height / 3) {
      for (double x = offset ? size.width / 4 : 0;
          x < size.width;
          x += size.width / 2) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x, y + size.height / 3),
          paint,
        );
      }
      offset = !offset;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
