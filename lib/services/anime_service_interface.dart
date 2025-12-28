import '../models/anime.dart';
import '../models/user_profile.dart';
import '../models/watching_entry.dart';
import 'discussion_service.dart';

abstract class IAnimeService {
  Future<UserProfile?> getUserProfile();
  Future<List<WatchingEntry>> getWatchingList();
  Future<Map<String, List<WatchingEntry>>> getLibraryLists();
  Future<Map<String, List<WatchingEntry>>> getLibraryListsWithUser(
    UserProfile user,
  );
  Future<List<Anime>> getTrendingAnime();
  Future<Anime?> getAnimeDetails(int id);
  Future<List<Anime>> searchAnime(String query);
  Future<List<String>> getAvailableListNames();
  Future<WatchingEntry?> getMediaListEntry(int animeId);
  Future<void> saveMediaListEntry(
    int animeId,
    String listName,
    int progress, {
    double? score,
  });
  Future<void> deleteMediaListEntry(int entryId);
  Future<void> updateEpisodeProgress(
    int animeId,
    int progress,
    int? totalEpisodes,
  );
  Future<List<DiscussionOption>> getDiscussionLinks(
    Anime anime,
    int episodeNumber,
  );
}
