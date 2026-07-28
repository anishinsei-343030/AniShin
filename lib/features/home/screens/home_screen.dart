import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/anime_repository.dart';
import '../widgets/anime_card.dart';
import '../widgets/trending_carousel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trending = ref.watch(trendingProvider);
    final popular = ref.watch(popularProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AnimeApp'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(trendingProvider),
        child: ListView(
          children: [
            trending.when(
              data: (animeList) => TrendingCarousel(animeList: animeList),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Failed to load trending: $e'),
              ),
              loading: () => const SizedBox(
                height: 250,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Popular',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            popular.when(
              data: (animeList) => SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: animeList.length,
                  itemBuilder: (context, index) =>
                      AnimeCard(anime: animeList[index]),
                ),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Failed to load popular: $e'),
              ),
              loading: () => const SizedBox(
                height: 280,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
