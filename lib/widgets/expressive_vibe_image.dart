import 'package:flutter/material.dart';
import '../theme/expressive_theme.dart';
import 'expressive_image.dart';
import 'grain_overlay.dart';

/// A wrapper around [ExpressiveImage] that applies vibe-based filters and grain.
class ExpressiveVibeImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Color? skeletonColor;
  final double vibeScore;

  const ExpressiveVibeImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.skeletonColor,
    required this.vibeScore,
  });

  @override
  Widget build(BuildContext context) {
    final filter = ExpressiveTheme.getImageFilter(vibeScore);
    final image = ExpressiveImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      skeletonColor: skeletonColor,
    );

    if (filter == null) {
      return image;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        ColorFiltered(colorFilter: filter, child: image),
        GrainOverlay(opacity: ExpressiveTheme.getGrainOpacity(vibeScore)),
      ],
    );
  }
}
