import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/anime.dart';
import '../theme/expressive_theme.dart';
import '../screens/anime_details_page.dart';
import 'expressive_image.dart';
import 'outlined_star.dart';

import '../widgets/grain_overlay.dart';

/// A reusable manga-style anime card with consistent styling
/// Used across home, search, and library pages
class MangaCard extends StatefulWidget {
  final Anime anime;
  final double width;
  final Widget? overlayBadge;
  final double vibeScore;

  const MangaCard({
    super.key,
    required this.anime,
    this.width = 180,
    this.overlayBadge,
    this.vibeScore = 0.0,
  });

  @override
  State<MangaCard> createState() => _MangaCardState();
}

class _MangaCardState extends State<MangaCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final vibe = VibeColors.fromScore(
      widget.vibeScore,
      widget.anime.parsedColor,
    );

    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () async {
          setState(() => _isPressed = true);
          HapticFeedback.lightImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted) setState(() => _isPressed = false);
          await Future.delayed(const Duration(milliseconds: 50));
          if (!context.mounted) return;

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AnimeDetailsPage(anime: widget.anime),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutQuad,
          width: widget.width,
          transform: Matrix4.translationValues(
            _isPressed ? vibe.shadowOffset.dx : 0,
            _isPressed ? vibe.shadowOffset.dy : 0,
            0,
          ),
          decoration: BoxDecoration(
            color: vibe.scaffoldBg,
            border: Border.all(
              width: ExpressiveTheme.borderWidthMedium,
              color: vibe.primaryText,
            ),
            borderRadius: BorderRadius.zero,
            boxShadow: [
              BoxShadow(
                color: vibe.shadowColor,
                offset: _isPressed ? Offset.zero : vibe.shadowOffset,
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'anime_cover_${widget.anime.id}',
                      child: Builder(
                        builder: (context) {
                          final image = ExpressiveImage(
                            imageUrl: widget.anime.coverImage,
                            fit: BoxFit.cover,
                            skeletonColor: widget.anime.parsedColor,
                          );

                          if (vibe.imageFilter == null) return image;

                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              ColorFiltered(
                                colorFilter: vibe.imageFilter!,
                                child: image,
                              ),
                              GrainOverlay(opacity: vibe.grainOpacity),
                            ],
                          );
                        },
                      ),
                    ),
                    if (widget.anime.averageScore != null)
                      Positioned(
                        top: ExpressiveTheme.spacingS,
                        left: ExpressiveTheme.spacingS,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ExpressiveTheme.spacingS,
                            vertical: ExpressiveTheme.spacingXS,
                          ),
                          decoration: BoxDecoration(
                            color: vibe.primaryText,
                            border: Border.all(
                              color: vibe.scaffoldBg,
                              width: ExpressiveTheme.borderWidthThin,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: vibe.shadowColor,
                                offset: ExpressiveTheme.shadowOffsetSmall,
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OutlinedStar(size: 12, color: vibe.scaffoldBg),
                              const SizedBox(width: ExpressiveTheme.spacingXS),
                              Text(
                                '${widget.anime.averageScore}%',
                                style: ExpressiveTheme.monoMedium(
                                  color: vibe.scaffoldBg,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (widget.overlayBadge != null)
                      Positioned(
                        bottom: ExpressiveTheme.spacingS,
                        right: ExpressiveTheme.spacingS,
                        child: widget.overlayBadge!,
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(ExpressiveTheme.spacingM),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      width: ExpressiveTheme.borderWidthMedium,
                      color: vibe.primaryText,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.anime.title.toUpperCase(),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: ExpressiveTheme.cardTitle(color: vibe.primaryText),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
