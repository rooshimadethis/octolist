import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/anime.dart';
import '../models/user_profile.dart';
import '../models/watching_entry.dart';
import '../graphql/anilist_client.dart';
import '../graphql/queries.dart';

import 'anime_service_interface.dart';

/// Service for interacting with the AniList GraphQL API.
///
/// This service replaces MockDataService for production use.
class AniListService implements IAnimeService {
  final ValueNotifier<GraphQLClient> _clientNotifier;

  static final AniListService _instance = AniListService._internal();

  factory AniListService() => _instance;

  AniListService._internal() : _clientNotifier = AniListClient.initClient();

  // Unified update stream for linking info across pages
  final _updateController = StreamController<AnimeUpdate>.broadcast();
  Stream<AnimeUpdate> get updates => _updateController.stream;

  /// Notify all listeners that an anime has been updated.
  void notifyUpdate(int mediaId, int progress, {String? status}) {
    _updateController.add(
      AnimeUpdate(mediaId: mediaId, progress: progress, status: status),
    );
  }

  // Debouncing state
  final Map<int, Timer> _debounceTimers = {};
  final Map<int, _PendingUpdate> _pendingUpdates = {};
  final Map<int, List<Completer<void>>> _pendingCompleters = {};

  GraphQLClient get _client => _clientNotifier.value;

  /// Loads the current user's profile information.
  Future<UserProfile?> getUserProfile() async {
    final QueryOptions options = QueryOptions(
      document: gql(AnimeQueries.getViewer),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw result.exception!;
    }

    if (result.data?['Viewer'] == null) {
      return null;
    }

    return UserProfile.fromJson(result.data!['Viewer']);
  }

  /// Loads the user's currently watching anime list.
  Future<List<WatchingEntry>> getWatchingList() async {
    // We need the user ID first
    final user = await getUserProfile();
    // If not logged in, return empty list (or throw? Empty seems fine for unauth state unless we enforce auth)
    if (user == null) return [];

    final QueryOptions options = QueryOptions(
      document: gql(AnimeQueries.getMediaList),
      variables: {'userId': user.id, 'status': 'CURRENT'},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw result.exception!;
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

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw result.exception!;
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
  }

  /// Loads the list of currently trending anime.
  Future<List<Anime>> getTrendingAnime() async {
    final QueryOptions options = QueryOptions(
      document: gql(AnimeQueries.getTrendingAnime),
      fetchPolicy: FetchPolicy.cacheAndNetwork,
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw result.exception!;
    }

    final List media = result.data?['trending']?['media'] ?? [];
    return media.map((e) => Anime.fromJson(e)).toList();
  }

  /// Loads detailed information for a specific anime by ID.
  Future<Anime?> getAnimeDetails(int id) async {
    final QueryOptions options = QueryOptions(
      document: gql(AnimeQueries.getAnimeDetails),
      variables: {'id': id},
      fetchPolicy: FetchPolicy.cacheFirst,
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw result.exception!;
    }

    if (result.data?['Media'] == null) return null;

    return Anime.fromJson(result.data!['Media']);
  }

  /// Searches for anime matching the given query.
  Future<List<Anime>> searchAnime(String query) async {
    final QueryOptions options = QueryOptions(
      document: gql(AnimeQueries.searchAnime),
      variables: {'query': query},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw result.exception!;
    }

    final List media = result.data?['Page']?['media'] ?? [];
    return media.map((e) => Anime.fromJson(e)).toList();
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
    if (listName == 'Planning') {
      status = 'PLANNING';
    } else if (listName == 'Completed') {
      status = 'COMPLETED';
    } else if (listName == 'Dropped') {
      status = 'DROPPED';
    } else if (listName == 'Paused') {
      status = 'PAUSED';
    }

    final MutationOptions options = MutationOptions(
      document: gql(AnimeQueries.saveMediaListEntry),
      variables: {'mediaId': animeId, 'status': status, 'progress': progress},
    );

    final QueryResult result = await _client.mutate(options);
    if (result.hasException) {
      throw result.exception!;
    }
  }

  /// Updates the episode progress for an anime with debouncing.
  ///
  /// This method automatically handles:
  /// - Debouncing (500ms) to prevent API spam
  /// - Status updates (moves to CURRENT if started, COMPLETED if finished)
  Future<void> updateEpisodeProgress(
    int animeId,
    int progress,
    int? totalEpisodes,
  ) async {
    // 1. Create a Completer for this request
    final completer = Completer<void>();

    if (!_pendingCompleters.containsKey(animeId)) {
      _pendingCompleters[animeId] = [];
    }
    _pendingCompleters[animeId]!.add(completer);

    // 2. Store the latest update data
    _pendingUpdates[animeId] = _PendingUpdate(
      progress: progress,
      totalEpisodes: totalEpisodes,
    );

    // 3. Cancel existing timer (debounce)
    _debounceTimers[animeId]?.cancel();

    // 4. Set new timer
    _debounceTimers[animeId] = Timer(const Duration(milliseconds: 1000), () {
      _executeDebouncedUpdate(animeId);
    });

    // 5. Return the Future so the UI can await the *eventual* result (if it wants)
    // Note: In a debounced scenario, usually only the last await 'matters' for error handling,
    // but we will complete ALL pending completers with the result of the batch.
    return completer.future;
  }

  Future<void> _executeDebouncedUpdate(int animeId) async {
    final updateData = _pendingUpdates[animeId];
    _pendingUpdates.remove(animeId);
    _debounceTimers.remove(animeId); // Clean up timer

    final completers = _pendingCompleters[animeId] ?? [];
    _pendingCompleters.remove(animeId);

    if (updateData == null) return;

    try {
      String? status;
      if (updateData.totalEpisodes != null &&
          updateData.progress >= updateData.totalEpisodes!) {
        status = 'COMPLETED';
      } else if (updateData.progress > 0) {
        // If we are making progress, assume we are watching it
        status = 'CURRENT';
      }

      final MutationOptions options = MutationOptions(
        document: gql(AnimeQueries.saveMediaListEntry),
        variables: {
          'mediaId': animeId,
          'progress': updateData.progress,
          if (status != null) 'status': status,
        },
      );

      final QueryResult result = await _client.mutate(options);

      if (result.hasException) {
        throw result.exception!;
      }

      // Success! Complete all waiting futures
      for (var c in completers) {
        if (!c.isCompleted) c.complete();
      }

      // Notify other pages about this change
      notifyUpdate(animeId, updateData.progress, status: status);
    } catch (e) {
      // Failure! Error all waiting futures
      for (var c in completers) {
        if (!c.isCompleted) c.completeError(e);
      }
    }
  }
}

class _PendingUpdate {
  final int progress;
  final int? totalEpisodes;

  _PendingUpdate({required this.progress, this.totalEpisodes});
}

/// Represents an update to an anime's progress or status.
class AnimeUpdate {
  final int mediaId;
  final int progress;
  final String? status;

  AnimeUpdate({required this.mediaId, required this.progress, this.status});
}
