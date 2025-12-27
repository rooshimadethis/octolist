import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../services/anime_store.dart';
import '../theme/expressive_theme.dart';
import '../widgets/activity_card.dart';
import '../widgets/anime_card_skeleton.dart';
import '../graphql/queries.dart';
import 'search_page.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  final int _perPage = 20;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AnimeStore>();
    final vibeScore = store.vibeScore;
    final primaryText = ExpressiveTheme.getPrimaryText(vibeScore);
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        title: Text(
          'SOCIAL',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            fontSize: 32,
            color: primaryText,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: primaryText, size: 28),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(vibeScore: vibeScore),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Query(
        options: QueryOptions(
          document: gql(AnimeQueries.getGlobalTextActivities),
          variables: {'page': _currentPage, 'perPage': _perPage},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
        builder:
            (
              QueryResult result, {
              VoidCallback? refetch,
              FetchMore? fetchMore,
            }) {
              if (result.hasException) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: primaryText),
                        const SizedBox(height: 16),
                        Text(
                          'FAILED TO LOAD FEED',
                          style: GoogleFonts.teko(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          result.exception.toString(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.teko(
                            fontSize: 16,
                            color: primaryText.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: refetch,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryText,
                            foregroundColor: scaffoldBg,
                            shape: const RoundedRectangleBorder(),
                          ),
                          child: Text(
                            'RETRY',
                            style: GoogleFonts.teko(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (result.isLoading && result.data == null) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: const AnimeCardSkeleton(
                        height: 180,
                      ).animate(delay: (index * 100).ms).fadeIn(),
                    );
                  },
                );
              }

              final activities =
                  result.data?['Page']?['activities'] as List<dynamic>? ?? [];
              final pageInfo =
                  result.data?['Page']?['pageInfo'] as Map<String, dynamic>?;
              final hasNextPage = pageInfo?['hasNextPage'] as bool? ?? false;

              if (activities.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: primaryText.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'NO ACTIVITIES FOUND',
                          style: GoogleFonts.teko(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _currentPage = 1;
                  });
                  refetch?.call();
                },
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: activities.length + (hasNextPage ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == activities.length) {
                      // Load more indicator
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _currentPage++;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryText,
                              foregroundColor: scaffoldBg,
                              shape: const RoundedRectangleBorder(),
                            ),
                            child: Text(
                              'LOAD MORE',
                              style: GoogleFonts.teko(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    final activity = activities[index] as Map<String, dynamic>;
                    return ActivityCard(
                      activity: activity,
                      vibeScore: vibeScore,
                    ).animate(delay: (index * 50).ms).fadeIn(duration: 300.ms);
                  },
                ),
              );
            },
      ),
    );
  }
}
