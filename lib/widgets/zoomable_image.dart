import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'expressive_image.dart';

/// A wrapper widget that allows its child (usually an image) to be tapped
/// and opened in a full-screen zoomable viewer.
class ZoomableImage extends StatelessWidget {
  final Widget child;
  final String imageUrl;
  final String? heroTag;
  final double? vibeScore;

  const ZoomableImage({
    super.key,
    required this.child,
    required this.imageUrl,
    this.heroTag,
    this.vibeScore,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            barrierColor: Colors.black.withValues(alpha: 0.9),
            pageBuilder: (context, _, __) => _ZoomableImageViewer(
              imageUrl: imageUrl,
              heroTag: heroTag,
              vibeScore: vibeScore,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        );
      },
      child: heroTag != null
          ? Hero(
              tag: heroTag!,
              flightShuttleBuilder:
                  (
                    flightContext,
                    animation,
                    flightDirection,
                    fromHeroContext,
                    toHeroContext,
                  ) {
                    // Determine which widget to show during flight
                    final Hero toHero = toHeroContext.widget as Hero;
                    // When pushing (flightDirection.push), we want the `child` (which is the source image) to fly to the destination.
                    // But the destination is a PhotoView which might look different.
                    // Using the source child is usually safer for the flight.
                    return toHero.child;
                  },
              child: child,
            )
          : child,
    );
  }
}

class _ZoomableImageViewer extends StatefulWidget {
  final String imageUrl;
  final String? heroTag;
  final double? vibeScore;

  const _ZoomableImageViewer({
    required this.imageUrl,
    this.heroTag,
    this.vibeScore,
  });

  @override
  State<_ZoomableImageViewer> createState() => _ZoomableImageViewerState();
}

class _ZoomableImageViewerState extends State<_ZoomableImageViewer> {
  // Using a simplified approach without external photo_view package if possible,
  // but standard InteractiveViewer is great for this.
  // Actually, InteractiveViewer is built-in. Let's use that first to avoid adding dependencies if unnecessary.
  // Although the user mentioned "scroll around", InteractiveViewer handles this.

  // NOTE: Providing a "drag to dismiss" is a nice touch for a premium feel.
  // For now, we'll implement a basic InteractiveViewer with a close button.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Dismissible area (tap background to close)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.transparent),
            ),
          ),

          // Image
          Center(
            child: widget.heroTag != null
                ? Hero(tag: widget.heroTag!, child: _buildZoomableImage())
                : _buildZoomableImage(),
          ),

          // Close button
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomableImage() {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      clipBehavior: Clip.none,
      child: SizedBox.expand(
        child: ExpressiveImage(imageUrl: widget.imageUrl, fit: BoxFit.contain),
      ),
    );
  }
}
