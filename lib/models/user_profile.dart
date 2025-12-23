class UserProfile {
  final int id;
  final String name;
  final String avatarMedium;
  final String avatarLarge;
  final UserProfileStats? stats;

  UserProfile({
    required this.id,
    required this.name,
    required this.avatarMedium,
    required this.avatarLarge,
    this.stats,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final avatar = json['avatar'] ?? {};
    final statsJson = json['statistics']?['anime'];
    return UserProfile(
      id: json['id'],
      name: json['name'] ?? 'Guest',
      avatarMedium: avatar['medium'] ?? '',
      avatarLarge: avatar['large'] ?? '',
      stats: statsJson != null ? UserProfileStats.fromJson(statsJson) : null,
    );
  }
}

class UserProfileStats {
  final int count;
  final int minutesWatched;
  final int episodesWatched;
  final int meanScore;
  final List<UserStatusCount> statuses;

  UserProfileStats({
    required this.count,
    required this.minutesWatched,
    required this.episodesWatched,
    required this.meanScore,
    required this.statuses,
  });

  factory UserProfileStats.fromJson(Map<String, dynamic> json) {
    final statusList = json['statuses'] as List<dynamic>? ?? [];
    return UserProfileStats(
      count: json['count'] ?? 0,
      minutesWatched: json['minutesWatched'] ?? 0,
      episodesWatched: json['episodesWatched'] ?? 0,
      meanScore: json['meanScore'] ?? 0,
      statuses: statusList.map((e) => UserStatusCount.fromJson(e)).toList(),
    );
  }
}

class UserStatusCount {
  final int count;
  final String status;

  UserStatusCount({required this.count, required this.status});

  factory UserStatusCount.fromJson(Map<String, dynamic> json) {
    return UserStatusCount(
      count: json['count'] ?? 0,
      status: json['status'] ?? '',
    );
  }
}
