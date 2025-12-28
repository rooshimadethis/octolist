import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/expressive_theme.dart';
import '../widgets/expressive_image.dart';
import 'user_accent_builder.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'pressable_card.dart';

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
    final user = activity['user'] as Map<String, dynamic>?;
    final userName = user?['name'] as String? ?? 'Unknown User';
    final avatarUrl = user?['avatar']?['large'] as String? ?? '';
    final profileColorName = user?['options']?['profileColor'] as String?;

    final text = activity['text'] as String? ?? '';
    final createdAt = activity['createdAt'] as int? ?? 0;
    final replyCount = activity['replyCount'] as int? ?? 0;
    final likeCount = activity['likeCount'] as int? ?? 0;
    final isLiked = activity['isLiked'] as bool? ?? false;

    final vibe = VibeColors.fromScore(vibeScore);

    return UserAccentBuilder(
      avatarUrl: avatarUrl,
      profileColorName: profileColorName,
      vibeScore: vibeScore,
      builder: (context, heartColor) => PressableCard(
        shadowOffset: vibe.shadowOffset,
        onTap: onTap,
        builder: (context, isPressed) => AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutQuad,
          margin: EdgeInsets.only(
            left: 16,
            right: 16 + vibe.shadowOffset.dx,
            top: 8,
            bottom: 8 + vibe.shadowOffset.dy,
          ),
          decoration: BoxDecoration(
            color: vibe.scaffoldBg,
            border: Border.all(color: vibe.primaryText, width: 3),
            boxShadow: [
              BoxShadow(
                color: vibe.shadowColor,
                offset: isPressed ? Offset.zero : vibe.shadowOffset,
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

              // Middle Section: Text
              Padding(
                padding: const EdgeInsets.all(12),
                child: IgnorePointer(
                  child: HtmlWidget(
                    text,
                    textStyle: GoogleFonts.teko(
                      fontSize: 18,
                      color: vibe.primaryText,
                      height: 1.3,
                    ),
                    onTapUrl: (_) => false,
                    onTapImage: (_) => false,
                  ),
                ),
              ),

              // Footer with stats
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: isLiked
                          ? heartColor
                          : vibe.primaryText.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$likeCount',
                      style: GoogleFonts.teko(
                        fontSize: 14,
                        color: isLiked
                            ? heartColor
                            : vibe.primaryText.withValues(alpha: 0.7),
                      ),
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
