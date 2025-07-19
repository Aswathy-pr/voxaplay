import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';


class AudioController extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConcatenatingAudioSource _playlist;
  bool _isPlaying = false;
  bool _isRepeatOn = false;
  bool _isShuffleOn = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String _errorMessage = '';

  AudioPlayer get audioPlayer => _audioPlayer;
  bool get isPlaying => _isPlaying;
  bool get isRepeatOn => _isRepeatOn;
  bool get isShuffleOn => _isShuffleOn;
  Duration get position => _position;
  Duration get duration => _duration;
  String get errorMessage => _errorMessage;

  Future<void> initialize(List<Song> songs, Song initialSong) async {
    _setupPlaylist(songs);
    await _loadSong(songs, initialSong);
    _setupStreams();
  }

  void _setupPlaylist(List<Song> songs) {
    _playlist = ConcatenatingAudioSource(
      children: songs
          .where((song) => song.path.isNotEmpty)
          .map((song) => AudioSource.uri(Uri.parse(song.path)))
          .toList(),
    );
  }

  void _setupStreams() {
    _audioPlayer.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });
    _audioPlayer.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
      notifyListeners();
    });
  }

  Future<void> _loadSong(List<Song> songs, Song initialSong) async {
    try {
      if (_playlist.length == 0) {
        _errorMessage = 'No playable songs in the list';
        notifyListeners();
        return;
      }
      int initialIndex = songs.indexOf(initialSong);
      if (initialIndex < 0 || initialIndex >= _playlist.length) {
        initialIndex = 0;
      }
      await _audioPlayer.setAudioSource(
        _playlist,
        initialIndex: initialIndex,
      );
      togglePlayPause();
    } catch (e) {
      _errorMessage = 'Failed to play song: $e';
      print ('Error loading song: $e');
      notifyListeners();
    }
  }

  void togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeatOn = !_isRepeatOn;
    _audioPlayer.setLoopMode(_isRepeatOn ? LoopMode.one : LoopMode.off);
    notifyListeners();
  }

  void toggleShuffle() {
    _isShuffleOn = !_isShuffleOn;
    _audioPlayer.setShuffleModeEnabled(_isShuffleOn);
    notifyListeners();
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  void seekToPrevious() {
    if (_audioPlayer.hasPrevious) {
      _audioPlayer.seekToPrevious();
    }
  }

  void seekToNext() {
    if (_audioPlayer.hasNext) {
      _audioPlayer.seekToNext();
    }
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}