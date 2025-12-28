import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../theme/expressive_theme.dart';
import '../screens/web_view_page.dart';
import 'expressive_image.dart';
import 'user_accent_builder.dart';

/// A single reply item in an activity thread
class ActivityReplyItem extends StatelessWidget {
  final Map<String, dynamic> reply;
  final double vibeScore;
  final Function(Map<String, dynamic>) onLike;

  const ActivityReplyItem({
    super.key,
    required this.reply,
    required this.vibeScore,
    required this.onLike,
  });

  String _getRelativeTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return timeago.format(dateTime, locale: 'en_short');
  }

  @override
  Widget build(BuildContext context) {
    final vibe = VibeColors.fromScore(vibeScore);
    final user = reply['user'] as Map<String, dynamic>?;
    final avatarUrl = user?['avatar']?['large'] as String? ?? '';
    final profileColorName = user?['options']?['profileColor'] as String?;
    final userName = user?['name'] as String? ?? 'Unknown';
    final text = reply['text'] as String? ?? '';
    final createdAt = reply['createdAt'] as int? ?? 0;
    final isLiked = reply['isLiked'] as bool? ?? false;
    final likeCount = reply['likeCount'] as int? ?? 0;

    return UserAccentBuilder(
      avatarUrl: avatarUrl,
      profileColorName: profileColorName,
      vibeScore: vibeScore,
      builder: (context, heartColor) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            ClipOval(
              child: avatarUrl.isNotEmpty
                  ? ExpressiveImage(imageUrl: avatarUrl, width: 32, height: 32)
                  : Container(
                      width: 32,
                      height: 32,
                      color: vibe.primaryText.withValues(alpha: 0.1),
                      child: const Icon(Icons.person, size: 16),
                    ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Username and timestamp
                  Row(
                    children: [
                      Text(
                        userName.toUpperCase(),
                        style: GoogleFonts.teko(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: vibe.primaryText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getRelativeTime(createdAt),
                        style: GoogleFonts.teko(
                          fontSize: 12,
                          color: vibe.primaryText.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Reply text
                  HtmlWidget(
                    text,
                    textStyle: GoogleFonts.teko(
                      fontSize: 16,
                      color: vibe.primaryText.withValues(alpha: 0.9),
                      height: 1.2,
                    ),
                    onTapUrl: (url) async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebViewPage(
                            url: url,
                            title: 'LINK',
                            vibeScore: vibeScore,
                          ),
                        ),
                      );
                      return true;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Like button
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onLike(reply);
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 24,
                      color: isLiked
                          ? heartColor
                          : vibe.primaryText.withValues(alpha: 0.3),
                    ),
                    if (likeCount > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        '$likeCount',
                        style: GoogleFonts.teko(
                          fontSize: 18,
                          color: isLiked
                              ? heartColor
                              : vibe.primaryText.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
