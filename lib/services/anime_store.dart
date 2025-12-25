import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/vibe_level.dart';
import '../models/watching_entry.dart';
import '../models/anime.dart';
import '../models/user_profile.dart';
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

  double _vibeScore = 0.0;
  double get vibeScore => _vibeScore;
  set vibeScore(double value) {
    if (_vibeScore == value) return;
    _vibeScore = value.clamp(0.0, 1.0);
    _saveVibe();
    notifyListeners();
  }

  /// Get the current VibeLevel based on the score.
  VibeLevel get vibeLevel => getVibeLevel(_vibeScore);

  /// Load vibe score from persistent storage
  Future<void> initVibe() async {
    final prefs = await SharedPreferences.getInstance();
    _vibeScore = prefs.getDouble('vibe_score') ?? 0.0;
    notifyListeners();
  }

  /// Get an entry by its media ID.
  WatchingEntry? getEntry(int mediaId) => _allEntries[mediaId];

  /// Get all entries for a specific list.
  List<WatchingEntry> getListEntries(String listName) {
    final ids = _listMemberships[listName] ?? [];
    final entries = ids
        .map((id) => _allEntries[id])
        .whereType<WatchingEntry>()
        .toList();

    // Sort by updatedAt in descending order (most recent first)
    entries.sort((a, b) {
      final aTime = a.updatedAt ?? 0;
      final bTime = b.updatedAt ?? 0;
      return bTime.compareTo(aTime); // Descending order
    });

    return entries;
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

  /// Initial load of the library with a pre-fetched user profile.
  /// This avoids duplicate getUserProfile API calls.
  Future<void> fetchLibraryWithUser(UserProfile user) async {
    _isLoading = true;
    _error = null;
    // Defer notification to avoid "setState() or markNeedsBuild() called during build"
    Future.microtask(() => notifyListeners());

    try {
      final library = await _service.getLibraryListsWithUser(user);

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

    // Adjust Vibe
    _adjustVibe(entry.anime, delta);

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

  /// Updates the user score for an anime.
  Future<void> updateScore(int mediaId, double score) async {
    final entry = _allEntries[mediaId];
    if (entry == null) return;

    // Find current list status
    String? currentStatus;
    for (var listName in listNames) {
      if (_listMemberships[listName]?.contains(mediaId) ?? false) {
        currentStatus = listName;
        break;
      }
    }

    if (currentStatus == null) return;

    // Optimistic update
    final oldEntry = entry;
    final updatedEntry = entry.copyWith(userScore: score.toInt());
    _allEntries[mediaId] = updatedEntry;
    notifyListeners();

    try {
      await _service.saveMediaListEntry(
        mediaId,
        currentStatus,
        entry.progress,
        score: score,
      );
    } catch (e) {
      // Revert on failure
      _allEntries[mediaId] = oldEntry;
      notifyListeners();
      rethrow;
    }
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

  /// Genre intensity lookup table for vibe calculation
  /// Positive values = dark/serious, Negative values = light/cheerful
  static const Map<String, double> _genreIntensity = {
    // High Intensity Dark
    'Psychological': 1.0,
    'Horror': 1.0,
    'Thriller': 1.0,
    // Mild Dark
    'Drama': 0.5,
    'Mystery': 0.6,
    'Supernatural': 0.5,
    'Seinen': 0.6,
    // High Intensity Light
    'Comedy': -1.0,
    'Slice of Life': -1.0,
    // Mild Light
    'Romance': -0.6,
    'Music': -0.6,
    'Sports': -0.6,
    'Shoujo': -0.6,
  };

  void _adjustVibe(Anime anime, int delta) {
    if (delta == 0) return;

    // We want a full season (approx 12 episodes) of a "pure" show to shift the vibe 100%
    // So the max shift per episode should be around 1/12 = 0.0833
    const double maxShiftPerEpisode = 1.0 / 12.0;

    // Calculate total intensity from all genres using lookup table
    double intensity = 0.0;
    for (final genre in anime.genres) {
      intensity += _genreIntensity[genre] ?? 0.0;
    }

    // Normalize intensity to [-1.0, 1.0]
    // A show with multiple intense genres hits the cap, ensuring consistent "vibey-ness"
    final normalizedIntensity = intensity.clamp(-1.0, 1.0);

    // Final adjustment is intensity * maxShiftPerEpisode * delta
    final adjustment = normalizedIntensity * maxShiftPerEpisode * delta;

    final oldVibe = _vibeScore;
    _vibeScore = (_vibeScore + adjustment).clamp(0.0, 1.0);

    if (oldVibe != _vibeScore) {
      final genreLog = anime.genres
          .map((g) {
            final score = _genreIntensity[g] ?? 0.0;
            return '$g: $score';
          })
          .join(', ');

      debugPrint(
        '🔮 Vibe: ${oldVibe.toStringAsFixed(2)} → ${_vibeScore.toStringAsFixed(2)}\n'
        '   Intensity: ${normalizedIntensity.toStringAsFixed(2)}, Δ: ${adjustment.toStringAsFixed(2)}\n'
        '   Genres: [$genreLog]',
      );
      _saveVibe();
      // Note: notifyListeners() is already called by the parent updateProgress method
    }
  }

  Future<void> _saveVibe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('vibe_score', _vibeScore);
    } catch (e) {
      debugPrint('Error saving vibe score: $e');
    }
  }
}
