import 'package:dio/dio.dart';
import '../../models/anime_model.dart';

class AnilistApi {
  final Dio _dio;
  static const String _endpoint = 'https://graphql.anilist.co';

  AnilistApi()
      : _dio = Dio(BaseOptions(
          baseUrl: _endpoint,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ));

  Future<Map<String, dynamic>> _query(
      String query, Map<String, dynamic>? variables) async {
    final response = await _dio.post('', data: {
      'query': query,
      if (variables != null) 'variables': variables,
    });
    return response.data;
  }

  Future<List<AnimeModel>> search(String search,
      {int page = 1, int perPage = 20}) async {
    const query = '''
      query (\$page: Int, \$perPage: Int, \$search: String) {
        Page(page: \$page, perPage: \$perPage) {
          pageInfo { total currentPage lastPage hasNextPage }
          media(search: \$search, type: ANIME) {
            id
            title { romaji english native }
            coverImage { extraLarge large medium }
            bannerImage
            description
            episodes
            duration
            status
            season
            seasonYear
            genres
            averageScore
            popularity
            startDate { year month day }
            nextAiringEpisode { airingAt episode }
          }
        }
      }
    ''';
    final data = await _query(query, {
      'page': page,
      'perPage': perPage,
      'search': search,
    });
    final media = data['data']['Page']['media'] as List? ?? [];
    return media
        .map((m) => AnimeModel.fromAnilistMap(m as Map<String, dynamic>))
        .toList();
  }

  Future<List<AnimeModel>> getTrending(
      {int page = 1, int perPage = 20}) async {
    const query = '''
      query (\$page: Int, \$perPage: Int) {
        Page(page: \$page, perPage: \$perPage) {
          media(type: ANIME, sort: TRENDING_DESC) {
            id
            title { romaji english }
            coverImage { extraLarge large }
            episodes
            genres
            averageScore
            popularity
            trending
          }
        }
      }
    ''';
    final data = await _query(query, {'page': page, 'perPage': perPage});
    final media = data['data']['Page']['media'] as List? ?? [];
    return media
        .map((m) => AnimeModel.fromAnilistMap(m as Map<String, dynamic>))
        .toList();
  }

  Future<List<AnimeModel>> getSeasonal(String season, int year,
      {int perPage = 50}) async {
    const query = '''
      query (\$season: MediaSeason, \$year: Int, \$perPage: Int) {
        Page(perPage: \$perPage) {
          media(season: \$season, seasonYear: \$year, type: ANIME, sort: POPULARITY_DESC) {
            id
            title { romaji english }
            coverImage { extraLarge large }
            episodes
            genres
            averageScore
            popularity
          }
        }
      }
    ''';
    final data = await _query(query, {
      'season': season,
      'year': year,
      'perPage': perPage,
    });
    final media = data['data']['Page']['media'] as List? ?? [];
    return media
        .map((m) => AnimeModel.fromAnilistMap(m as Map<String, dynamic>))
        .toList();
  }

  Future<AnimeModel?> getById(int id) async {
    const query = '''
      query (\$id: Int) {
        Media(id: \$id, type: ANIME) {
          id
          title { romaji english native }
          coverImage { extraLarge large medium color }
          bannerImage
          description
          episodes
          duration
          status
          season
          seasonYear
          genres
          averageScore
          meanScore
          popularity
          favourites
          studios { nodes { name } }
          startDate { year month day }
          nextAiringEpisode { airingAt episode }
          trailer { id site }
          source
          characters(page: 1, perPage: 10) {
            edges { role node { id name { full native } image { large } } }
          }
        }
      }
    ''';
    final data = await _query(query, {'id': id});
    final media = data['data']?['Media'];
    if (media == null) return null;
    return AnimeModel.fromAnilistMap(media as Map<String, dynamic>);
  }
}
