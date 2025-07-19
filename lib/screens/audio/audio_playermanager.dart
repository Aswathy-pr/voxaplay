import 'package:just_audio/just_audio.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';

class AudioPlayerManager {
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  factory AudioPlayerManager() => _instance;
  AudioPlayerManager._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  ConcatenatingAudioSource? _playlist;
  List<Song> _songs = [];
  Song? _currentSong;

  AudioPlayer get player => _audioPlayer;
  List<Song> get songs => _songs;
  ConcatenatingAudioSource? get playlist => _playlist;
  Song? get currentSong => _currentSong;

  Future<void> setPlaylist(List<Song> songs, {int initialIndex = 0}) async {
    _songs = List.from(songs);
    _playlist = ConcatenatingAudioSource(
      children: songs.map((song) => AudioSource.file(song.path)).toList(),
      shuffleOrder: DefaultShuffleOrder(),
    );
    await _audioPlayer.setAudioSource(
      _playlist!,
      initialIndex: initialIndex.clamp(0, songs.length - 1),
    );

    _currentSong = songs.isNotEmpty ? songs[initialIndex.clamp(0, songs.length - 1)] : null;

    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < _songs.length) {
        _currentSong = _songs[index];
      } else {
        _currentSong = null;
      }
    });
  }

  Future<void> updateShuffle(bool isShuffle) async {
    if (_playlist != null) {
      await _audioPlayer.setShuffleModeEnabled(isShuffle);
    }
  }

  Future<void> updateRepeat(bool isRepeat) async {
    await _audioPlayer.setLoopMode(isRepeat ? LoopMode.one : LoopMode.all);
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}