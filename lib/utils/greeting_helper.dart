import 'package:octolist/utils/vibe_level.dart';

/// Helper class to determine greetings based on time of day and vibe score.
class GreetingHelper {
  GreetingHelper._();

  // Cache for greeting data
  static GreetingData? _cachedGreeting;
  static TimeRange? _cachedTimeRange;
  static VibeLevel? _cachedVibeLevel;

  /// Returns a [GreetingData] object containing the main title and subtitle
  /// for the current time and vibe.
  static GreetingData getGreeting(VibeLevel vibeLevel) {
    final timeRange = _getTimeRange();

    // Return cached value if time range and vibe level haven't changed
    if (_cachedGreeting != null &&
        _cachedTimeRange == timeRange &&
        _cachedVibeLevel == vibeLevel) {
      return _cachedGreeting!;
    }

    final greeting =
        _greetings[vibeLevel]?[timeRange] ??
        const GreetingData('Hello.', 'Welcome back.');

    // Update cache
    _cachedGreeting = greeting;
    _cachedTimeRange = timeRange;
    _cachedVibeLevel = vibeLevel;

    return greeting;
  }

  static TimeRange _getTimeRange() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return TimeRange.morning;
    if (hour >= 12 && hour < 18) return TimeRange.afternoon;
    if (hour >= 18) return TimeRange.evening;
    return TimeRange.deepNight;
  }

  static const Map<VibeLevel, Map<TimeRange, GreetingData>> _greetings = {
    VibeLevel.radiant: {
      TimeRange.morning: GreetingData(
        'Rise and shine!',
        'A new adventure awaits! ☀️',
      ),
      TimeRange.afternoon: GreetingData(
        'The sun is high!',
        'Time for a snack and a show? 🍰',
      ),
      TimeRange.evening: GreetingData(
        'Rest well!',
        'Dream of magic and starlight. ✨',
      ),
      TimeRange.deepNight: GreetingData(
        'Still awake?',
        'Just one more episode! 🌙',
      ),
    },
    VibeLevel.neutral: {
      TimeRange.morning: GreetingData(
        'Good morning.',
        'Ready to update your list?',
      ),
      TimeRange.afternoon: GreetingData(
        'Checking in?',
        'Here is what\'s trending today.',
      ),
      TimeRange.evening: GreetingData(
        'Settling in?',
        'What\'s on the menu tonight?',
      ),
      TimeRange.deepNight: GreetingData(
        'Burning the midnight oil, are we?',
        '',
      ),
    },
    VibeLevel.grim: {
      TimeRange.morning: GreetingData(
        'The sun rises,',
        'but the shadows linger.',
      ),
      TimeRange.afternoon: GreetingData(
        'The glare is harsh.',
        'Hide away for a while.',
      ),
      TimeRange.evening: GreetingData(
        'The day ends.',
        'Now, the real stories begin.',
      ),
      TimeRange.deepNight: GreetingData(
        'The world is quiet.',
        'Only you and the screen.',
      ),
    },
    VibeLevel.abyssal: {
      TimeRange.morning: GreetingData('You survived the night...', 'for now.'),
      TimeRange.afternoon: GreetingData(
        'Noon offers no protection.',
        'We see you.',
      ),
      TimeRange.evening: GreetingData(
        'Surrender to the dark.',
        'The void is watching.',
      ),
      TimeRange.deepNight: GreetingData(
        'Go to sleep.',
        'Before something else wakes up.',
      ),
    },
  };
}

enum TimeRange { morning, afternoon, evening, deepNight }

class GreetingData {
  final String title;
  final String subtitle;

  const GreetingData(this.title, this.subtitle);
}
