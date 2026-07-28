import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../services/storage_service.dart';
import '../../../providers/anime_repository.dart';

class DetailScreen extends ConsumerWidget {
  final String id;

  const DetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animeAsync = ref.watch(animeDetailProvider(id));
    final episodesAsync = ref.watch(episodesProvider(id));

    return Scaffold(
      body: animeAsync.when(
        data: (anime) {
          final isFav = ref.watch(favoritesProvider).any((f) => f.id == anime.id);

          return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              actions: [
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : null,
                  ),
                  onPressed: () {
                    ref.read(favoritesProvider.notifier).toggle(
                      FavoriteEntry(
                        id: anime.id,
                        title: anime.title,
                        image: anime.image,
                        score: anime.score,
                        episodes: anime.episodes,
                        addedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                      ),
                    );
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: CachedNetworkImage(
                  imageUrl: anime.cover ?? anime.image ?? '',
                  fit: BoxFit.cover,
                  color: Colors.black.withValues(alpha: 0.4),
                  colorBlendMode: BlendMode.darken,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: anime.image ?? '',
                            width: 100,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                anime.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  if (anime.score != null) ...[
                                    const Icon(Icons.star,
                                        size: 16, color: Colors.amber),
                                    const SizedBox(width: 4),
                                    Text(
                                      anime.score!.toStringAsFixed(1),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  if (anime.episodes != null)
                                    Text(
                                      '${anime.episodes} eps',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (anime.genres.isNotEmpty)
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: anime.genres
                                      .take(5)
                                          .map((g) => Chip(
                                            label: Text(g, style: const TextStyle(fontSize: 11)),
                                            materialTapTargetSize:
                                                MaterialTapTargetSize.shrinkWrap,
                                            visualDensity: VisualDensity.compact,
                                          ))
                                      .toList(),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (anime.description != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        anime.description!,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      'Episodes',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            episodesAsync.when(
              data: (episodes) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final ep = episodes[index];
                    final watchEntry = ref.watch(watchHistoryProvider)
                        .where((w) => w.episodeId == ep.id)
                        .firstOrNull;
                    final progress = watchEntry?.duration != null &&
                            watchEntry!.duration!.inMilliseconds > 0
                        ? (watchEntry.progress.inMilliseconds /
                                watchEntry.duration!.inMilliseconds)
                            .clamp(0.0, 1.0)
                        : 0.0;

                    return ListTile(
                      leading: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: CachedNetworkImage(
                              imageUrl: ep.image ?? '',
                              width: 80,
                              height: 45,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (progress > 0)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 3,
                                backgroundColor: Colors.white24,
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        'Episode ${ep.number.toInt()}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (ep.title != null) Text(ep.title!),
                          if (watchEntry != null && watchEntry.isCompleted)
                            const Text('Completed',
                                style: TextStyle(
                                    color: Colors.green, fontSize: 12)),
                        ],
                      ),
                      trailing: const Icon(Icons.play_circle_outline),
                      onTap: () => context.push(
                        '/watch/${anime.id}/${ep.id}?title=${Uri.encodeComponent(anime.title)}&image=${Uri.encodeComponent(anime.image ?? '')}&ep=${ep.number.toInt()}',
                      ),
                    );
                  },
                  childCount: episodes.length,
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(child: Text('Failed to load episodes: $e')),
              ),
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        );
      },
      error: (e, _) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
