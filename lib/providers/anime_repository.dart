import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/consumet_api.dart';
import '../core/api/anilist_api.dart';
import '../models/anime_model.dart';
import '../models/episode_model.dart';

final consumetApiProvider = Provider<ConsumetApi>((ref) => ConsumetApi());

final anilistApiProvider = Provider<AnilistApi>((ref) => AnilistApi());

final trendingProvider = FutureProvider.autoDispose<List<AnimeModel>>((ref) {
  final api = ref.watch(consumetApiProvider);
  return api.getTrending();
});

final popularProvider = FutureProvider.autoDispose<List<AnimeModel>>((ref) {
  final api = ref.watch(consumetApiProvider);
  return api.getPopular();
});

final searchProvider =
    FutureProvider.autoDispose.family<List<AnimeModel>, String>((ref, query) {
  if (query.trim().isEmpty) return Future.value([]);
  final api = ref.watch(consumetApiProvider);
  return api.searchAnime(query);
});

final animeDetailProvider =
    FutureProvider.autoDispose.family<AnimeModel, String>((ref, id) {
  final api = ref.watch(consumetApiProvider);
  return api.getAnimeInfo(id);
});

final episodesProvider =
    FutureProvider.autoDispose.family<List<EpisodeModel>, String>((ref, id) {
  final api = ref.watch(consumetApiProvider);
  return api.getEpisodes(id);
});

final episodeSourcesProvider = FutureProvider.autoDispose.family<
    StreamResponse,
    String>((
  ref,
  episodeId,
) {
  final api = ref.watch(consumetApiProvider);
  return api.getEpisodeSources(episodeId);
});

final airingScheduleProvider =
    FutureProvider.autoDispose<List<AnimeModel>>((ref) {
  final api = ref.watch(consumetApiProvider);
  return api.getAiringSchedule();
});
