import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/anime.dart';
import '../models/user_profile.dart';

/// Represents a user's watching entry with progress and score information.
///
/// This combines anime metadata with user-specific tracking data.
class WatchingEntry {
  final Anime anime;
  final int progress;
  final int userScore;
  final int id; // The entry ID, not media ID

  WatchingEntry({
    required this.anime,
    required this.progress,
    required this.userScore,
    required this.id,
  });
}

/// Service for loading mock AniList data from JSON assets.
///
/// This service simulates API calls by loading pre-fetched JSON data from the assets folder.
/// In a production app, these methods would make actual HTTP requests to the AniList GraphQL API.
class MockDataService {
  /// Loads the current user's profile information.
  ///
  /// Returns the user's name, avatar, and statistics.
  Future<UserProfile> getUserProfile() async {
    final jsonString = await rootBundle.loadString(
      'assets/anilist_data/viewer_data.json',
    );
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return UserProfile.fromJson(json['data']['Viewer']);
  }

  /// Loads the user's currently watching anime list.
  ///
  /// Returns a list of [WatchingEntry] objects containing anime with progress tracking.
  /// Looks for lists named "Watching" or "Current" in the user's library.
  /// Returns an empty list if no watching list is found.
  Future<List<WatchingEntry>> getWatchingList() async {
    final jsonString = await rootBundle.loadString(
      'assets/anilist_data/viewer_data.json',
    );
    final Map<String, dynamic> json = jsonDecode(jsonString);
    final List<dynamic> lists = json['data']['MediaListCollection']['lists'];

    // Find the "Watching" list
    final watchingList = lists.firstWhere(
      (list) => list['name'] == 'Watching' || list['name'] == 'Current',
      orElse: () => null,
    );

    if (watchingList == null) return [];

    final List<dynamic> entries = watchingList['entries'];
    return entries.map((e) {
      return WatchingEntry(
        id: e['id'],
        progress: e['progress'] ?? 0,
        userScore: e['score'] ?? 0,
        anime: Anime.fromJson(e['media']),
      );
    }).toList();
  }

  /// Loads all of the user's library lists (Watching, Completed, Planning, etc.).
  ///
  /// Returns a map where keys are list names and values are lists of [WatchingEntry].
  /// Each entry includes the anime and the user's progress/score for that anime.
  /// Lists are ordered: Watching, Planning, Completed, Dropped
  Future<Map<String, List<WatchingEntry>>> getLibraryLists() async {
    final jsonString = await rootBundle.loadString(
      'assets/anilist_data/viewer_data.json',
    );
    final Map<String, dynamic> json = jsonDecode(jsonString);
    final List<dynamic> lists = json['data']['MediaListCollection']['lists'];

    final Map<String, List<WatchingEntry>> library = {};

    for (var list in lists) {
      final String name = list['name'];
      final List<dynamic> entries = list['entries'];
      library[name] = entries.map((e) {
        return WatchingEntry(
          id: e['id'],
          progress: e['progress'] ?? 0,
          userScore: e['score'] ?? 0,
          anime: Anime.fromJson(e['media']),
        );
      }).toList();
    }

    // Reorder lists to: Watching, Planning, Completed, Dropped
    final orderedLibrary = <String, List<WatchingEntry>>{};
    const desiredOrder = ['Watching', 'Planning', 'Completed', 'Dropped'];

    for (final listName in desiredOrder) {
      if (library.containsKey(listName)) {
        orderedLibrary[listName] = library[listName]!;
      }
    }

    // Add any remaining lists that weren't in the desired order
    for (final entry in library.entries) {
      if (!orderedLibrary.containsKey(entry.key)) {
        orderedLibrary[entry.key] = entry.value;
      }
    }

    return orderedLibrary;
  }

  /// Loads the list of currently trending anime.
  ///
  /// Returns a list of [Anime] objects sorted by current popularity.
  /// This data is pre-fetched from the AniList trending query.
  Future<List<Anime>> getTrendingAnime() async {
    final jsonString = await rootBundle.loadString(
      'assets/anilist_data/home_data.json',
    );
    final Map<String, dynamic> json = jsonDecode(jsonString);
    final List<dynamic> media = json['data']['trending']['media'];
    return media.map((e) => Anime.fromJson(e)).toList();
  }

  // Popular list removed as requested to reduce load

  /// Loads detailed information for a specific anime by ID.
  ///
  /// [id] The AniList media ID of the anime to load.
  ///
  /// Returns full anime details including characters, studios, and recommendations.
  /// Returns null if the anime details cannot be loaded.
  ///
  /// Currently supports specific IDs with pre-fetched data:
  /// - 20: Naruto
  /// - 1735: Naruto Shippuden
  /// - 154587: Frieren
  /// - 21: One Piece
  /// - Others: Defaults to Naruto for testing
  Future<Anime?> getAnimeDetails(int id) async {
    // Determine which file to load based on the ID
    String fileName;

    if (id == 20) {
      fileName = 'media_details_naruto.json';
    } else if (id == 1735) {
      fileName = 'media_details_naruto_shippuden.json';
    } else if (id == 154587) {
      fileName = 'media_details_frieren.json';
    } else if (id == 21) {
      fileName = 'media_details_one_piece.json';
    } else {
      // Fallback for testing generic clicks, default to Naruto for robust details
      fileName = 'media_details_naruto.json';
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/anilist_data/$fileName',
      );
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return Anime.fromJson(json['data']['Media']);
    } catch (e) {
      debugPrint('Error loading details for ID $id: $e');
      return null;
    }
  }

  /// Searches for anime matching the given query.
  ///
  /// [query] The search term to match against anime titles.
  ///
  /// Returns a list of matching [Anime] objects.
  /// Returns an empty list if no results are found or an error occurs.
  ///
  /// Note: This is a simplified mock implementation. In production, this would
  /// support advanced filters like genre, year, status, etc.
  Future<List<Anime>> searchAnime(String query) async {
    // Determine which mock file to use based on query
    String fileName = 'search_results_naruto.json';

    // Simple mock logic for testing filters
    if (query.toLowerCase().contains('2023') ||
        query.toLowerCase().contains('winter')) {
      fileName = 'search_results_2023_winter.json';
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/anilist_data/$fileName',
      );
      final Map<String, dynamic> json = jsonDecode(jsonString);
      // Handle the slightly different structure if necessary, but usually Page -> media
      final List<dynamic> media = json['data']['Page']['media'];
      return media.map((e) => Anime.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error searching anime: $e');
      return [];
    }
  }

  /// Retrieves the names of all available lists in the user's library.
  ///
  /// Returns a list of list names (e.g., "Watching", "Completed", "Planning").
  /// Used for populating list selection dialogs.
  Future<List<String>> getAvailableListNames() async {
    final jsonString = await rootBundle.loadString(
      'assets/anilist_data/viewer_data.json',
    );
    final Map<String, dynamic> json = jsonDecode(jsonString);
    final List<dynamic> lists = json['data']['MediaListCollection']['lists'];

    return lists.map((list) => list['name'] as String).toList();
  }

  /// Check if an anime is in the user's library and return the entry
  Future<WatchingEntry?> getMediaListEntry(int animeId) async {
    final jsonString = await rootBundle.loadString(
      'assets/anilist_data/viewer_data.json',
    );
    final Map<String, dynamic> json = jsonDecode(jsonString);
    final List<dynamic> lists = json['data']['MediaListCollection']['lists'];

    for (var list in lists) {
      final List<dynamic> entries = list['entries'];
      for (var entry in entries) {
        if (entry['media']['id'] == animeId) {
          return WatchingEntry(
            id: entry['id'],
            progress: entry['progress'] ?? 0,
            userScore: entry['score'] ?? 0,
            anime: Anime.fromJson(entry['media']),
          );
        }
      }
    }
    return null;
  }

  /// Saves or updates an anime entry in the user's library.
  ///
  /// [animeId] The AniList media ID of the anime.
  /// [listName] The target list name (e.g., "Watching", "Completed").
  /// [progress] The current episode progress.
  ///
  /// This is a mock mutation that logs the action.
  /// In a production app, this would make an actual API call to AniList's
  /// SaveMediaListEntry mutation.
  Future<void> saveMediaListEntry(
    int animeId,
    String listName,
    int progress,
  ) async {
    debugPrint(
      'Mock mutation: Saving anime $animeId to list "$listName" with progress $progress',
    );
    // In a real implementation, this would make an API call
    // For now, we just log the action
  }

  /// Updates the episode progress for an anime with automatic status management.
  ///
  /// [animeId] The AniList media ID of the anime.
  /// [progress] The new episode progress count.
  /// [totalEpisodes] The total number of episodes (if known).
  ///
  /// Automatically moves the anime to "Completed" when progress reaches totalEpisodes.
  /// This is a mock mutation that logs the action.
  ///
  /// In a production app, this would make an actual API call to update the entry
  /// and potentially move it between lists based on the new progress.
  Future<void> updateEpisodeProgress(
    int animeId,
    int progress,
    int? totalEpisodes,
  ) async {
    String targetList = 'Current';

    // Auto-update to Completed if all episodes are watched
    if (totalEpisodes != null && progress >= totalEpisodes) {
      targetList = 'Completed';
    }

    debugPrint(
      'Mock mutation: Updating anime $animeId progress to $progress (target list: $targetList)',
    );
    // In a real implementation, this would make an API call
  }
}
