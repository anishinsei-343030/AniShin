import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../services/storage_service.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final watchHistory = ref.watch(watchHistoryProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Library'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Favorites'),
              Tab(text: 'Continue'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _FavoritesTab(favorites: favorites),
            _ContinueTab(
              entries: watchHistory.isNotEmpty
                  ? ref.read(watchHistoryProvider.notifier).getContinueWatching()
                  : [],
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesTab extends ConsumerWidget {
  final List<FavoriteEntry> favorites;

  const _FavoritesTab({required this.favorites});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (favorites.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No favorites yet',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Tap the heart on any anime to save it',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final fav = favorites[index];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: fav.image != null
                  ? CachedNetworkImage(
                      imageUrl: fav.image!,
                      width: 56,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 56,
                      height: 80,
                      color: Colors.grey[800],
                      child: const Icon(Icons.movie),
                    ),
            ),
            title: Text(fav.title, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              '${fav.score?.toStringAsFixed(1) ?? 'N/A'} · ${fav.episodes ?? '?'} eps',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () {
                ref.read(favoritesProvider.notifier).toggle(
                  FavoriteEntry(
                    id: fav.id,
                    title: fav.title,
                    image: fav.image,
                    score: fav.score,
                    episodes: fav.episodes,
                    addedAt: fav.addedAt,
                  ),
                );
              },
            ),
            onTap: () => context.push('/anime/${fav.id}'),
          );
        },
      ),
    );
  }
}

class _ContinueTab extends ConsumerWidget {
  final List<WatchHistoryEntry> entries;

  const _ContinueTab({required this.entries});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entries.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No watch history',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Start watching to see your progress here',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final progress = entry.duration != null && entry.duration!.inMilliseconds > 0
              ? (entry.progress.inMilliseconds / entry.duration!.inMilliseconds)
                  .clamp(0.0, 1.0)
              : 0.0;

          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: entry.animeImage != null
                  ? CachedNetworkImage(
                      imageUrl: entry.animeImage!,
                      width: 56,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 56,
                      height: 80,
                      color: Colors.grey[800],
                      child: const Icon(Icons.movie),
                    ),
            ),
            title: Text(entry.animeTitle,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.episodeTitle ?? 'Episode ${entry.episodeNumber.toInt()}'),
                if (progress > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 3,
                    ),
                  ),
              ],
            ),
            onTap: () => context.push(
              '/watch/${entry.animeId}/${entry.episodeId}',
            ),
          );
        },
      ),
    );
  }
}
