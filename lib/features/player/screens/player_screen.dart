import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../services/storage_service.dart';
import '../../../providers/anime_repository.dart';
import '../../../models/episode_model.dart';
import '../widgets/player_controls.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final String animeId;
  final String episodeId;
  final String? animeTitle;
  final String? animeImage;
  final double episodeNumber;

  const PlayerScreen({
    super.key,
    required this.animeId,
    required this.episodeId,
    this.animeTitle,
    this.animeImage,
    this.episodeNumber = 1,
  });

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  final Player _player = Player();
  late VideoController _controller;
  bool _isInitialized = false;
  StreamResponse? _streamData;
  late String _currentEpisodeId;
  late double _currentEpisodeNumber;

  @override
  void initState() {
    super.initState();
    _controller = VideoController(_player);
    _currentEpisodeId = widget.episodeId;
    _currentEpisodeNumber = widget.episodeNumber;
    _loadVideo(_currentEpisodeId);
  }

  Future<void> _loadVideo(String episodeId) async {
    setState(() => _isInitialized = false);
    try {
      final sources =
          await ref.read(episodeSourcesProvider(episodeId).future);
      if (sources.sources.isNotEmpty) {
        final url = sources.sources.first.url;
        await _player.open(Media(url, httpHeaders: sources.headers));
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _streamData = sources;
          });
        }
        _player.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load video: $e')),
        );
        setState(() => _isInitialized = true);
      }
    }
  }

  void _navigateEpisode(int direction) {
    final episodes = ref.read(episodesProvider(widget.animeId));
    final list = episodes.asData?.value;
    if (list == null || list.isEmpty) return;

    final idx = list.indexWhere((e) => e.id == _currentEpisodeId);
    if (idx == -1) return;

    final target = idx + direction;
    if (target < 0 || target >= list.length) return;

    final ep = list[target];
    _saveProgressForNavigation();
    setState(() {
      _currentEpisodeId = ep.id;
      _currentEpisodeNumber = ep.number;
    });
    _loadVideo(ep.id);
  }

  Future<void> _saveProgressForNavigation() async {
    final position = _player.state.position;
    final duration = _player.state.duration;
    ref.read(watchHistoryProvider.notifier).add(
      WatchHistoryEntry(
        animeId: widget.animeId,
        animeTitle: widget.animeTitle ?? 'Unknown',
        animeImage: widget.animeImage,
        episodeId: _currentEpisodeId,
        episodeNumber: _currentEpisodeNumber,
        episodeTitle: 'Episode ${_currentEpisodeNumber.toInt()}',
        progress: position,
        duration: duration,
        watchedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      ),
    );
  }

  void _seekRelative(int seconds) {
    final current = _player.state.position;
    final newPos = current + Duration(seconds: seconds);
    _player.seek(newPos);
  }

  int _getEpisodeIndex() {
    final episodes = ref.read(episodesProvider(widget.animeId));
    final list = episodes.asData?.value ?? [];
    return list.indexWhere((e) => e.id == _currentEpisodeId);
  }

  int _getEpisodeListLength() {
    final episodes = ref.read(episodesProvider(widget.animeId));
    final data = episodes.asData;
    return data?.value.length ?? 0;
  }

  @override
  void dispose() {
    _saveProgressForNavigation();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final idx = _getEpisodeIndex();
    final total = _getEpisodeListLength();
    final hasPrev = idx > 0;
    final hasNext = idx < total - 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            _isInitialized
                ? Video(
                    controller: _controller,
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading video...',
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
            if (_isInitialized)
              PlayerControls(
                player: _player,
                title:
                    '${widget.animeTitle ?? ''} - Ep ${_currentEpisodeNumber.toInt()}',
                onBack: () => Navigator.pop(context),
                onSkipBack: () => _seekRelative(-10),
                onSkipForward: () => _seekRelative(10),
                hasPrevious: hasPrev,
                hasNext: hasNext,
                onPrevious: () => _navigateEpisode(-1),
                onNext: () => _navigateEpisode(1),
                introStart: _parseDuration(_streamData?.introStart),
                introEnd: _parseDuration(_streamData?.introEnd),
              ),
          ],
        ),
      ),
    );
  }

  Duration? _parseDuration(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length == 2) {
      return Duration(
        minutes: int.tryParse(parts[0]) ?? 0,
        seconds: int.tryParse(parts[1]) ?? 0,
      );
    }
    if (parts.length == 3) {
      return Duration(
        hours: int.tryParse(parts[0]) ?? 0,
        minutes: int.tryParse(parts[1]) ?? 0,
        seconds: int.tryParse(parts[2]) ?? 0,
      );
    }
    return null;
  }
}
