class AnimeModel {
  final String id;
  final String? malId;
  final String title;
  final String? nativeTitle;
  final String? image;
  final String? cover;
  final String? description;
  final String? status;
  final List<String> genres;
  final double? score;
  final int? episodes;
  final int? duration;
  final String? type;
  final int? releaseYear;
  final int? popularity;
  final int? currentEpisode;
  final AiringEpisode? nextAiringEpisode;

  AnimeModel({
    required this.id,
    this.malId,
    required this.title,
    this.nativeTitle,
    this.image,
    this.cover,
    this.description,
    this.status,
    this.genres = const [],
    this.score,
    this.episodes,
    this.duration,
    this.type,
    this.releaseYear,
    this.popularity,
    this.currentEpisode,
    this.nextAiringEpisode,
  });

  factory AnimeModel.fromConsumetMap(Map<String, dynamic> json) {
    final titleData = json['title'];
    String title;
    if (titleData is Map) {
      title = titleData['userPreferred'] ?? titleData['english'] ?? titleData['romaji'] ?? 'Unknown';
    } else {
      title = titleData?.toString() ?? 'Unknown';
    }

    Object? rawGenres = json['genres'];
    List<String> genres = [];
    if (rawGenres is String) {
      genres = rawGenres.split(',').map((g) => g.trim()).toList();
    } else if (rawGenres is List) {
      genres = rawGenres.map((g) => g.toString()).toList();
    }

    return AnimeModel(
      id: json['id']?.toString() ?? '',
      malId: json['malId']?.toString(),
      title: title,
      nativeTitle: titleData is Map ? titleData['native']?.toString() : null,
      image: json['image']?.toString(),
      cover: json['cover']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString(),
      genres: genres,
      score: _parseDouble(json['rating'] ?? json['score']),
      episodes: _parseInt(json['totalEpisodes'] ?? json['episodes']),
      duration: _parseInt(json['duration']),
      type: json['type']?.toString(),
      releaseYear: _parseInt(json['releaseDate'] ?? json['releaseYear']),
      popularity: _parseInt(json['popularity']),
      currentEpisode: _parseInt(json['currentEpisode']),
      nextAiringEpisode: json['nextAiringEpisode'] != null
          ? AiringEpisode.fromMap(json['nextAiringEpisode'])
          : null,
    );
  }

  factory AnimeModel.fromAnilistMap(Map<String, dynamic> json) {
    final titleData = json['title'];
    return AnimeModel(
      id: json['id']?.toString() ?? '',
      title: titleData is Map
          ? (titleData['english'] ?? titleData['romaji'] ?? 'Unknown')
          : 'Unknown',
      nativeTitle: titleData is Map ? titleData['native']?.toString() : null,
      image: json['coverImage'] is Map
          ? (json['coverImage']['extraLarge'] ?? json['coverImage']['large'])
          : null,
      cover: json['bannerImage']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString(),
      genres: (json['genres'] as List?)?.map((g) => g.toString()).toList() ?? [],
      score: _parseDouble(json['averageScore']),
      episodes: _parseInt(json['episodes']),
      duration: _parseInt(json['duration']),
      type: json['type']?.toString(),
      releaseYear: json['startDate'] is Map ? _parseInt(json['startDate']['year']) : null,
      popularity: _parseInt(json['popularity']),
      nextAiringEpisode: json['nextAiringEpisode'] != null
          ? AiringEpisode.fromMap(json['nextAiringEpisode'])
          : null,
    );
  }

  static double? _parseDouble(Object? value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? _parseInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class AiringEpisode {
  final int episode;
  final int airingAt;

  AiringEpisode({required this.episode, required this.airingAt});

  factory AiringEpisode.fromMap(Map<String, dynamic> json) {
    return AiringEpisode(
      episode: json['episode'] ?? json['episodeNumber'] ?? 0,
      airingAt: json['airingAt'] ?? 0,
    );
  }
}
