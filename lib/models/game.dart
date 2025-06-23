import 'package:flutter/material.dart';

class Game {
  final int id;
  final String name;
  final String? backgroundImage;
  final double? rating;
  final int? ratingTop;
  final int? ratingsCount;
  final String? released;
  final List<Genre> genres;
  final List<Platform> platforms;
  final String? description;
  final List<String> screenshots;
  final int? metacriticScore;
  final String? website;

  Game({
    required this.id,
    required this.name,
    this.backgroundImage,
    this.rating,
    this.ratingTop,
    this.ratingsCount,
    this.released,
    this.genres = const [],
    this.platforms = const [],
    this.description,
    this.screenshots = const [],
    this.metacriticScore,
    this.website,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      backgroundImage: json['background_image'],
      rating: (json['rating'] as num?)?.toDouble(),
      ratingTop: json['rating_top'],
      ratingsCount: json['ratings_count'],
      released: json['released'],
      genres: (json['genres'] as List<dynamic>?)
          ?.map((g) => Genre.fromJson(g))
          .toList() ?? [],
      platforms: (json['platforms'] as List<dynamic>?)
          ?.map((p) => Platform.fromJson(p['platform'] ?? p))
          .toList() ?? [],
      description: json['description_raw'] ?? json['description'],
      screenshots: (json['short_screenshots'] as List<dynamic>?)
          ?.map((s) => s['image'] as String)
          .toList() ?? [],
      metacriticScore: json['metacritic'],
      website: json['website'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'background_image': backgroundImage,
      'rating': rating,
      'rating_top': ratingTop,
      'ratings_count': ratingsCount,
      'released': released,
      'genres': genres.map((g) => g.toJson()).toList(),
      'platforms': platforms.map((p) => p.toJson()).toList(),
      'description_raw': description,
      'short_screenshots': screenshots.map((s) => {'image': s}).toList(),
      'metacritic': metacriticScore,
      'website': website,
    };
  }
}

class Genre {
  final int id;
  final String name;
  final String? slug;
  final String? imageBackground;

  Genre({
    required this.id,
    required this.name,
    this.slug,
    this.imageBackground,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'],
      imageBackground: json['image_background'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'image_background': imageBackground,
    };
  }
}

class Platform {
  final int id;
  final String name;
  final String? slug;
  final String? imageBackground;

  Platform({
    required this.id,
    required this.name,
    this.slug,
    this.imageBackground,
  });

  factory Platform.fromJson(Map<String, dynamic> json) {
    return Platform(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'],
      imageBackground: json['image_background'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'image_background': imageBackground,
    };
  }
}

// Cores para diferentes gêneros de jogos
const Map<String, Color> genreColors = {
  'action': Color(0xFFE91E63),
  'adventure': Color(0xFF4CAF50),
  'racing': Color(0xFFFF9800),
  'role-playing-games-rpg': Color(0xFF9C27B0),
  'shooter': Color(0xFFF44336),
  'sports': Color(0xFF2196F3),
  'strategy': Color(0xFF607D8B),
  'puzzle': Color(0xFFFFEB3B),
  'arcade': Color(0xFFFF5722),
  'platformer': Color(0xFF8BC34A),
  'fighting': Color(0xFF795548),
  'simulation': Color(0xFF00BCD4),
  'indie': Color(0xFF673AB7),
  'massively-multiplayer': Color(0xFF3F51B5),
  'family': Color(0xFFCDDC39),
  'board-games': Color(0xFF009688),
  'educational': Color(0xFFFFC107),
  'casual': Color(0xFFE040FB),
};

extension GameExtensions on Game {
  String get formattedRating {
    if (rating != null) {
      return rating!.toStringAsFixed(1);
    }
    return 'N/A';
  }

  String get formattedReleaseDate {
    if (released != null && released!.isNotEmpty) {
      try {
        final date = DateTime.parse(released!);
        return '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        return released!;
      }
    }
    return 'Data não disponível';
  }

  String get platformsString {
    if (platforms.isEmpty) return 'Plataforma não informada';
    return platforms.map((p) => p.name).join(', ');
  }

  String get genresString {
    if (genres.isEmpty) return 'Gênero não informado';
    return genres.map((g) => g.name).join(', ');
  }
}
