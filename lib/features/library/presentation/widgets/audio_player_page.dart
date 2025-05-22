import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:echoread/core/config/cloudinary_config.dart';

class AudioPlayScreen extends StatefulWidget {
  final String title;
  final String author;
  final String coverImageUrl;
  final String audioUrl;

  const AudioPlayScreen({
    super.key,
    required this.title,
    required this.author,
    required this.coverImageUrl,
    required this.audioUrl,
  });

  @override
  State<AudioPlayScreen> createState() => _AudioPlayScreenState();
}

class _AudioPlayScreenState extends State<AudioPlayScreen> {
  late final AudioPlayer _player;
  Duration _current = Duration.zero;
  Duration _total = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _setupAudio();
  }

  Future<void> _setupAudio() async {
    try {
      await _player.setUrl(CloudinaryConfig.baseUrl(widget.audioUrl, MediaType.audio));

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
    if (_isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.title, style: const TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                widget.coverImageUrl,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.author,
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatTime(_current)),
                Text(_formatTime(_total)),
              ],
            ),
            Slider(
              value: _current.inSeconds.toDouble().clamp(0, _total.inSeconds.toDouble()),
              max: _total.inSeconds.toDouble().clamp(1, double.infinity),
              onChanged: (value) => _player.seek(Duration(seconds: value.toInt())),
              activeColor: Colors.teal,
              inactiveColor: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.fast_rewind, size: 32),
                  onPressed: () {
                    final newPosition = _current - const Duration(seconds: 10);
                    _player.seek(newPosition > Duration.zero ? newPosition : Duration.zero);
                  },
                ),
                const SizedBox(width: 20),
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.teal,
                  child: IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 36,
                      color: Colors.white,
                    ),
                    onPressed: _togglePlayback,
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.fast_forward, size: 32),
                  onPressed: () {
                    final newPosition = _current + const Duration(seconds: 10);
                    if (_total != Duration.zero && newPosition < _total) {
                      _player.seek(newPosition);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
