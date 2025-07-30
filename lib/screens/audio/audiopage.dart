import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';
import 'package:musicvoxaplay/screens/widgets/bottom_navigationbar.dart';
import 'package:musicvoxaplay/screens/services/song_service.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';
import 'package:musicvoxaplay/screens/audio/audio_fullscreen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:musicvoxaplay/screens/widgets/audio/mini_player_widget.dart';
import 'package:musicvoxaplay/screens/widgets/audio/song_list_widgets.dart';
import 'package:musicvoxaplay/screens/audio/audio_playermanager.dart';
import 'package:musicvoxaplay/screens/song_menu/song_menubar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musicvoxaplay/screens/song_menu/playnext_service.dart';

class AudioPage extends StatefulWidget {
  const AudioPage({super.key});

  @override
  _AudioPageState createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  late Future<List<Song>> _songsFuture;
  int _currentIndex = 0;
  final SongService _songService = SongService();
  Song? _currentlyPlayingSong;
  bool _isPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayerManager().player;
  late final PlayNextService _playNextService;

  @override
  void initState() {
    super.initState();
    _songsFuture = _songService.fetchSongsFromDevice();
    _playNextService = PlayNextService(
      songService: _songService,
      audioPlayer: _audioPlayer,
    );
    _setupAudioPlayerListeners();
  }

  void _setupAudioPlayerListeners() {
    _audioPlayer.playingStream.listen((playing) {
      if (mounted) {
        setState(() {
          _isPlaying = playing;
        });
      }
    });
    _audioPlayer.currentIndexStream.listen((index) async {
      if (index != null && mounted) {
        final songs = AudioPlayerManager().songs;
        if (index < songs.length) {
          setState(() {
            _currentlyPlayingSong = songs[index];
          });
          
          await _songService.incrementPlayCount(songs[index]);
        }
      }
    });
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
    if (index != 0 ) {
      _audioPlayer.pause();
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error toggling playback: $e')));
      }
    }
  }

  Future<void> _playSong(Song song, List<Song> songs) async {
    try {
      await AudioPlayerManager().setPlaylist(
        songs,
        initialIndex: songs.indexOf(song),
      );
      await _audioPlayer.play();
      setState(() {
        _currentlyPlayingSong = song;
        _isPlaying = true;
      });
      await _songService.incrementPlayCount(song);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AudioFullScreen(song: song, songs: songs),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error playing song: $e')));
      }
    }
  }

  Future<void> _navigateToSongMenu(Song song) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongMenuPage(
          song: song,
          audioPlayer: _audioPlayer,
          songService: _songService,
          playNextService: _playNextService,
        ),
      ),
    );
    setState(() {
      _songsFuture = _songService.fetchSongsFromDevice();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: buildAppBar(context, 'All audios'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: SongListWidget(
                  songsFuture: _songsFuture,
                  currentSong: _currentlyPlayingSong,
                  onSongTap: _playSong,
                  onMenuTap: _navigateToSongMenu,
                  onRetry: () async {
                    await Permission.audio.request();
                    setState(() {
                      _songsFuture = _songService.fetchSongsFromDevice();
                    });
                  },
                ),
              ),
            ),
            if (_currentlyPlayingSong != null)
              MiniPlayerWidget(
                song: _currentlyPlayingSong!,
                isPlaying: _isPlaying,
                onTogglePlay: _togglePlayPause,
                onClose: () {
                  _audioPlayer.stop();
                  setState(() {
                    _currentlyPlayingSong = null;
                  });
                },
                onTap: () async {
                  final songs = await _songsFuture;
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AudioFullScreen(
                        song: _currentlyPlayingSong!,
                        songs: songs,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        context: context,
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.playingStream.drain();
    _audioPlayer.currentIndexStream.drain();
    super.dispose();
  }
}
