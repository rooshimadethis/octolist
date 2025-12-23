import 'package:flutter/foundation.dart';
import '../models/watching_entry.dart';
import 'anime_service_interface.dart';
import 'anilist_service.dart';

/// Single source of truth for Anime data and User Library.
class AnimeStore extends ChangeNotifier {
  final IAnimeService _service;

  AnimeStore({IAnimeService? service}) : _service = service ?? AniListService();

  IAnimeService get service => _service;

  // Primary store: Media ID -> WatchingEntry
  final Map<int, WatchingEntry> _allEntries = {};

  // List memberships: List Name -> List of Media IDs
  final Map<String, List<int>> _listMemberships = {};

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Get an entry by its media ID.
  WatchingEntry? getEntry(int mediaId) => _allEntries[mediaId];

  /// Get all entries for a specific list.
  List<WatchingEntry> getListEntries(String listName) {
    final ids = _listMemberships[listName] ?? [];
    return ids.map((id) => _allEntries[id]).whereType<WatchingEntry>().toList();
  }

  /// Get the names of all lists in the user's library.
  List<String> get listNames => _listMemberships.keys.toList()
    ..sort((a, b) {
      const order = [
        'Watching',
        'Planning',
        'Completed',
        'Dropped',
        'Paused',
        'Rewatching',
      ];
      int indexA = order.indexOf(a);
      int indexB = order.indexOf(b);
      if (indexA == -1) indexA = 999;
      if (indexB == -1) indexB = 999;
      return indexA.compareTo(indexB);
    });

  /// Initial load of the library.
  Future<void> fetchLibrary() async {
    _isLoading = true;
    _error = null;
    // Defer notification to avoid "setState() or markNeedsBuild() called during build"
    Future.microtask(() => notifyListeners());

    try {
      final library = await _service.getLibraryLists();

      _allEntries.clear();
      _listMemberships.clear();

      library.forEach((listName, entries) {
        final ids = <int>[];
        for (var entry in entries) {
          _allEntries[entry.anime.id] = entry;
          ids.add(entry.anime.id);
        }
        _listMemberships[listName] = ids;
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Updates the episode progress for an anime.
  /// This handles optimistic updates and syncing with AniList.
  Future<void> updateProgress(int mediaId, int delta) async {
    final entry = _allEntries[mediaId];
    if (entry == null) return;

    final oldEntry = entry;
    final newProgress = (entry.progress + delta).clamp(
      0,
      entry.anime.episodes ?? 999,
    );

    if (newProgress == entry.progress) return;

    // Optimistic Update
    final updatedEntry = entry.copyWith(progress: newProgress);
    _allEntries[mediaId] = updatedEntry;

    // Check if status needs to change (e.g. Completed)
    if (newProgress >= (entry.anime.episodes ?? 999)) {
      _moveToStatus(mediaId, 'Completed');
    } else if (newProgress > 0 && _isStatus(mediaId, 'Planning')) {
      _moveToStatus(mediaId, 'Watching');
    }

    notifyListeners();

    try {
      await _service.updateEpisodeProgress(
        mediaId,
        newProgress,
        entry.anime.episodes,
      );
      // Backend update successful, _service already broadcasts but our store is the source now
    } catch (e) {
      // Revert on failure
      _allEntries[mediaId] = oldEntry;
      // We'd also need to revert status moves if we wanted to be perfect,
      // but status moves are usually one-way and rarer.
      notifyListeners();
      rethrow;
    }
  }

  /// Save or update an entry to a specific list status.
  Future<void> saveToStatus(int mediaId, String status) async {
    // TODO: Implement list status changes in Store
    // This will require calling saveMediaListEntry and updating local memberships.
    await _service.saveMediaListEntry(
      mediaId,
      status,
      getEntry(mediaId)?.progress ?? 0,
    );
    await fetchLibrary(); // Easiest way to sync complex list moves for now
  }

  void _moveToStatus(int mediaId, String targetStatus) {
    // Basic local move logic
    _listMemberships.forEach((status, ids) {
      ids.remove(mediaId);
    });

    if (!_listMemberships.containsKey(targetStatus)) {
      _listMemberships[targetStatus] = [];
    }
    _listMemberships[targetStatus]!.add(mediaId);
  }

  bool _isStatus(int mediaId, String status) {
    return _listMemberships[status]?.contains(mediaId) ?? false;
  }
}
