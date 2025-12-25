import 'package:flutter/material.dart';

/// A reusable widget for displaying the OctoList octopus mascot
/// with configurable size, rotation, and positioning.
///
/// The mascot image has padding around it, so negative margins may be needed
/// for precise positioning.
class OctopusMascot extends StatelessWidget {
  /// The size of the octopus (width and height)
  final double size;

  /// Rotation in degrees (positive = clockwise)
  final double rotation;

  /// Optional opacity (0.0 to 1.0)
  final double opacity;

  /// Whether to add a subtle floating animation
  final bool animate;

  const OctopusMascot({
    super.key,
    this.size = 40,
    this.rotation = 0,
    this.opacity = 1.0,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget octopus = Transform.rotate(
      angle: rotation * 3.14159 / 180, // Convert degrees to radians
      child: Opacity(
        opacity: opacity,
        child: Image.asset(
          'assets/mascot/octopus.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );

    // Add floating animation if requested
    if (animate) {
      // Note: Animation would require flutter_animate or AnimatedBuilder
      // For now, return static version
      // TODO: Add subtle floating animation using flutter_animate
    }

    return octopus;
  }
}
