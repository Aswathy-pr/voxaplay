import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';
import 'package:musicvoxaplay/screens/services/song_service.dart';
import 'package:musicvoxaplay/screens/song_menu/playnext_service.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';
import 'package:musicvoxaplay/screens/widgets/bottom_navigationbar.dart';
import 'package:musicvoxaplay/screens/audio/audio_fullscreen.dart';
import 'package:musicvoxaplay/screens/audio/audio_playermanager.dart';
import 'package:musicvoxaplay/screens/song_menu/song_menubar.dart';
import 'package:just_audio/just_audio.dart';

class MostPlayed extends StatefulWidget {
  const MostPlayed({super.key});

  @override
  State<MostPlayed> createState() => _MostPlayedState();
}

class _MostPlayedState extends State<MostPlayed> {
  int _currentIndex = 2; 
  final SongService _songService = SongService();
  final AudioPlayer _audioPlayer = AudioPlayerManager().player;
  late final PlayNextService _playNextService;

  @override
  void initState() {
    super.initState();

    _playNextService = PlayNextService(songService: _songService, audioPlayer: _audioPlayer);
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
    if (index != 2) {
      _audioPlayer.pause();
    }
  }

  
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: buildAppBar(context, 'Most Played', showBackButton: true),
      body: FutureBuilder<List<Song>>(
        future: _songService.getMostPlayedSongs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading most played songs',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 20,
                    ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No songs played yet',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 20,
                    ),
              ),
            );
          }

          final songs = snapshot.data!;
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              final isPlayable = song.path.isNotEmpty;

              return ListTile(
                leading: song.artwork != null
                    ? Image.memory(
                        song.artwork!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.music_note,
                        size: 50,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                title: Text(
                  song.title,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: isPlayable
                            ? Theme.of(context).textTheme.bodyLarge!.color
                            : Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                ),
                subtitle: Text(
                  '${song.artist} • Played ${song.playcount} time${song.playcount == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  const SizedBox(width: 8.0),
                      IconButton(
                        icon: Icon(
                          Icons.more_horiz,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                          size: 20.0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SongMenuPage(
                                song: song,
                                audioPlayer: _audioPlayer,
                                songService: _songService,
                                playNextService: _playNextService, // Pass PlayNextService
                              ),
                            ),
                          ).then((_) {
             
                            setState(() {});
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                onTap: isPlayable
                    ? () async {
                        try {
                          await AudioPlayerManager().setPlaylist(
                            songs,
                            initialIndex: index,
                          );
                          await _audioPlayer.play();
                          await _songService.incrementPlayCount(song);
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AudioFullScreen(
                                song: song,
                                songs: songs,
                              ),
                            ),
                          );
                          setState(() {});                                                  
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error playing song: $e')),
                            );
                          }
                        }
                      }
                    : null,
              );
            },
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return buildBottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      context: context,
    );
  }
}