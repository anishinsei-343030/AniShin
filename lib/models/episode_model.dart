class EpisodeModel {
  final String id;
  final double number;
  final String? title;
  final String? image;
  final String? releaseDate;
  final int? duration;
  final bool? isFiller;

  EpisodeModel({
    required this.id,
    required this.number,
    this.title,
    this.image,
    this.releaseDate,
    this.duration,
    this.isFiller,
  });

  factory EpisodeModel.fromMap(Map<String, dynamic> json) {
    return EpisodeModel(
      id: json['id']?.toString() ?? '',
      number: (json['number'] ?? 0).toDouble(),
      title: json['title']?.toString(),
      image: json['image']?.toString() ?? json['img']?.toString(),
      releaseDate: json['releaseDate']?.toString() ?? json['airDate']?.toString(),
      duration: json['duration'] is int ? json['duration'] as int : null,
      isFiller: json['isFiller'] as bool? ?? json['filler'] as bool? ?? false,
    );
  }
}

class VideoSource {
  final String url;
  final String? quality;
  final bool isM3U8;
  final Map<String, String>? headers;

  VideoSource({
    required this.url,
    this.quality,
    this.isM3U8 = false,
    this.headers,
  });

  factory VideoSource.fromMap(Map<String, dynamic> json) {
    return VideoSource(
      url: json['url']?.toString() ?? '',
      quality: json['quality']?.toString(),
      isM3U8: json['isM3U8'] == true || json['isM3U8'] == 'true',
      headers: (json['headers'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v.toString())),
    );
  }
}

class SubtitleTrack {
  final String url;
  final String? lang;

  SubtitleTrack({required this.url, this.lang});

  factory SubtitleTrack.fromMap(Map<String, dynamic> json) {
    return SubtitleTrack(
      url: json['url']?.toString() ?? '',
      lang: json['lang']?.toString(),
    );
  }
}

class StreamResponse {
  final List<VideoSource> sources;
  final List<SubtitleTrack>? subtitles;
  final Map<String, String>? headers;
  final String? introStart;
  final String? introEnd;

  StreamResponse({
    required this.sources,
    this.subtitles,
    this.headers,
    this.introStart,
    this.introEnd,
  });

  factory StreamResponse.fromMap(Map<String, dynamic> json) {
    return StreamResponse(
      sources: (json['sources'] as List?)
              ?.map((s) => VideoSource.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
      subtitles: (json['subtitles'] as List?)
          ?.map((s) => SubtitleTrack.fromMap(s as Map<String, dynamic>))
          .toList(),
      headers: (json['headers'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v.toString())),
      introStart: json['intro'] is Map ? json['intro']['start']?.toString() : null,
      introEnd: json['intro'] is Map ? json['intro']['end']?.toString() : null,
    );
  }
}
