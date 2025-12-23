import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/anime.dart';
import '../models/user_profile.dart';
import '../models/watching_entry.dart';
import 'anime_service_interface.dart';

/// Service for loading mock AniList data from JSON assets.
///
/// This service simulates API calls by loading pre-fetched JSON data from the assets folder.
/// In a production app, these methods would make actual HTTP requests to the AniList GraphQL API.
class MockDataService implements IAnimeService {
  /// Loads the current user's profile information.
  @override
  Future<UserProfile?> getUserProfile() async {
    final jsonString = await rootBundle.loadString(
      'assets/anilist_data/viewer_data.json',
    );
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return UserProfile.fromJson(json['data']['Viewer']);
  }

  /// Loads the user's currently watching anime list.
  @override
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
  @override
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
  @override
  Future<List<Anime>> getTrendingAnime() async {
    final jsonString = await rootBundle.loadString(
      'assets/anilist_data/home_data.json',
    );
    final Map<String, dynamic> json = jsonDecode(jsonString);
    final List<dynamic> media = json['data']['trending']['media'];
    return media.map((e) => Anime.fromJson(e)).toList();
  }

  /// Loads detailed information for a specific anime by ID.
  @override
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
  @override
  Future<List<Anime>> searchAnime(String query) async {
    String fileName = 'search_results_naruto.json';

    if (query.toLowerCase().contains('2023') ||
        query.toLowerCase().contains('winter')) {
      fileName = 'search_results_2023_winter.json';
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/anilist_data/$fileName',
      );
      final Map<String, dynamic> json = jsonDecode(jsonString);
      final List<dynamic> media = json['data']['Page']['media'];
      return media.map((e) => Anime.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error searching anime: $e');
      return [];
    }
  }

  /// Retrieves the names of all available lists in the user's library.
  @override
  Future<List<String>> getAvailableListNames() async {
    final jsonString = await rootBundle.loadString(
      'assets/anilist_data/viewer_data.json',
    );
    final Map<String, dynamic> json = jsonDecode(jsonString);
    final List<dynamic> lists = json['data']['MediaListCollection']['lists'];

    return lists.map((list) => list['name'] as String).toList();
  }

  /// Check if an anime is in the user's library and return the entry
  @override
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
  @override
  Future<void> saveMediaListEntry(
    int animeId,
    String listName,
    int progress,
  ) async {
    debugPrint(
      'Mock mutation: Saving anime $animeId to list "$listName" with progress $progress',
    );
  }

  /// Updates the episode progress for an anime with automatic status management.
  @override
  Future<void> updateEpisodeProgress(
    int animeId,
    int progress,
    int? totalEpisodes,
  ) async {
    String targetList = 'Current';

    if (totalEpisodes != null && progress >= totalEpisodes) {
      targetList = 'Completed';
    }

    debugPrint(
      'Mock mutation: Updating anime $animeId progress to $progress (target list: $targetList)',
    );
  }
}
