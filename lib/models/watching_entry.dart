import '../models/anime.dart';

/// Represents a user's watching entry with progress and score information.
///
/// This combines anime metadata with user-specific tracking data.
class WatchingEntry {
  final Anime anime;
  final int progress;
  final int userScore;
  final int id; // The entry ID, not media ID
  final int? updatedAt;

  WatchingEntry({
    required this.anime,
    required this.progress,
    required this.userScore,
    required this.id,
    this.updatedAt,
  });

  WatchingEntry copyWith({
    Anime? anime,
    int? progress,
    int? userScore,
    int? id,
    int? updatedAt,
  }) {
    return WatchingEntry(
      anime: anime ?? this.anime,
      progress: progress ?? this.progress,
      userScore: userScore ?? this.userScore,
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
