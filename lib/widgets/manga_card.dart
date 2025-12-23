import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/anime.dart';
import '../theme/expressive_theme.dart';
import '../utils/color_parser.dart';
import '../screens/anime_details_page.dart';
import 'expressive_image.dart';
import 'outlined_star.dart';

/// A reusable manga-style anime card with consistent styling
/// Used across home, search, and library pages
class MangaCard extends StatelessWidget {
  final Anime anime;
  final double width;
  final Widget? overlayBadge;

  const MangaCard({
    super.key,
    required this.anime,
    this.width = 180,
    this.overlayBadge,
  });

  @override
  Widget build(BuildContext context) {
    final shadowColor = ColorParser.parseAnimeColor(anime.color);

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AnimeDetailsPage(anime: anime),
            ),
          );
        },
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: ExpressiveTheme.surfaceWhite,
            border: Border.all(
              width: ExpressiveTheme.borderWidthMedium,
              color: ExpressiveTheme.primaryBlack,
            ),
            borderRadius: BorderRadius.zero,
            boxShadow: ExpressiveTheme.hardShadows(
              color: shadowColor,
              offset: ExpressiveTheme.shadowOffsetXLarge,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'anime_cover_${anime.id}',
                      child: ExpressiveImage(
                        imageUrl: anime.coverImage,
                        fit: BoxFit.cover,
                        skeletonColor: anime.parsedColor,
                      ),
                    ),
                    if (anime.averageScore != null)
                      Positioned(
                        top: ExpressiveTheme.spacingS,
                        left: ExpressiveTheme.spacingS,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ExpressiveTheme.spacingS,
                            vertical: ExpressiveTheme.spacingXS,
                          ),
                          decoration: BoxDecoration(
                            color: ExpressiveTheme.primaryBlack,
                            border: Border.all(
                              color: ExpressiveTheme.surfaceWhite,
                              width: ExpressiveTheme.borderWidthThin,
                            ),
                            boxShadow: ExpressiveTheme.hardShadows(
                              offset: ExpressiveTheme.shadowOffsetSmall,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const OutlinedStar(size: 12),
                              const SizedBox(width: ExpressiveTheme.spacingXS),
                              Text(
                                '${anime.averageScore}%',
                                style: ExpressiveTheme.monoMedium(
                                  color: ExpressiveTheme.surfaceWhite,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (overlayBadge != null)
                      Positioned(
                        bottom: ExpressiveTheme.spacingS,
                        right: ExpressiveTheme.spacingS,
                        child: overlayBadge!,
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(ExpressiveTheme.spacingM),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      width: ExpressiveTheme.borderWidthMedium,
                      color: ExpressiveTheme.primaryBlack,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anime.title.toUpperCase(),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: ExpressiveTheme.cardTitle(),
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
