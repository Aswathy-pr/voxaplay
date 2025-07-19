import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';
import 'package:musicvoxaplay/screens/audio/audio_playermanager.dart';


class PlayPauseWidget extends StatefulWidget {
  final Song song;
  final AudioPlayer audioPlayer;

  const PlayPauseWidget({
    Key? key,
    required this.song,
    required this.audioPlayer,
  }) : super(key: key);

  @override
  _PlayPauseWidgetState createState() => _PlayPauseWidgetState();
}

class _PlayPauseWidgetState extends State<PlayPauseWidget> {
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    _isPlaying =
        widget.audioPlayer.playing &&
        AudioPlayerManager().currentSong?.path == widget.song.path;

    widget.audioPlayer.playingStream.listen((playing) {
      if (mounted) {
        setState(() {
          _isPlaying =
              playing &&
              AudioPlayerManager().currentSong?.path == widget.song.path;
        });
      }
    });
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await widget.audioPlayer.pause();
      } else {
       
        await AudioPlayerManager().setPlaylist([widget.song], initialIndex: 0);
        await widget.audioPlayer.play();
      }
    } catch (e) {
      print('Error toggling play/pause: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            color: Theme.of(context).textTheme.bodyLarge!.color,
            size: 39,
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _togglePlayPause,
            child: Text(
              _isPlaying ? 'Pause' : 'Play',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: 21, 
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.audioPlayer.playingStream.drain();
    super.dispose();
  }
}
