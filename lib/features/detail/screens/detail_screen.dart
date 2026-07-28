import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
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
        data: (anime) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
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
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CachedNetworkImage(
                          imageUrl: ep.image ?? '',
                          width: 80,
                          height: 45,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        'Episode ${ep.number.toInt()}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle:
                          ep.title != null ? Text(ep.title!) : null,
                      trailing: const Icon(Icons.play_circle_outline),
                      onTap: () => context.push(
                        '/watch?episodeId=${ep.id}&title=${Uri.encodeComponent(anime.title)}',
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
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
