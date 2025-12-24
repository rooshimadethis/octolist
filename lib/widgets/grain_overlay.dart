import 'dart:math';
import 'package:flutter/material.dart';

class GrainOverlay extends StatelessWidget {
  final double opacity;
  final Color color;

  const GrainOverlay({
    super.key,
    required this.opacity,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    if (opacity <= 0.01) return const SizedBox.shrink();

    // Wrap in RepaintBoundary to isolate repaints and improve performance
    return RepaintBoundary(
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: CustomPaint(
            painter: _GrainPainter(color: color),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  final Color color;

  _GrainPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42); // Fixed seed for consistent grain pattern

    // Create a more film-like grain with varying sizes and opacity
    // Use multiple layers with different densities for a smoother look

    // Layer 1: Fine grain (small, dense)
    _drawGrainLayer(
      canvas,
      size,
      random,
      density: 0.008, // Reduced density
      minSize: 0.5,
      maxSize: 1.0,
      baseOpacity: 0.15,
    );

    // Layer 2: Medium grain
    _drawGrainLayer(
      canvas,
      size,
      random,
      density: 0.004,
      minSize: 1.0,
      maxSize: 1.5,
      baseOpacity: 0.10,
    );

    // Layer 3: Coarse grain (larger, sparser)
    _drawGrainLayer(
      canvas,
      size,
      random,
      density: 0.002,
      minSize: 1.5,
      maxSize: 2.5,
      baseOpacity: 0.08,
    );
  }

  void _drawGrainLayer(
    Canvas canvas,
    Size size,
    Random random, {
    required double density,
    required double minSize,
    required double maxSize,
    required double baseOpacity,
  }) {
    // Reduced max count from 3000 to 1500 for better performance
    final count = (size.width * size.height * density).toInt().clamp(0, 1500);

    // Pre-allocate paint object to avoid repeated allocations
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final grainSize = minSize + random.nextDouble() * (maxSize - minSize);
      final opacity = baseOpacity * (0.5 + random.nextDouble() * 0.5);

      // Reuse paint object and only update color
      paint.color = color.withValues(alpha: opacity);

      // Draw small circles instead of points for smoother grain
      canvas.drawCircle(Offset(x, y), grainSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
