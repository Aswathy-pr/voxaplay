import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musicvoxaplay/screens/audio/audio_playermanager.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';
import 'package:musicvoxaplay/screens/widgets/audio/album_art.dart';
import 'package:musicvoxaplay/screens/widgets/audio/playback_controls.dart';
import 'package:musicvoxaplay/screens/widgets/audio/progress_bar.dart';
import 'package:musicvoxaplay/screens/widgets/audio/repeat_suffle.dart';
import 'package:musicvoxaplay/screens/widgets/bottom_navigationbar.dart';


class AudioFullScreen extends StatefulWidget {
  final Song song;
  final List<Song> songs;

  const AudioFullScreen({required this.song, required this.songs, Key? key})
      : super(key: key);

  @override
  _AudioFullScreenState createState() => _AudioFullScreenState();
}

class _AudioFullScreenState extends State<AudioFullScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isRepeat = false;
  bool _isShuffle = false;
  bool _isFavorite = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Song? _currentSong;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayerManager().player;
    _currentSong = widget.song;
    _isFavorite = _currentSong?.isFavorite ?? false;
    _setupAudioPlayer();
    _initializePlaylist();
  }

  Future<void> _initializePlaylist() async {
    final initialIndex = widget.songs.indexWhere((s) => s.path == widget.song.path);
    if (initialIndex >= 0) {
      await AudioPlayerManager().setPlaylist(widget.songs, initialIndex: initialIndex);
      await _audioPlayer.setShuffleModeEnabled(_isShuffle);
      await _audioPlayer.setLoopMode(_isRepeat ? LoopMode.one : LoopMode.off);
      await _audioPlayer.play();
      if (mounted) _updateRecentlyPlayed(_currentSong!);
    }
  }

  void _setupAudioPlayer() {
    _audioPlayer.playingStream.listen((playing) {
      if (mounted) setState(() => _isPlaying = playing);
    });

    _audioPlayer.durationStream.listen((d) {
      if (mounted) setState(() => _duration = d ?? Duration.zero);
    });

    _audioPlayer.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });

    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && index < AudioPlayerManager().songs.length && mounted) {
        setState(() {
          _currentSong = AudioPlayerManager().songs[index];
          _isFavorite = _currentSong?.isFavorite ?? false;
          _updateRecentlyPlayed(_currentSong!);
        });
      }
    });
  }

  Future<void> _updateRecentlyPlayed(Song song) async {
    final box = Hive.box<Song>('recentlyPlayed');
    final existingKeys = box.keys.where((k) => box.get(k)?.path == song.path).toList();
    for (var key in existingKeys) await box.delete(key);
    if (box.length >= 10) await box.delete(box.keys.first);
    await box.add(Song(
      song.title,
      song.artist,
      song.path,
      artwork: song.artwork,
      playedAt: DateTime.now(),
      isFavorite: song.isFavorite,
    ));
  }

  Future<void> _togglePlayPause() async {
    _isPlaying ? await _audioPlayer.pause() : await _audioPlayer.play();
  }

  Future<void> _toggleRepeat() async {
    try {
      final newRepeatMode = !_isRepeat;
      await _audioPlayer.setLoopMode(newRepeatMode ? LoopMode.one : LoopMode.off);
      if (mounted) setState(() => _isRepeat = newRepeatMode);
    } catch (e) {
      print('Error toggling repeat: $e');
      if (mounted) setState(() => _isRepeat = !_isRepeat);
    }
  }

  Future<void> _toggleShuffle() async {
    try {
      final newShuffleMode = !_isShuffle;
      await _audioPlayer.setShuffleModeEnabled(newShuffleMode);
      if (mounted) setState(() => _isShuffle = newShuffleMode);
    } catch (e) {
      print('Error toggling shuffle: $e');
      if (mounted) setState(() => _isShuffle = !_isShuffle);
    }
  }

  void _playPreviousSong() => _audioPlayer.seekToPrevious();
  void _playNextSong() => _audioPlayer.seekToNext();

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
      if (_currentSong != null) {
        _currentSong!.isFavorite = _isFavorite;
        final songIndex = Hive.box<Song>('songsBox')
            .values.toList()
            .indexWhere((s) => s.path == _currentSong!.path);
        if (songIndex != -1) Hive.box<Song>('songsBox').putAt(songIndex, _currentSong!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: buildAppBar(context, 'Now Playing', showBackButton: true),
      body: _currentSong == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AlbumArtwork(song: _currentSong!),
                const SizedBox(height: 20),
                Text(
                  _currentSong!.title,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  _currentSong!.artist,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 16,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 40),
                ProgressBar(
                  position: _position,
                  duration: _duration,
                  isFavorite: _isFavorite,
                  onFavoritePressed: _toggleFavorite,
                  onChanged: (value) async {
                    await _audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                ),
                const SizedBox(height: 25),
                PlaybackControls(
                  isPlaying: _isPlaying,
                  onPrevious: _playPreviousSong,
                  onPlayPause: _togglePlayPause,
                  onNext: _playNextSong,
                ),
                const SizedBox(height: 25),
                PlaybackOptions(
                  isRepeat: _isRepeat,
                  isShuffle: _isShuffle,
                  onRepeat: _toggleRepeat,
                  onShuffle: _toggleShuffle,
                ),
              ],
            ),
      bottomNavigationBar: buildBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            setState(() => _currentIndex = index);
          }
        },
        context: context,
      ),
    );
  }
}