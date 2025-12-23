import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/anime.dart';
import '../models/user_profile.dart';
import 'mock_data_service.dart'; // For WatchingEntry class
import '../graphql/anilist_client.dart';
import '../graphql/queries.dart';

/// Service for interacting with the AniList GraphQL API.
///
/// This service replaces MockDataService for production use.
class AniListService {
  final ValueNotifier<GraphQLClient> _clientNotifier;

  AniListService() : _clientNotifier = AniListClient.initClient();

  GraphQLClient get _client => _clientNotifier.value;

  /// Loads the current user's profile information.
  Future<UserProfile?> getUserProfile() async {
    final QueryOptions options = QueryOptions(
      document: gql(AnimeQueries.getViewer),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    try {
      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        debugPrint(
          'Error fetching user profile: ${result.exception.toString()}',
        );
        return null;
      }

      if (result.data?['Viewer'] == null) {
        return null;
      }

      return UserProfile.fromJson(result.data!['Viewer']);
    } catch (e) {
      debugPrint('Exception fetching user profile: $e');
      return null;
    }
  }

  /// Loads the user's currently watching anime list.
  Future<List<WatchingEntry>> getWatchingList() async {
    // We need the user ID first
    final user = await getUserProfile();
    if (user == null) return [];

    final QueryOptions options = QueryOptions(
      document: gql(AnimeQueries.getMediaList),
      variables: {
        'userId':
            user.id, // We need to add ID to UserProfile model if not there
        'status': 'CURRENT',
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    try {
      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        debugPrint(
          'Error fetching watching list: ${result.exception.toString()}',
        );
        return [];
      }

      final lists = result.data?['MediaListCollection']?['lists'] as List?;
      if (lists == null || lists.isEmpty) return [];

      // Usually only one list returned directly if filtered by status,
      // but AniList structure nests it in 'lists' array
      final watchingList = lists.first;
      final entries = watchingList['entries'] as List;

      return entries.map((e) {
        return WatchingEntry(
          id: e['id'],
          progress: e['progress'] ?? 0,
          userScore: (e['score'] as num?)?.toInt() ?? 0,
          anime: Anime.fromJson(e['media']),
        );
      }).toList();
    } catch (e) {
      debugPrint('Exception fetching watching list: $e');
      return [];
    }
  }

  /// Loads all of the user's library lists.
  Future<Map<String, List<WatchingEntry>>> getLibraryLists() async {
    final user = await getUserProfile();
    if (user == null) return {};

    final QueryOptions options = QueryOptions(
      document: gql(AnimeQueries.getMediaList),
      variables: {'userId': user.id},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    try {
      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        debugPrint('Error fetching library: ${result.exception.toString()}');
        return {};
      }

      final lists = result.data?['MediaListCollection']?['lists'] as List?;
      if (lists == null) return {};

      final Map<String, List<WatchingEntry>> library = {};

      for (var list in lists) {
        final String name = list['name'];
        final List entries = list['entries'];
        library[name] = entries.map((e) {
          return WatchingEntry(
            id: e['id'],
            progress: e['progress'] ?? 0,
            userScore: (e['score'] as num?)?.toInt() ?? 0,
            anime: Anime.fromJson(e['media']),
          );
        }).toList();
      }

      return library;
    } catch (e) {
      debugPrint('Exception fetching library: $e');
      return {};
    }
  }

  /// Loads the list of currently trending anime.
  Future<List<Anime>> getTrendingAnime() async {
    final QueryOptions options = QueryOptions(
      document: gql(AnimeQueries.getTrendingAnime),
      fetchPolicy: FetchPolicy.cacheAndNetwork,
    );

    try {
      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        debugPrint('Error fetching trending: ${result.exception.toString()}');
        return [];
      }

      final List media = result.data?['trending']?['media'] ?? [];
      return media.map((e) => Anime.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Exception fetching trending: $e');
      return [];
    }
  }

  /// Loads detailed information for a specific anime by ID.
  Future<Anime?> getAnimeDetails(int id) async {
    final QueryOptions options = QueryOptions(
      document: gql(AnimeQueries.getAnimeDetails),
      variables: {'id': id},
      fetchPolicy: FetchPolicy.cacheFirst,
    );

    try {
      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        debugPrint('Error fetching details: ${result.exception.toString()}');
        return null;
      }

      if (result.data?['Media'] == null) return null;

      return Anime.fromJson(result.data!['Media']);
    } catch (e) {
      debugPrint('Exception fetching details: $e');
      return null;
    }
  }

  /// Searches for anime matching the given query.
  Future<List<Anime>> searchAnime(String query) async {
    final QueryOptions options = QueryOptions(
      document: gql(AnimeQueries.searchAnime),
      variables: {'query': query},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    try {
      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        debugPrint('Error searching anime: ${result.exception.toString()}');
        return [];
      }

      final List media = result.data?['Page']?['media'] ?? [];
      return media.map((e) => Anime.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Exception searching anime: $e');
      return [];
    }
  }

  /// Retrieves the names of all available lists in the user's library.
  Future<List<String>> getAvailableListNames() async {
    final lists = await getLibraryLists();
    return lists.keys.toList();
  }

  /// Check if an anime is in the user's library and return the entry
  Future<WatchingEntry?> getMediaListEntry(int animeId) async {
    // This is inefficient but works for now without complex cache management
    // Ideally we would query for just this media entry directly from API
    // but the getMediaListEntry query structure is specific.
    // For optimization, we should implement a specific query for this.
    final lists = await getLibraryLists();

    for (var list in lists.values) {
      for (var entry in list) {
        if (entry.anime.id == animeId) {
          return entry;
        }
      }
    }
    return null;
  }

  /// Saves or updates an anime entry in the user's library.
  Future<void> saveMediaListEntry(
    int animeId,
    String listName,
    int progress,
  ) async {
    // Note: This needs mapping listName to MediaListStatus if using status,
    // or using string keys if custom lists.
    // For simplicity, we map standard names to statuses.
    String status = 'CURRENT';
    if (listName == 'Planning')
      status = 'PLANNING';
    else if (listName == 'Completed')
      status = 'COMPLETED';
    else if (listName == 'Dropped')
      status = 'DROPPED';
    else if (listName == 'Paused')
      status = 'PAUSED';

    final MutationOptions options = MutationOptions(
      document: gql(AnimeQueries.saveMediaListEntry),
      variables: {'mediaId': animeId, 'status': status, 'progress': progress},
    );

    try {
      final QueryResult result = await _client.mutate(options);
      if (result.hasException) {
        debugPrint('Error saving entry: ${result.exception.toString()}');
      }
    } catch (e) {
      debugPrint('Exception saving entry: $e');
    }
  }

  /// Updates the episode progress for an anime.
  Future<void> updateEpisodeProgress(
    int animeId,
    int progress,
    int? totalEpisodes,
  ) async {
    String? status;
    if (totalEpisodes != null && progress >= totalEpisodes) {
      status = 'COMPLETED';
    }

    final MutationOptions options = MutationOptions(
      document: gql(AnimeQueries.saveMediaListEntry),
      variables: {
        'mediaId': animeId,
        'progress': progress,
        if (status != null) 'status': status,
      },
    );

    try {
      final QueryResult result = await _client.mutate(options);
      if (result.hasException) {
        debugPrint('Error updating progress: ${result.exception.toString()}');
      }
    } catch (e) {
      debugPrint('Exception updating progress: $e');
    }
  }
}
