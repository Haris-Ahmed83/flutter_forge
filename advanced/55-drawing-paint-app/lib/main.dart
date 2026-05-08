import 'package:flutter/material.dart';
import 'dart:ui' as ui; // For ImageByteFormat and to avoid name collision with Path

/// Main entry point of the application.
void main() {
  runApp(const MyApp());
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Drawing Paint',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DrawingScreen(),
    );
  }
}

/// Represents a single drawing stroke, including its path, color, and stroke width.
class DrawingPoint {
  final Path path;
  final Color color;
  final double strokeWidth;

  DrawingPoint({required this.path, required this.color, required this.strokeWidth});
}

/// The main screen for drawing.
class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  // List to store all completed drawing points (strokes).
  final List<DrawingPoint> _drawingPoints = [];
  // The current point being drawn by the user. It's null if no drawing is in progress.
  DrawingPoint? _currentDrawingPoint;

  Color _selectedColor = Colors.black;
  double _strokeWidth = 5.0;

  // Predefined color palette for the user to choose from.
  final List<Color> _colors = [
    Colors.black,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.brown,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Drawing App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Expanded widget ensures the drawing canvas takes up available space.
          Expanded(
            child: GestureDetector(
              // Called when the user starts touching the screen.
              onPanStart: (details) {
                setState(() {
                  // Create a new path and move its starting point to the touch location.
                  Path path = Path();
                  path.moveTo(details.localPosition.dx, details.localPosition.dy);
                  _currentDrawingPoint = DrawingPoint(
                    path: path,
                    color: _selectedColor,
                    strokeWidth: _strokeWidth,
                  );
                });
              },
              // Called when the user moves their finger across the screen.
              onPanUpdate: (details) {
                setState(() {
                  if (_currentDrawingPoint != null) {
                    // Add a line segment to the current path, extending it to the new touch location.
                    _currentDrawingPoint!.path.lineTo(details.localPosition.dx, details.localPosition.dy);
                  }
                });
              },
              // Called when the user lifts their finger from the screen.
              onPanEnd: (details) {
                setState(() {
                  if (_currentDrawingPoint != null) {
                    // Add the completed current drawing point to the list of drawing points.
                    _drawingPoints.add(_currentDrawingPoint!);
                    _currentDrawingPoint = null; // Clear the current drawing point.
                  }
                });
              },
              child: CustomPaint(
                // The CustomPaint widget takes a CustomPainter to draw on the canvas.
                painter: DrawingPainter(
                  drawingPoints: _drawingPoints,
                  currentDrawingPoint: _currentDrawingPoint,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints.expand(),
                ),
              ),
            ),
          ),
          // Control panel for brush size, colors, undo, and clear.
          _buildControlPanel(),
        ],
      ),
    );
  }

  /// Builds the control panel at the bottom of the screen.
  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Color palette selection.
          _buildColorPalette(),
          const SizedBox(height: 16),
          // Brush size slider.
          _buildBrushSizeSlider(),
          const SizedBox(height: 16),
          // Undo and Clear buttons.
          _buildActionButtons(),
        ],
      ),
    );
  }

  /// Builds the horizontal color palette.
  Widget _buildColorPalette() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _colors.map((color) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: _selectedColor == color ? Theme.of(context).colorScheme.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Builds the brush size slider.
  Widget _buildBrushSizeSlider() {
    return Row(
      children: [
        Icon(Icons.brush, color: Theme.of(context).colorScheme.onSurfaceVariant),
        Expanded(
          child: Slider(
            value: _strokeWidth,
            min: 1.0,
            max: 20.0,
            divisions: 19, // 19 divisions for values from 1 to 20
            label: _strokeWidth.round().toString(),
            onChanged: (value) {
              setState(() {
                _strokeWidth = value;
              });
            },
            activeColor: Theme.of(context).colorScheme.primary,
            inactiveColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
        ),
        Text(
          _strokeWidth.round().toString(),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  /// Builds the Undo and Clear All buttons.
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                if (_drawingPoints.isNotEmpty) {
                  _drawingPoints.removeLast(); // Remove the last drawn stroke.
                }
              });
            },
            icon: const Icon(Icons.undo),
            label: const Text('Undo'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _drawingPoints.clear(); // Clear all drawing strokes.
                _currentDrawingPoint = null;
              });
            },
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear All'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }
}

/// CustomPainter implementation for drawing paths on the canvas.
class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> drawingPoints;
  final DrawingPoint? currentDrawingPoint;

  DrawingPainter({required this.drawingPoints, this.currentDrawingPoint});

  @override
  void paint(Canvas canvas, Size size) {
    // Create a Paint object for drawing, configured for strokes.
    Paint paint = Paint()
      ..style = PaintingStyle.stroke // Draw outlines, not filled shapes.
      ..strokeCap = StrokeCap.round // Round caps for line ends.
      ..strokeJoin = StrokeJoin.round; // Round joins for line corners.

    // Draw all previously completed drawing points (strokes).
    for (var drawingPoint in drawingPoints) {
      paint.color = drawingPoint.color;
      paint.strokeWidth = drawingPoint.strokeWidth;
      canvas.drawPath(drawingPoint.path, paint);
    }

    // Draw the currently active drawing point (if any).
    // This allows the user to see the line being drawn in real-time.
    if (currentDrawingPoint != null) {
      paint.color = currentDrawingPoint!.color;
      paint.strokeWidth = currentDrawingPoint!.strokeWidth;
      canvas.drawPath(currentDrawingPoint!.path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    // Repaint only if the list of drawing points or the current drawing point has changed.
    return oldDelegate.drawingPoints.length != drawingPoints.length ||
        oldDelegate.currentDrawingPoint != currentDrawingPoint;
  }
}
