import 'dart:math';
import 'vibe_level.dart';

/// Helper class to determine text strings based on vibe score.
class VibeTextHelper {
  VibeTextHelper._();

  // Shared Random instance to avoid creating new instances
  static final Random _random = Random();

  // Cache for random selections to avoid recalculating on every build
  static String? _cachedSearchHint;
  static VibeLevel? _cachedSearchHintLevel;

  static String? _cachedContinueWatchingHeader;
  static VibeLevel? _cachedContinueWatchingLevel;

  static String? _cachedTrendingNowHeader;
  static VibeLevel? _cachedTrendingNowLevel;

  /// Returns a random search hint text based on vibe score.
  static String getSearchHint(VibeLevel vibeLevel) {
    // Return cached value if vibe level hasn't changed
    if (_cachedSearchHint != null && _cachedSearchHintLevel == vibeLevel) {
      return _cachedSearchHint!;
    }

    final options = _searchHints[vibeLevel] ?? ['Find anime...'];
    _cachedSearchHint = options[_random.nextInt(options.length)];
    _cachedSearchHintLevel = vibeLevel;
    return _cachedSearchHint!;
  }

  /// Returns a random header text for "Continue Watching" based on vibe score.
  static String getContinueWatchingHeader(VibeLevel vibeLevel) {
    // Return cached value if vibe level hasn't changed
    if (_cachedContinueWatchingHeader != null &&
        _cachedContinueWatchingLevel == vibeLevel) {
      return _cachedContinueWatchingHeader!;
    }

    final options =
        _continueWatchingHeaders[vibeLevel] ?? ['Continue Watching'];
    _cachedContinueWatchingHeader = options[_random.nextInt(options.length)];
    _cachedContinueWatchingLevel = vibeLevel;
    return _cachedContinueWatchingHeader!;
  }

  /// Returns a random header text for "Trending Now" based on vibe score.
  static String getTrendingNowHeader(VibeLevel vibeLevel) {
    // Return cached value if vibe level hasn't changed
    if (_cachedTrendingNowHeader != null &&
        _cachedTrendingNowLevel == vibeLevel) {
      return _cachedTrendingNowHeader!;
    }

    final options = _trendingNowHeaders[vibeLevel] ?? ['Trending Now'];
    _cachedTrendingNowHeader = options[_random.nextInt(options.length)];
    _cachedTrendingNowLevel = vibeLevel;
    return _cachedTrendingNowHeader!;
  }

  static const Map<VibeLevel, List<String>> _searchHints = {
    VibeLevel.radiant: ['Search for your next favorite memory!'],
    VibeLevel.neutral: ['Find a series or movie.'],
    VibeLevel.grim: ['What truth are you seeking?'],
    VibeLevel.abyssal: ['Type the name. Invoke the nightmare.'],
  };

  static const Map<VibeLevel, List<String>> _continueWatchingHeaders = {
    VibeLevel.radiant: [
      'Where the magic left off! ✨',
      'Your friends are waiting!',
    ],
    VibeLevel.neutral: ['Resume Playback', 'Back to the Story'],
    VibeLevel.grim: ['The descent continues...', 'Finish what you started.'],
    VibeLevel.abyssal: [
      'Return to the madness.',
      'No turning back now.',
      'Feed the obsession.',
    ],
  };

  static const Map<VibeLevel, List<String>> _trendingNowHeaders = {
    VibeLevel.radiant: [
      'Everyone\'s talking about these! 🌟',
      'Join the hype train!',
    ],
    VibeLevel.neutral: ['Popular This Week', 'Top Charts'],
    VibeLevel.grim: [
      'Others are suffering, too.',
      'Spreading like a contagion.',
    ],
    VibeLevel.abyssal: [
      'The masses are screaming for these.',
      'Current Delusions',
      'Witness the collective rot.',
    ],
  };
}
