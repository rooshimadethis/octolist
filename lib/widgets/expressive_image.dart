import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ExpressiveImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Color? skeletonColor;

  const ExpressiveImage({
    super.key,
    this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.skeletonColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildSkeleton();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      alignment: Alignment.center,
      // Fade in from skeleton color instead of white
      fadeInDuration: const Duration(milliseconds: 150),
      fadeInCurve: Curves.easeOut,
      // Show skeleton while loading
      placeholder: (context, url) => _buildSkeleton(),
      // Show skeleton on error
      errorWidget: (context, url, error) => _buildSkeleton(),
      // Aggressive caching (only if width/height are finite values)
      memCacheWidth: (width != null && width!.isFinite)
          ? (width! * 2).toInt()
          : null,
      memCacheHeight: (height != null && height!.isFinite)
          ? (height! * 2).toInt()
          : null,
      maxWidthDiskCache: 1000,
      maxHeightDiskCache: 1000,
    );
  }

  Widget _buildSkeleton({Key? key}) {
    final baseColor = skeletonColor ?? Colors.grey[300]!;
    return Container(
          key: key,
          width: width,
          height: height,
          color: baseColor,
          alignment: Alignment.center,
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.3));
  }
}
