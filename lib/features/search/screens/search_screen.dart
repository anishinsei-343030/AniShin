import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/anime_repository.dart';
import '../../home/widgets/anime_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search anime...',
            border: InputBorder.none,
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
          ),
          onSubmitted: (value) => setState(() => _query = value.trim()),
        ),
      ),
      body: results.when(
        data: (animeList) {
          if (animeList.isEmpty) {
            return const Center(
              child: Text('Search for your favorite anime'),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: animeList.length,
            itemBuilder: (context, index) =>
                AnimeCard(anime: animeList[index], width: double.infinity),
          );
        },
        error: (e, _) => Center(child: Text('Error: $e')),
        loading: () => _query.isNotEmpty
            ? const Center(child: CircularProgressIndicator())
            : const Center(child: Text('Search for your favorite anime')),
      ),
    );
  }
}
