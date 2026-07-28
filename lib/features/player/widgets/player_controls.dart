import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

class PlayerControls extends StatefulWidget {
  final Player player;
  final String? title;
  final VoidCallback? onBack;
  final VoidCallback? onSkipBack;
  final VoidCallback? onSkipForward;
  final bool hasPrevious;
  final bool hasNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final Duration? introStart;
  final Duration? introEnd;

  const PlayerControls({
    super.key,
    required this.player,
    this.title,
    this.onBack,
    this.onSkipBack,
    this.onSkipForward,
    this.hasPrevious = false,
    this.hasNext = false,
    this.onPrevious,
    this.onNext,
    this.introStart,
    this.introEnd,
  });

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  bool _visible = true;
  Timer? _hideTimer;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  bool _sliderDragging = false;

  @override
  void initState() {
    super.initState();
    _resetHideTimer();

    widget.player.stream.position.listen((p) {
      if (!_sliderDragging && mounted) {
        setState(() => _position = p);
      }
    });

    widget.player.stream.duration.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    widget.player.stream.playing.listen((playing) {
      if (mounted) setState(() => _isPlaying = playing);
    });
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) setState(() => _visible = false);
    });
  }

  void show() {
    setState(() => _visible = true);
    _resetHideTimer();
  }

  void toggle() {
    if (_visible) {
      _hideTimer?.cancel();
      setState(() => _visible = false);
    } else {
      show();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggle,
      child: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: _visible ? _buildOverlay() : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Column(
        children: [
          _buildTopBar(),
          const Spacer(),
          _buildCenterControls(),
          const Spacer(),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: widget.onBack,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.title ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.hasPrevious)
          IconButton(
            icon: const Icon(Icons.skip_previous, color: Colors.white, size: 36),
            onPressed: widget.onPrevious,
          ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: widget.onSkipBack,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white54, width: 2),
            ),
            child: const Icon(Icons.replay_10, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(width: 32),
        GestureDetector(
          onTap: () {
            if (_isPlaying) {
              widget.player.pause();
            } else {
              widget.player.play();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.black,
              size: 36,
            ),
          ),
        ),
        const SizedBox(width: 32),
        GestureDetector(
          onTap: widget.onSkipForward,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white54, width: 2),
            ),
            child: const Icon(Icons.forward_10, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(width: 24),
        if (widget.hasNext)
          IconButton(
            icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
            onPressed: widget.onNext,
          ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_showSkipButton)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextButton.icon(
                    onPressed: () {
                      if (widget.introEnd != null) {
                        widget.player.seek(widget.introEnd!);
                      }
                    },
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    label: const Text('Skip Intro',
                        style: TextStyle(color: Colors.white)),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                Text(
                  _formatDuration(_position),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 16),
                      activeTrackColor: Colors.red,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Colors.red,
                      overlayColor: Colors.red.withValues(alpha: 0.2),
                    ),
                    child: Slider(
                      value: _duration.inMilliseconds > 0
                          ? (_position.inMilliseconds /
                                  _duration.inMilliseconds)
                              .clamp(0.0, 1.0)
                          : 0.0,
                      onChanged: (v) {
                        _sliderDragging = true;
                        setState(() {
                          _position = Duration(
                            milliseconds:
                                (v * _duration.inMilliseconds).round(),
                          );
                        });
                      },
                      onChangeEnd: (v) {
                        _sliderDragging = false;
                        widget.player.seek(Duration(
                          milliseconds: (v * _duration.inMilliseconds).round(),
                        ));
                        _resetHideTimer();
                      },
                    ),
                  ),
                ),
                Text(
                  _formatDuration(_duration),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool get _showSkipButton {
    if (widget.introStart == null || widget.introEnd == null) return false;
    return _position >= widget.introStart! && _position < widget.introEnd!;
  }
}
