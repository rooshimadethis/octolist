import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/expressive_theme.dart';
import '../widgets/expressive_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../screens/web_view_page.dart';

/// A card widget for displaying a single text activity post from the global feed
class ActivityCard extends StatelessWidget {
  final Map<String, dynamic> activity;
  final double vibeScore;
  final VoidCallback? onTap;

  const ActivityCard({
    super.key,
    required this.activity,
    this.vibeScore = 0.0,
    this.onTap,
  });

  String _getRelativeTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return timeago.format(dateTime, locale: 'en_short');
  }

  @override
  Widget build(BuildContext context) {
    final vibe = VibeColors.fromScore(vibeScore);

    final user = activity['user'] as Map<String, dynamic>?;
    final userName = user?['name'] as String? ?? 'Unknown User';
    final avatarUrl = user?['avatar']?['large'] as String? ?? '';
    final text = activity['text'] as String? ?? '';
    final createdAt = activity['createdAt'] as int? ?? 0;
    final replyCount = activity['replyCount'] as int? ?? 0;
    final likeCount = activity['likeCount'] as int? ?? 0;

    // Attached Media Data
    final media = activity['media'] as Map<String, dynamic>?;
    final hasMedia = media != null;

    String? mediaTitle;
    String? mediaCoverUrl;

    if (hasMedia) {
      final titleObj = media['title'] ?? {};
      mediaTitle =
          titleObj['english'] ??
          titleObj['romaji'] ??
          titleObj['native'] ??
          'Unknown';

      final coverObj = media['coverImage'] ?? {};
      // Match Anime.fromJson logic: prefer extraLarge
      mediaCoverUrl =
          coverObj['extraLarge'] ?? coverObj['large'] ?? coverObj['medium'];
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: vibe.scaffoldBg,
          border: Border.all(color: vibe.primaryText, width: 3),
          boxShadow: [
            BoxShadow(
              color: vibe.shadowColor,
              offset: const Offset(6, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: vibe.primaryText, width: 2),
                ),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
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
                  const SizedBox(width: 12),
                  // Username and timestamp
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName.toUpperCase(),
                          style: GoogleFonts.teko(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: vibe.primaryText,
                            letterSpacing: 1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _getRelativeTime(createdAt),
                          style: GoogleFonts.teko(
                            fontSize: 14,
                            color: vibe.primaryText.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Middle Section: Text + Optional Media
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Activity Text
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: HtmlWidget(
                      text,
                      textStyle: GoogleFonts.teko(
                        fontSize: 18,
                        color: vibe.primaryText,
                        height: 1.3,
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
                  ),
                ),

                // Attached Media (Right Side)
                if (hasMedia && mediaCoverUrl != null)
                  Container(
                    width: 80,
                    margin: const EdgeInsets.only(
                      top: 12,
                      right: 12,
                      bottom: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: vibe.primaryText,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: vibe.shadowColor,
                                offset: const Offset(3, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: AspectRatio(
                            aspectRatio: 2 / 3,
                            child: ExpressiveImage(
                              imageUrl: mediaCoverUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (mediaTitle != null)
                          Text(
                            mediaTitle,
                            style: GoogleFonts.teko(
                              fontSize: 12,
                              color: vibe.primaryText,
                              height: 1.1,
                            ),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
              ],
            ),

            // Footer with stats
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: vibe.primaryText, width: 2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: vibe.primaryText.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$replyCount',
                    style: GoogleFonts.teko(
                      fontSize: 14,
                      color: vibe.primaryText.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.favorite_border,
                    size: 16,
                    color: vibe.primaryText.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$likeCount',
                    style: GoogleFonts.teko(
                      fontSize: 14,
                      color: vibe.primaryText.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
