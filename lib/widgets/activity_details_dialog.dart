import 'package:flutter/material.dart';

import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../graphql/queries.dart';
import '../theme/expressive_theme.dart';
import '../widgets/expressive_image.dart';
import '../widgets/anime_card_skeleton.dart';

class ActivityDetailsDialog extends StatelessWidget {
  final int activityId;
  final Map<String, dynamic>? initialActivity;
  final double vibeScore;

  const ActivityDetailsDialog({
    super.key,
    required this.activityId,
    this.initialActivity,
    this.vibeScore = 0.0,
  });

  String _getRelativeTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return timeago.format(dateTime, locale: 'en_short');
  }

  @override
  Widget build(BuildContext context) {
    final vibe = VibeColors.fromScore(vibeScore);

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
                    variables: {'id': activityId},
                    fetchPolicy: FetchPolicy.networkOnly,
                  ),
                  builder:
                      (
                        QueryResult result, {
                        VoidCallback? refetch,
                        FetchMore? fetchMore,
                      }) {
                        if (result.isLoading && initialActivity == null) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: const AnimeCardSkeleton(height: 200),
                          );
                        }

                        final data =
                            result.data?['Activity'] ?? initialActivity;

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
                        final replies =
                            (data['replies'] as List<dynamic>?) ?? [];
                        final replyCount = replies.length;

                        // Attached Media Data
                        final media = data['media'] as Map<String, dynamic>?;
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
                          mediaCoverUrl =
                              coverObj['extraLarge'] ??
                              coverObj['large'] ??
                              coverObj['medium'];
                        }

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
                                              color: vibe.primaryText
                                                  .withValues(alpha: 0.7),
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
                                      if (await canLaunchUrl(Uri.parse(url))) {
                                        await launchUrl(
                                          Uri.parse(url),
                                          mode: LaunchMode.externalApplication,
                                        );
                                        return true;
                                      }
                                      return false;
                                    },
                                  ),

                                  // Attached Media (If any)
                                  if (hasMedia && mediaCoverUrl != null) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: vibe.primaryText,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: vibe.shadowColor,
                                            offset: const Offset(4, 4),
                                            blurRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 80,
                                            height: 120,
                                            child: ExpressiveImage(
                                              imageUrl: mediaCoverUrl,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'TALKING ABOUT:',
                                                    style: GoogleFonts.teko(
                                                      fontSize: 14,
                                                      color: vibe.primaryText
                                                          .withValues(
                                                            alpha: 0.7,
                                                          ),
                                                    ),
                                                  ),
                                                  Text(
                                                    mediaTitle!,
                                                    style: GoogleFonts.teko(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: vibe.primaryText,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Divider
                            Container(
                              height: 2,
                              color: vibe.primaryText.withValues(alpha: 0.2),
                            ),

                            // Replies
                            if (replies.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  8,
                                ),
                                child: Text(
                                  'REPLIES ($replyCount)',
                                  style: GoogleFonts.teko(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: vibe.primaryText.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ),
                              ListView.separated(
                                shrinkWrap: true, // Needed inside ListView
                                physics:
                                    const NeverScrollableScrollPhysics(), // Scroll parent
                                itemCount: replies.length,
                                separatorBuilder: (c, i) => Divider(
                                  color: vibe.primaryText.withValues(
                                    alpha: 0.1,
                                  ),
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
                                      rUser?['avatar']?['large'] as String? ??
                                      '';
                                  final rText = reply['text'] as String? ?? '';
                                  final rTime = reply['createdAt'] as int? ?? 0;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: vibe.primaryText,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    _getRelativeTime(rTime),
                                                    style: GoogleFonts.teko(
                                                      fontSize: 12,
                                                      color: vibe.primaryText
                                                          .withValues(
                                                            alpha: 0.6,
                                                          ),
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
                                                  if (await canLaunchUrl(
                                                    Uri.parse(url),
                                                  )) {
                                                    await launchUrl(
                                                      Uri.parse(url),
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                    return true;
                                                  }
                                                  return false;
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
