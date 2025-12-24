import 'package:flutter/material.dart';

class Character {
  final int id;
  final String name;
  final String image;
  final String role;

  Character({
    required this.id,
    required this.name,
    required this.image,
    required this.role,
  });

  factory Character.fromEdge(Map<String, dynamic> edge) {
    final node = edge['node'] ?? {};
    final name = node['name'] ?? {};
    final image = node['image'] ?? {};
    return Character(
      id: node['id'] ?? 0,
      name: name['full'] ?? 'Unknown',
      image: image['medium'] ?? image['large'] ?? '',
      role: edge['role'] ?? '',
    );
  }
}

class Studio {
  final int id;
  final String name;

  Studio({required this.id, required this.name});

  factory Studio.fromJson(Map<String, dynamic> json) {
    return Studio(id: json['id'] ?? 0, name: json['name'] ?? 'Unknown');
  }
}

class Anime {
  final int id;
  final String title;
  final String? coverImage;
  final String? bannerImage;
  final int? averageScore;
  final int? episodes;
  final List<String> genres;
  final String? color;

  // Cached parsed color to avoid redundant parsing
  Color? _cachedParsedColor;
  Color get parsedColor {
    if (color == null) return Colors.black;
    if (_cachedParsedColor != null) return _cachedParsedColor!;

    try {
      _cachedParsedColor = Color(int.parse(color!.replaceAll('#', '0xFF')));
      return _cachedParsedColor!;
    } catch (_) {
      _cachedParsedColor = Colors.black;
      return Colors.black;
    }
  }

  final String? description;
  final List<Character> characters;
  final List<Studio> studios;
  final List<Anime> recommendations;
  final String? season;
  final int? seasonYear;
  final String? status;
  final bool isAdult;
  final List<RelatedMedia> relations;

  Anime({
    required this.id,
    required this.title,
    this.coverImage,
    this.bannerImage,
    this.averageScore,
    this.episodes,
    this.genres = const [],
    this.color,
    this.description,
    this.characters = const [],
    this.studios = const [],
    this.recommendations = const [],
    this.season,
    this.seasonYear,
    this.status,
    this.isAdult = false,
    this.relations = const [],
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    final titleObj = json['title'] ?? {};
    final coverObj = json['coverImage'] ?? {};

    return Anime(
      id: json['id'],
      title:
          titleObj['english'] ??
          titleObj['romaji'] ??
          titleObj['native'] ??
          'Unknown',
      coverImage:
          coverObj['extraLarge'] ?? coverObj['large'] ?? coverObj['medium'],
      bannerImage: json['bannerImage'],
      averageScore: json['averageScore'],
      episodes: json['episodes'],
      genres: json['genres'] != null ? List<String>.from(json['genres']) : [],
      color: coverObj['color'],
      description: json['description'],
      season: json['season'],
      seasonYear: json['seasonYear'],
      status: json['status'],
      isAdult: json['isAdult'] ?? false,
      characters: json['characters'] != null
          ? (json['characters']['edges'] as List)
                .map((e) => Character.fromEdge(e))
                .toList()
          : [],
      studios: json['studios'] != null
          ? (json['studios']['nodes'] as List)
                .map((e) => Studio.fromJson(e))
                .toList()
          : [],
      recommendations: json['recommendations'] != null
          ? (json['recommendations']['nodes'] as List)
                .map((e) => Anime.fromRecommendation(e['mediaRecommendation']))
                .toList()
          : [],
      relations: json['relations'] != null
          ? (json['relations']['edges'] as List)
                .map((e) => RelatedMedia.fromJson(e))
                .toList()
          : [],
    );
  }

  factory Anime.fromRecommendation(Map<String, dynamic> json) {
    final titleObj = json['title'] ?? {};
    final coverObj = json['coverImage'] ?? {};
    return Anime(
      id: json['id'] ?? 0,
      title:
          titleObj['english'] ??
          titleObj['romaji'] ??
          titleObj['userPreferred'] ??
          'Unknown',
      coverImage:
          coverObj['extraLarge'] ?? coverObj['large'] ?? coverObj['medium'],
    );
  }
}

class RelatedMedia {
  final String relationType;
  final Anime anime;

  RelatedMedia({required this.relationType, required this.anime});

  factory RelatedMedia.fromJson(Map<String, dynamic> json) {
    return RelatedMedia(
      relationType: json['relationType'] ?? 'UNKNOWN',
      anime: Anime.fromJson(json['node']),
    );
  }
}
