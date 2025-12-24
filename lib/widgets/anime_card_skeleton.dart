import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimeCardSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final bool isHorizontal;

  const AnimeCardSkeleton({
    super.key,
    this.width,
    this.height,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    // Single shimmer effect wrapping the entire card for better performance
    final card = isHorizontal ? _buildHorizontalSkeleton() : _buildVerticalSkeleton();

    return RepaintBoundary(
      child: card
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.5)),
    );
  }

  Widget _buildHorizontalSkeleton() {
    return Container(
      width: width ?? 280,
      height: height ?? 180,
      margin: const EdgeInsets.only(bottom: 12, right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 3, color: Colors.black),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(8, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              border: const Border(
                right: BorderSide(width: 3, color: Colors.black),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextLine(height: 20),
                  const SizedBox(height: 8),
                  _buildTextLine(width: 80, height: 16),
                  const SizedBox(height: 12),
                  _buildTextLine(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalSkeleton() {
    return Container(
      width: width ?? 180,
      height: height ?? 280,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 3, color: Colors.black),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(8, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(color: Colors.grey[300]),
          ),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(width: 3, color: Colors.black)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildTextLine(height: 20)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextLine({double? width, double height = 12}) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      color: Colors.grey[300],
    );
  }
}
