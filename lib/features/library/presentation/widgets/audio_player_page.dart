import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:developer';

class AudioPlayScreen extends StatefulWidget {
  final String title;
  final String author;
  final String coverImageUrl;
  final List<String> audioUrls;

  const AudioPlayScreen({
    super.key,
    required this.title,
    required this.author,
    required this.coverImageUrl,
    required this.audioUrls,
  });

  @override
  State<AudioPlayScreen> createState() => _AudioPlayScreenState();
}

class _AudioPlayScreenState extends State<AudioPlayScreen> {
  late final AudioPlayer _player;
  Duration _current = Duration.zero;
  Duration _total = Duration.zero;
  bool _isPlaying = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _setupAudio();
  }

  Future<void> _setupAudio() async {
    try {
      final playlist = ConcatenatingAudioSource(
        children: widget.audioUrls.map((url) => AudioSource.uri(Uri.parse(url))).toList(),
      );

      await _player.setAudioSource(playlist);

      _player.durationStream.listen((duration) {
        setState(() {
          _total = duration ?? Duration.zero;
        });
      });

      _player.positionStream.listen((position) {
        setState(() => _current = position);
      });

      _player.playerStateStream.listen((state) {
        setState(() => _isPlaying = state.playing);
      });

      _player.currentIndexStream.listen((index) {
        setState(() {
          if (index != null) _currentIndex = index;
        });
      });
    } catch (e) {
      log('Audio load error: $e');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    _isPlaying ? _player.pause() : _player.play();
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(1, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _playAtIndex(int index) {
    _player.seek(Duration.zero, index: index);
    _player.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B14),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Cover Image & Info
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  widget.coverImageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                widget.author,
                style: const TextStyle(fontSize: 18, color: Colors.greenAccent),
              ),
              const SizedBox(height: 20),

              // Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatTime(_current), style: const TextStyle(color: Colors.white70)),
                  Text(_formatTime(_total), style: const TextStyle(color: Colors.white70)),
                ],
              ),
              Slider(
                value: _current.inSeconds.toDouble().clamp(0, _total.inSeconds.toDouble()),
                max: _total.inSeconds.toDouble().clamp(1, double.infinity),
                onChanged: (value) => _player.seek(Duration(seconds: value.toInt())),
                activeColor: Colors.greenAccent,
                inactiveColor: Colors.white12,
              ),
              const SizedBox(height: 24),

              // Playback Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, size: 32, color: Colors.greenAccent),
                    onPressed: () => _player.seekToPrevious(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.replay_10, size: 32, color: Colors.greenAccent),
                    onPressed: () {
                      final newPosition = _current - const Duration(seconds: 10);
                      _player.seek(newPosition > Duration.zero ? newPosition : Duration.zero);
                    },
                  ),
                  const SizedBox(width: 16),
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.greenAccent,
                    child: IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 32,
                        color: Colors.black,
                      ),
                      onPressed: _togglePlayback,
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.forward_10, size: 32, color: Colors.greenAccent),
                    onPressed: () {
                      final newPosition = _current + const Duration(seconds: 10);
                      if (_total != Duration.zero && newPosition < _total) {
                        _player.seek(newPosition);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, size: 32, color: Colors.greenAccent),
                    onPressed: () => _player.seekToNext(),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Up Next',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),

              // Up Next List
              Expanded(
                child: ListView.builder(
                  itemCount: widget.audioUrls.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _currentIndex;
                    final audioName = widget.audioUrls[index].split('/').last;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 6),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(widget.coverImageUrl, width: 50, height: 50, fit: BoxFit.cover),
                      ),
                      title: Text(
                        audioName,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.white70,
                        ),
                      ),
                      subtitle: Text(widget.author, style: const TextStyle(color: Colors.greenAccent)),
                      onTap: () => _playAtIndex(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
