import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../graphql/queries.dart';
import '../theme/expressive_theme.dart';
import '../screens/web_view_page.dart';
import 'expressive_image.dart';
import 'anime_card_skeleton.dart';
import 'user_accent_builder.dart';
import 'liked_by_section.dart';
import 'activity_reply_item.dart';
import 'zoomable_image.dart';

class ActivityDetailsDialog extends StatefulWidget {
  final int activityId;
  final Map<String, dynamic>? initialActivity;
  final double vibeScore;

  const ActivityDetailsDialog({
    super.key,
    required this.activityId,
    this.initialActivity,
    this.vibeScore = 0.0,
  });

  @override
  State<ActivityDetailsDialog> createState() => _ActivityDetailsDialogState();
}

class _ActivityDetailsDialogState extends State<ActivityDetailsDialog> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  String _getRelativeTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return timeago.format(dateTime, locale: 'en_short');
  }

  @override
  Widget build(BuildContext context) {
    final vibe = VibeColors.fromScore(widget.vibeScore);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: vibe.scaffoldBg,
          border: Border.all(color: vibe.primaryText, width: 3),
          boxShadow: [
            BoxShadow(
              color: vibe.shadowColor,
              offset: const Offset(8, 8),
              blurRadius: 0,
            ),
          ],
        ),
        child: ClipRect(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildHeader(vibe),

              // Content
              Expanded(
                child: Query(
                  options: QueryOptions(
                    document: gql(AnimeQueries.getActivityDetails),
                    variables: {'id': widget.activityId},
                    fetchPolicy: widget.initialActivity?['replies'] != null
                        ? FetchPolicy.cacheOnly
                        : FetchPolicy.cacheFirst,
                  ),
                  builder: (result, {refetch, fetchMore}) {
                    if (result.isLoading && widget.initialActivity == null) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: AnimeCardSkeleton(height: 200),
                      );
                    }

                    final data =
                        result.data?['Activity'] ?? widget.initialActivity;
                    if (data == null) {
                      return _buildErrorState(vibe);
                    }

                    return _buildContent(data, vibe, refetch);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(VibeColors vibe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: vibe.primaryText, width: 2)),
        color: vibe.scaffoldBg,
      ),
      child: Row(
        children: [
          Text(
            'THREAD',
            style: GoogleFonts.teko(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: vibe.primaryText,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(Icons.close, color: vibe.primaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(VibeColors vibe) {
    return Center(
      child: Text(
        'COULD NOT LOAD ACTIVITY',
        style: GoogleFonts.teko(color: vibe.primaryText, fontSize: 20),
      ),
    );
  }

  Widget _buildContent(
    Map<String, dynamic> data,
    VibeColors vibe,
    VoidCallback? refetch,
  ) {
    final user = data['user'] as Map<String, dynamic>?;
    final avatarUrl = user?['avatar']?['large'] as String? ?? '';
    final profileColorName = user?['options']?['profileColor'] as String?;
    final userName = user?['name'] as String? ?? 'Unknown';
    final text = data['text'] as String? ?? '';
    final createdAt = data['createdAt'] as int? ?? 0;
    final replies = (data['replies'] as List<dynamic>?) ?? [];
    final likes = (data['likes'] as List<dynamic>?) ?? [];

    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: [
        // Main Post
        _buildMainPost(userName, avatarUrl, createdAt, text, vibe),

        // Liked by section
        LikedBySection(likes: likes, vibeScore: widget.vibeScore),

        // Action buttons (Like & Comment)
        _buildActionButtons(data, avatarUrl, profileColorName, vibe, refetch),

        // Comment input
        _buildCommentInput(vibe, refetch),

        // Divider
        Container(height: 2, color: vibe.primaryText.withValues(alpha: 0.1)),

        // Replies section
        _buildRepliesSection(replies, vibe, refetch),
      ],
    );
  }

  Widget _buildMainPost(
    String userName,
    String avatarUrl,
    int createdAt,
    String text,
    VibeColors vibe,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info
          Row(
            children: [
              ClipOval(
                child: avatarUrl.isNotEmpty
                    ? ExpressiveImage(
                        imageUrl: avatarUrl,
                        width: 48,
                        height: 48,
                      )
                    : Container(
                        width: 48,
                        height: 48,
                        color: vibe.primaryText.withValues(alpha: 0.1),
                        child: Icon(Icons.person, color: vibe.primaryText),
                      ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName.toUpperCase(),
                    style: GoogleFonts.teko(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: vibe.primaryText,
                    ),
                  ),
                  Text(
                    _getRelativeTime(createdAt),
                    style: GoogleFonts.teko(
                      fontSize: 14,
                      color: vibe.primaryText.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Body
          HtmlWidget(
            text,
            textStyle: GoogleFonts.teko(
              fontSize: 18,
              color: vibe.primaryText,
              height: 1.4,
            ),
            onTapUrl: (url) async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebViewPage(
                    url: url,
                    title: 'LINK',
                    vibeScore: widget.vibeScore,
                  ),
                ),
              );
              return true;
            },
            customWidgetBuilder: (element) {
              if (element.localName == 'img' &&
                  element.attributes.containsKey('src')) {
                final src = element.attributes['src']!;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ZoomableImage(
                    imageUrl: src,
                    vibeScore: widget.vibeScore,
                    child: ExpressiveImage(imageUrl: src),
                  ),
                );
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    Map<String, dynamic> data,
    String avatarUrl,
    String? profileColorName,
    VibeColors vibe,
    VoidCallback? refetch,
  ) {
    return UserAccentBuilder(
      avatarUrl: avatarUrl,
      profileColorName: profileColorName,
      vibeScore: widget.vibeScore,
      builder: (context, heartColor) => Mutation(
        options: MutationOptions(
          document: gql(AnimeQueries.toggleLike),
          onCompleted: (_) => refetch?.call(),
        ),
        builder: (runMutation, result) {
          final isLiked = data['isLiked'] as bool? ?? false;
          final likeCount = data['likeCount'] as int? ?? 0;
          final replyCount = data['replyCount'] as int? ?? 0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Like button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    runMutation({'id': widget.activityId, 'type': 'ACTIVITY'});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isLiked ? heartColor : Colors.transparent,
                      border: Border.all(
                        color: isLiked ? heartColor : vibe.primaryText,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isLiked
                              ? ExpressiveTheme.getContrastText(heartColor)
                              : vibe.primaryText,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$likeCount',
                          style: GoogleFonts.teko(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isLiked
                                ? ExpressiveTheme.getContrastText(heartColor)
                                : vibe.primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Reply count indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: vibe.primaryText, width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 18,
                        color: vibe.primaryText,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$replyCount',
                        style: GoogleFonts.teko(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: vibe.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommentInput(VibeColors vibe, VoidCallback? refetch) {
    return Mutation(
      options: MutationOptions(
        document: gql(AnimeQueries.saveActivityReply),
        onCompleted: (_) {
          _commentController.clear();
          _commentFocusNode.unfocus();
          refetch?.call();
        },
      ),
      builder: (runMutation, result) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: vibe.primaryText, width: 2),
                  ),
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocusNode,
                    style: GoogleFonts.teko(
                      fontSize: 16,
                      color: vibe.primaryText,
                    ),
                    decoration: InputDecoration(
                      hintText: 'ADD A COMMENT...',
                      hintStyle: GoogleFonts.teko(
                        fontSize: 16,
                        color: vibe.primaryText.withValues(alpha: 0.4),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  final text = _commentController.text.trim();
                  if (text.isEmpty) return;
                  HapticFeedback.lightImpact();
                  runMutation({'activityId': widget.activityId, 'text': text});
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: vibe.primaryText,
                    border: Border.all(color: vibe.primaryText, width: 2),
                  ),
                  child: Icon(Icons.send, color: vibe.scaffoldBg, size: 20),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRepliesSection(
    List<dynamic> replies,
    VibeColors vibe,
    VoidCallback? refetch,
  ) {
    if (replies.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'NO REPLIES YET',
            style: GoogleFonts.teko(
              fontSize: 16,
              color: vibe.primaryText.withValues(alpha: 0.4),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'REPLIES (${replies.length})',
            style: GoogleFonts.teko(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: vibe.primaryText.withValues(alpha: 0.7),
            ),
          ),
        ),
        Mutation(
          options: MutationOptions(
            document: gql(AnimeQueries.toggleLike),
            onCompleted: (_) => refetch?.call(),
          ),
          builder: (runMutation, result) {
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: replies.length,
              separatorBuilder: (_, __) => Divider(
                color: vibe.primaryText.withValues(alpha: 0.05),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final reply = replies[index] as Map<String, dynamic>;
                return ActivityReplyItem(
                  reply: reply,
                  vibeScore: widget.vibeScore,
                  onLike: (reply) {
                    runMutation({'id': reply['id'], 'type': 'ACTIVITY_REPLY'});
                  },
                );
              },
            );
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
