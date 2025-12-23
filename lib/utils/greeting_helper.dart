/// Utility functions for generating time-based greetings
class GreetingHelper {
  GreetingHelper._();

  /// Returns a greeting based on the current time of day
  /// - Morning: before 12:00
  /// - Afternoon: 12:00 - 16:59
  /// - Evening: 17:00 onwards
  static String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
