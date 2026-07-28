import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../providers/anime_repository.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final String episodeId;
  final String? animeTitle;

  const PlayerScreen({
    super.key,
    required this.episodeId,
    this.animeTitle,
  });

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  final Player _player = Player();
  late VideoController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoController(_player);
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    try {
      final sources = await ref.read(episodeSourcesProvider(widget.episodeId).future);
      if (sources.sources.isNotEmpty) {
        final url = sources.sources.first.url;
        await _player.open(Media(url, httpHeaders: sources.headers));
        if (mounted) setState(() => _isInitialized = true);
        _player.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load video: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.animeTitle ?? 'Playing'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: _isInitialized
            ? Video(
                controller: _controller,
                controls: MaterialVideoControls,
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading video...', style: TextStyle(color: Colors.white70)),
                ],
              ),
      ),
    );
  }
}
