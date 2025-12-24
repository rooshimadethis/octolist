import 'dart:math';

/// Helper class to determine text strings based on vibe score.
class VibeTextHelper {
  VibeTextHelper._();

  /// Returns a random search hint text based on vibe score.
  static String getSearchHint({double vibeScore = 0.0}) {
    final vibeLevel = _getVibeLevel(vibeScore);
    final options = _searchHints[vibeLevel] ?? ['Find anime...'];
    return options[Random().nextInt(options.length)];
  }

  /// Returns a random header text for "Continue Watching" based on vibe score.
  static String getContinueWatchingHeader({double vibeScore = 0.0}) {
    final vibeLevel = _getVibeLevel(vibeScore);
    final options =
        _continueWatchingHeaders[vibeLevel] ?? ['Continue Watching'];
    return options[Random().nextInt(options.length)];
  }

  /// Returns a random header text for "Trending Now" based on vibe score.
  static String getTrendingNowHeader({double vibeScore = 0.0}) {
    final vibeLevel = _getVibeLevel(vibeScore);
    final options = _trendingNowHeaders[vibeLevel] ?? ['Trending Now'];
    return options[Random().nextInt(options.length)];
  }

  static VibeLevel _getVibeLevel(double score) {
    if (score < 0.25) return VibeLevel.radiant;
    if (score < 0.50) return VibeLevel.neutral;
    if (score < 0.75) return VibeLevel.grim;
    return VibeLevel.abyssal;
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

enum VibeLevel { radiant, neutral, grim, abyssal }
