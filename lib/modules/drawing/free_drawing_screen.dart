import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../utils/responsive_helper.dart';

/// מסך ציור חופשי
class FreeDrawingScreen extends StatefulWidget {
  const FreeDrawingScreen({super.key});

  @override
  State<FreeDrawingScreen> createState() => _FreeDrawingScreenState();
}

class _FreeDrawingScreenState extends State<FreeDrawingScreen> {
  List<DrawingPoint> drawingPoints = [];
  Color selectedColor = Colors.red;
  double strokeWidth = 5.0;
  bool _isHebrew = true;
  int? _activePointerId; // Track the active finger for single-touch drawing

  final List<Color> colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.black,
    Colors.white,
  ];

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    _isHebrew = Localizations.localeOf(context).languageCode == 'he';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.pink.shade50,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(responsive.spacing(12)),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isHebrew ? Icons.arrow_forward : Icons.arrow_back,
                        color: Colors.pink.shade700,
                        size: 32,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        _isHebrew ? 'ציור חופשי' : 'Free Drawing',
                        style: TextStyle(
                          fontSize: responsive.titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 32),
                      color: Colors.red,
                      onPressed: () {
                        setState(() {
                          drawingPoints.clear();
                          _activePointerId = null;
                        });
                      },
                      tooltip: _isHebrew ? 'נקה הכל' : 'Clear All',
                    ),
                  ],
                ),
              ),

              // Color Palette
              Container(
                height: 60,
                margin: EdgeInsets.symmetric(horizontal: responsive.spacing(12)),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: colors.length,
                  itemBuilder: (context, index) {
                    final color = colors[index];
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.grey,
                            width: isSelected ? 4 : 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : [],
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: responsive.spacing(12)),

              // Brush Size Slider
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                child: Row(
                  children: [
                    Icon(Icons.brush, size: 16, color: Colors.grey.shade700),
                    Expanded(
                      child: Slider(
                        value: strokeWidth,
                        min: 2.0,
                        max: 20.0,
                        activeColor: Colors.pink,
                        onChanged: (value) {
                          setState(() {
                            strokeWidth = value;
                          });
                        },
                      ),
                    ),
                    Icon(Icons.brush, size: 32, color: Colors.grey.shade700),
                  ],
                ),
              ),

              SizedBox(height: responsive.spacing(8)),

              // Drawing Canvas
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(responsive.spacing(12)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Listener(
                      onPointerDown: (details) {
                        // Only start drawing if no finger is currently active
                        if (_activePointerId == null) {
                          setState(() {
                            _activePointerId = details.pointer;
                            drawingPoints.add(
                              DrawingPoint(
                                details.localPosition,
                                Paint()
                                  ..color = selectedColor
                                  ..strokeWidth = strokeWidth
                                  ..strokeCap = StrokeCap.round,
                              ),
                            );
                          });
                        }
                      },
                      onPointerMove: (details) {
                        // Only draw if this is the active finger
                        if (_activePointerId == details.pointer) {
                          setState(() {
                            drawingPoints.add(
                              DrawingPoint(
                                details.localPosition,
                                Paint()
                                  ..color = selectedColor
                                  ..strokeWidth = strokeWidth
                                  ..strokeCap = StrokeCap.round,
                              ),
                            );
                          });
                        }
                      },
                      onPointerUp: (details) {
                        // Only end drawing if this is the active finger
                        if (_activePointerId == details.pointer) {
                          setState(() {
                            drawingPoints.add(DrawingPoint(null, Paint()));
                            _activePointerId = null;
                          });
                        }
                      },
                      child: CustomPaint(
                        painter: DrawingPainter(drawingPoints),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: responsive.spacing(12)),
            ],
          ),
        ),
      ),
    );
  }
}

class DrawingPoint {
  Offset? offset;
  Paint paint;

  DrawingPoint(this.offset, this.paint);
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> drawingPoints;

  DrawingPainter(this.drawingPoints);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < drawingPoints.length - 1; i++) {
      if (drawingPoints[i].offset != null && drawingPoints[i + 1].offset != null) {
        canvas.drawLine(
          drawingPoints[i].offset!,
          drawingPoints[i + 1].offset!,
          drawingPoints[i].paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
