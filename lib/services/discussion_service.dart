import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/anime.dart';

enum DiscussionSource { aniList, myAnimeList, redditSearch, googleSearch }

class DiscussionOption {
  final String title;
  final String url;
  final DiscussionSource source;
  final String? iconPath; // For custom icons if needed

  DiscussionOption({
    required this.title,
    required this.url,
    required this.source,
    this.iconPath,
  });
}

class DiscussionService {
  final GraphQLClient graphQLClient;

  DiscussionService({required this.graphQLClient});

  /// Fetches discussion links from multiple sources in parallel
  Future<List<DiscussionOption>> getDiscussionLinks(
    Anime anime,
    int episodeNumber,
  ) async {
    final futures = <Future<List<DiscussionOption>>>[
      _getAniListThreads(anime, episodeNumber),
      if (anime.idMal != null) _getJikanThreads(anime.idMal!, episodeNumber),
    ];

    final results = await Future.wait(futures);
    final options = results.expand((x) => x).toList();

    // Always add Fallback Search Options
    options.addAll(_getFallbackOptions(anime, episodeNumber));

    return options;
  }

  /// 1. Jikan API (MyAnimeList)
  /// Docs: https://docs.api.jikan.moe/#tag/anime/operation/getAnimeForum
  Future<List<DiscussionOption>> _getJikanThreads(
    int idMal,
    int episodeNumber,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.jikan.moe/v4/anime/$idMal/forum'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final topics = data['data'] as List<dynamic>;

        // Filter for "Episode X Discussion" related topics
        // Jikan topics are usually broad, but for episode discussions they often follow a pattern
        // or we filter the title.
        final relevantTopics = topics.where((topic) {
          final title = (topic['title'] as String).toLowerCase();
          final episodeStr = 'episode $episodeNumber';
          return title.contains(episodeStr) && title.contains('discussion');
        }).toList();

        return relevantTopics.map((topic) {
          return DiscussionOption(
            title: 'MyAnimeList Thread',
            url: 'https://myanimelist.net/forum/?topicid=${topic['mal_id']}',
            source: DiscussionSource.myAnimeList,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Error fetching Jikan threads: $e');
    }
    return [];
  }

  /// 2. AniList API
  Future<List<DiscussionOption>> _getAniListThreads(
    Anime anime,
    int episodeNumber,
  ) async {
    try {
      // 1. Try to find a direct thread for the episode linked to the media
      // This query looks for threads in the "Release Discussion" category (id: 5)
      // We perform a text search because filtering by Media ID isn't directly supported
      // on the `Page` query without filtering, but we can search for the title.

      // Construct a search query closer to what likely exists
      final searchQuery = '${anime.title} Episode $episodeNumber';

      final QueryOptions options = QueryOptions(
        document: gql(r'''
          query ($search: String) {
            Page(page: 1, perPage: 5) {
              threads(search: $search, sort: SEARCH_MATCH) {
                id
                title
                siteUrl
                categories {
                  id
                  name
                }
              }
            }
          }
        '''),
        variables: {'search': searchQuery},
      );

      final result = await graphQLClient.query(options);

      if (result.hasException) return [];

      final threads = result.data?['Page']?['threads'] as List<dynamic>? ?? [];

      return threads
          .where((thread) {
            // Double check it's relevant (optional, but good for accuracy)
            final title = (thread['title'] as String).toLowerCase();
            return title.contains('episode') &&
                (title.contains('$episodeNumber') ||
                    title.contains(
                      ' ${episodeNumber.toString().padLeft(2, '0')} ',
                    ));
          })
          .map((thread) {
            return DiscussionOption(
              title: 'AniList Thread',
              url: thread['siteUrl'],
              source: DiscussionSource.aniList,
            );
          })
          .toList();
    } catch (e) {
      debugPrint('Error fetching AniList threads: $e');
    }
    return [];
  }

  /// 3. Fallback Search Links
  List<DiscussionOption> _getFallbackOptions(Anime anime, int episodeNumber) {
    final query = Uri.encodeComponent(
      '${anime.title} Episode $episodeNumber Discussion',
    );

    return [
      DiscussionOption(
        title: 'Search Reddit',
        url: 'https://www.google.com/search?q=$query+site:reddit.com',
        source: DiscussionSource.redditSearch,
      ),
      DiscussionOption(
        title: 'Search MyAnimeList',
        url: 'https://www.google.com/search?q=$query+site:myanimelist.net',
        source: DiscussionSource.googleSearch,
      ),
      DiscussionOption(
        title: 'Search AniList',
        url: 'https://anilist.co/search/threads?search=$query',
        source: DiscussionSource.aniList,
      ),
    ];
  }
}
