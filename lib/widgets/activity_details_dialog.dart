import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:timeago/timeago.dart' as timeago;
import '../graphql/queries.dart';
import '../theme/expressive_theme.dart';
import '../widgets/expressive_image.dart';
import '../widgets/anime_card_skeleton.dart';
import '../screens/web_view_page.dart';

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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: vibe.primaryText, width: 2),
                  ),
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
              ),

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
                  builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
                    if (result.isLoading && widget.initialActivity == null) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: const AnimeCardSkeleton(height: 200),
                      );
                    }

                    final data =
                        result.data?['Activity'] ?? widget.initialActivity;

                    if (data == null) {
                      return Center(
                        child: Text(
                          'COULD NOT LOAD ACTIVITY',
                          style: GoogleFonts.teko(
                            color: vibe.primaryText,
                            fontSize: 20,
                          ),
                        ),
                      );
                    }

                    final user = data['user'] as Map<String, dynamic>?;
                    final userName = user?['name'] as String? ?? 'Unknown';
                    final avatarUrl =
                        user?['avatar']?['large'] as String? ?? '';
                    final text = data['text'] as String? ?? '';
                    final createdAt = data['createdAt'] as int? ?? 0;
                    final replies = (data['replies'] as List<dynamic>?) ?? [];
                    final replyCount = replies.length;

                    return ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: [
                        // Main Post
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User Info
                              Row(
                                children: [
                                  ClipOval(
                                    child: ExpressiveImage(
                                      imageUrl: avatarUrl,
                                      width: 48,
                                      height: 48,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          color: vibe.primaryText.withValues(
                                            alpha: 0.7,
                                          ),
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
                              ),
                            ],
                          ),
                        ),

                        // Liked by section
                        Builder(
                          builder: (context) {
                            final likes =
                                (data['likes'] as List<dynamic>?) ?? [];
                            if (likes.isEmpty) {
                              return const SizedBox.shrink();
                            }

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
                                      color: vibe.primaryText.withValues(
                                        alpha: 0.6,
                                      ),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 75,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: likes.length > 10
                                          ? 10
                                          : likes.length,
                                      separatorBuilder: (c, i) =>
                                          const SizedBox(width: 12),
                                      itemBuilder: (context, index) {
                                        final user =
                                            likes[index]
                                                as Map<String, dynamic>;
                                        final userName =
                                            user['name'] as String? ??
                                            'Unknown';
                                        final avatarUrl =
                                            user['avatar']?['large']
                                                as String? ??
                                            '';

                                        return SizedBox(
                                          width: 50,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Tooltip(
                                                message: userName,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: vibe.primaryText,
                                                      width: 2,
                                                    ),
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
                                                            color: vibe
                                                                .primaryText
                                                                .withValues(
                                                                  alpha: 0.2,
                                                                ),
                                                            child: Icon(
                                                              Icons.person,
                                                              color: vibe
                                                                  .primaryText,
                                                              size: 24,
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                userName.toUpperCase(),
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
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        // Action buttons (Like & Comment)
                        Mutation(
                          options: MutationOptions(
                            document: gql(AnimeQueries.toggleLike),
                            onCompleted: (data) {
                              // Refetch to update likes list
                              refetch?.call();
                            },
                          ),
                          builder: (runMutation, result) {
                            final isLiked = data['isLiked'] as bool? ?? false;
                            final likeCount = data['likeCount'] as int? ?? 0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  // Like button
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      runMutation({
                                        'id': widget.activityId,
                                        'type': 'ACTIVITY',
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isLiked
                                            ? ExpressiveTheme.getHeartColor(
                                                widget.vibeScore,
                                              )
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isLiked
                                              ? ExpressiveTheme.getHeartColor(
                                                  widget.vibeScore,
                                                )
                                              : vibe.primaryText,
                                          width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isLiked
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            size: 18,
                                            color: isLiked
                                                ? ExpressiveTheme.getContrastText(
                                                    ExpressiveTheme.getHeartColor(
                                                      widget.vibeScore,
                                                    ),
                                                  )
                                                : vibe.primaryText,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '$likeCount',
                                            style: GoogleFonts.teko(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: isLiked
                                                  ? ExpressiveTheme.getContrastText(
                                                      ExpressiveTheme.getHeartColor(
                                                        widget.vibeScore,
                                                      ),
                                                    )
                                                  : vibe.primaryText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Comment count indicator
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: vibe.primaryText,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.chat_bubble_outline,
                                          size: 18,
                                          color: vibe.primaryText,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${replies.length}',
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

                        // Comment input section
                        Mutation(
                          options: MutationOptions(
                            document: gql(AnimeQueries.saveActivityReply),
                            onCompleted: (data) {
                              _commentController.clear();
                              _commentFocusNode.unfocus();
                              // Refetch to show new comment
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
                                        border: Border.all(
                                          color: vibe.primaryText,
                                          width: 2,
                                        ),
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
                                            color: vibe.primaryText.withValues(
                                              alpha: 0.4,
                                            ),
                                          ),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
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
                                      final text = _commentController.text
                                          .trim();
                                      if (text.isEmpty) return;

                                      HapticFeedback.lightImpact();
                                      runMutation({
                                        'activityId': widget.activityId,
                                        'text': text,
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: vibe.primaryText,
                                        border: Border.all(
                                          color: vibe.primaryText,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.send,
                                        color: vibe.scaffoldBg,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        // Divider
                        Container(
                          height: 2,
                          color: vibe.primaryText.withValues(alpha: 0.2),
                        ),

                        // Replies
                        if (replies.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              'REPLIES ($replyCount)',
                              style: GoogleFonts.teko(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: vibe.primaryText.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                          ListView.separated(
                            shrinkWrap: true, // Needed inside ListView
                            physics:
                                const NeverScrollableScrollPhysics(), // Scroll parent
                            itemCount: replies.length,
                            separatorBuilder: (c, i) => Divider(
                              color: vibe.primaryText.withValues(alpha: 0.1),
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              final reply =
                                  replies[index] as Map<String, dynamic>;
                              final rUser =
                                  reply['user'] as Map<String, dynamic>?;
                              final rName =
                                  rUser?['name'] as String? ?? 'Unknown';
                              final rAvatar =
                                  rUser?['avatar']?['large'] as String? ?? '';
                              final rText = reply['text'] as String? ?? '';
                              final rTime = reply['createdAt'] as int? ?? 0;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipOval(
                                      child: ExpressiveImage(
                                        imageUrl: rAvatar,
                                        width: 32,
                                        height: 32,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                rName.toUpperCase(),
                                                style: GoogleFonts.teko(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: vibe.primaryText,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                _getRelativeTime(rTime),
                                                style: GoogleFonts.teko(
                                                  fontSize: 12,
                                                  color: vibe.primaryText
                                                      .withValues(alpha: 0.6),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          HtmlWidget(
                                            rText,
                                            textStyle: GoogleFonts.teko(
                                              fontSize: 16,
                                              color: vibe.primaryText
                                                  .withValues(alpha: 0.9),
                                              height: 1.3,
                                            ),
                                            onTapUrl: (url) async {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      WebViewPage(
                                                        url: url,
                                                        title: 'LINK',
                                                        vibeScore:
                                                            widget.vibeScore,
                                                      ),
                                                ),
                                              );
                                              return true;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ] else if (!result.isLoading) ...[
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                'NO REPLIES YET',
                                style: GoogleFonts.teko(
                                  fontSize: 16,
                                  color: vibe.primaryText.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
