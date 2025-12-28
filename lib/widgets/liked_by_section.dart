import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/expressive_theme.dart';
import 'expressive_image.dart';

/// Displays a horizontal list of users who liked a post/activity
class LikedBySection extends StatelessWidget {
  final List<dynamic> likes;
  final double vibeScore;

  const LikedBySection({super.key, required this.likes, this.vibeScore = 0.0});

  @override
  Widget build(BuildContext context) {
    if (likes.isEmpty) return const SizedBox.shrink();

    final vibe = VibeColors.fromScore(vibeScore);
    final displayCount = likes.length > 10 ? 10 : likes.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LIKED BY ${likes.length}',
            style: GoogleFonts.teko(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: vibe.primaryText.withValues(alpha: 0.6),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 75,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: displayCount,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final likeUser = likes[index] as Map<String, dynamic>;
                final likeName = likeUser['name'] as String? ?? 'Unknown';
                final likeAvatar =
                    likeUser['avatar']?['large'] as String? ?? '';

                return _LikedUserAvatar(
                  name: likeName,
                  avatarUrl: likeAvatar,
                  vibe: vibe,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LikedUserAvatar extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final VibeColors vibe;

  const _LikedUserAvatar({
    required this.name,
    required this.avatarUrl,
    required this.vibe,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: name,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: vibe.primaryText, width: 2),
              ),
              child: ClipOval(
                child: avatarUrl.isNotEmpty
                    ? ExpressiveImage(
                        imageUrl: avatarUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 40,
                        height: 40,
                        color: vibe.primaryText.withValues(alpha: 0.2),
                        child: Icon(
                          Icons.person,
                          color: vibe.primaryText,
                          size: 24,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name.toUpperCase(),
            style: GoogleFonts.teko(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: vibe.primaryText,
              height: 1,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
