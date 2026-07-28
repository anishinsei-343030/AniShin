import 'package:dio/dio.dart';
import '../../models/anime_model.dart';
import '../../models/episode_model.dart';

class ConsumetApi {
  final Dio _dio;
  static const String _baseUrl = 'https://api.consumet.org';

  ConsumetApi()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'User-Agent': 'AnimeApp/1.0'},
        ));

  Future<List<AnimeModel>> getTrending({int page = 1, int perPage = 20}) async {
    try {
      final response = await _dio.get('/meta/anilist/trending', queryParameters: {
        'page': page,
        'perPage': perPage,
      });
      final results = response.data['results'] as List? ?? [];
      return results
          .map((r) => AnimeModel.fromConsumetMap(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch trending: $e');
    }
  }

  Future<List<AnimeModel>> getPopular({int page = 1, int perPage = 20}) async {
    try {
      final response = await _dio.get('/meta/anilist/popular', queryParameters: {
        'page': page,
        'perPage': perPage,
      });
      final results = response.data['results'] as List? ?? [];
      return results
          .map((r) => AnimeModel.fromConsumetMap(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch popular: $e');
    }
  }

  Future<List<AnimeModel>> searchAnime(String query,
      {int page = 1, int perPage = 20}) async {
    try {
      final response = await _dio.get('/meta/anilist/search', queryParameters: {
        'query': query,
        'page': page,
        'perPage': perPage,
      });
      final results = response.data['results'] as List? ?? [];
      return results
          .map((r) => AnimeModel.fromConsumetMap(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search: $e');
    }
  }

  Future<AnimeModel> getAnimeInfo(String anilistId,
      {String provider = 'gogoanime'}) async {
    try {
      final response = await _dio.get('/meta/anilist/info/$anilistId',
          queryParameters: {'provider': provider});
      return AnimeModel.fromConsumetMap(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch anime info: $e');
    }
  }

  Future<List<EpisodeModel>> getEpisodes(String anilistId,
      {String provider = 'gogoanime'}) async {
    try {
      final response = await _dio.get('/meta/anilist/info/$anilistId',
          queryParameters: {'provider': provider});
      final episodes = response.data['episodes'] as List? ?? [];
      return episodes
          .map((e) => EpisodeModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch episodes: $e');
    }
  }

  Future<StreamResponse> getEpisodeSources(String episodeId,
      {String server = 'vidstreaming', String category = 'sub'}) async {
    try {
      final response = await _dio.get('/anime/hianime/watch', queryParameters: {
        'episodeId': episodeId,
        'server': server,
        'category': category,
      });
      return StreamResponse.fromMap(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch episode sources: $e');
    }
  }

  Future<List<AnimeModel>> getAiringSchedule(
      {int page = 1, int perPage = 20}) async {
    try {
      final response =
          await _dio.get('/meta/anilist/airing-schedule', queryParameters: {
        'page': page,
        'perPage': perPage,
      });
      final results = response.data['results'] as List? ?? [];
      return results
          .map((r) => AnimeModel.fromConsumetMap(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch schedule: $e');
    }
  }

  Future<List<AnimeModel>> advancedSearch({
    String? query,
    String? season,
    String? format,
    List<String>? genres,
    int? year,
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final params = <String, dynamic>{
        'type': 'ANIME',
        'page': page,
        'perPage': perPage,
        if (query != null) 'query': query,
        if (season != null) 'season': season,
        if (format != null) 'format': format,
        if (genres != null) 'genres': genres,
        if (year != null) 'year': year,
        if (status != null) 'status': status,
      };
      final response =
          await _dio.get('/meta/anilist/advanced-search', queryParameters: params);
      final results = response.data['results'] as List? ?? [];
      return results
          .map((r) => AnimeModel.fromConsumetMap(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed advanced search: $e');
    }
  }
}
