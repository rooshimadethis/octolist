import 'package:flutter/material.dart';

/// A manga-style outlined star icon with a yellow fill
/// Used for displaying ratings and scores throughout the app
class OutlinedStar extends StatelessWidget {
  final double size;
  final Color color;

  const OutlinedStar({super.key, this.size = 18, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Icon(Icons.star, size: size, color: color),
        Icon(Icons.star_border, size: size, color: color),
        Positioned(
          top: 1,
          left: 1,
          bottom: 1,
          right: 1,
          child: Icon(Icons.star, size: size - 2, color: Colors.yellow),
        ),
      ],
    );
  }
}
