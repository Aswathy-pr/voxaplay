import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';
import 'package:musicvoxaplay/screens/services/song_service.dart';
import 'package:musicvoxaplay/screens/song_menu/playnext_service.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';
import 'package:musicvoxaplay/screens/song_menu/play_pause_widghet.dart';
import 'package:musicvoxaplay/screens/song_menu/add_to_playlist.dart';

class SongMenuPage extends StatefulWidget {
  final Song song;
  final AudioPlayer audioPlayer;
  final SongService songService;
  final PlayNextService playNextService;

  const SongMenuPage({
    Key? key,
    required this.song,
    required this.audioPlayer,
    required this.songService,
    required this.playNextService,
  }) : super(key: key);

  @override
  _SongMenuPageState createState() => _SongMenuPageState();
}

class _SongMenuPageState extends State<SongMenuPage> {
  late Song _song; 

  @override
  void initState() {
    super.initState();
    _song = widget.song; 
  }

  Future<void> _toggleFavorite() async {
    try {
      setState(() {
        _song = Song(
          _song.title,
          _song.artist,
          _song.path,
          artwork: _song.artwork,
          isFavorite: !_song.isFavorite, 
          playcount: _song.playcount,
          playedAt: _song.playedAt,
        );
      });
      await widget.songService.updateFavoriteStatus(_song); 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[900],
            content: Text(
              _song.isFavorite
                  ? 'Added to Favorites'
                  : 'Removed from Favorites',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {

      setState(() {
        _song = Song(
          _song.title,
          _song.artist,
          _song.path,
          artwork: _song.artwork,
          isFavorite: !_song.isFavorite, 
          playcount: _song.playcount,
          playedAt: _song.playedAt,
        );
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating favorite: $e'),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    }
  }

  Future<void> _playNextSong() async {
    try {
      final nextSong = await widget.playNextService.playNext(_song);
      if (nextSong != null && mounted) {
        setState(() {
          _song = nextSong; 
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[900],
            content: Text('Playing next song: "${nextSong.title}"'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[900],
            content: const Text('No next song available'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[900],
            content: Text('Error playing next song: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _addToPlaylist() async {
    try {
      // Open Hive boxes
      final playlistsBox = await Hive.openBox('playlistsBox');
      final playlistSongsBox = await Hive.openBox('playlistSongsBox');
      
      final playlists = playlistsBox.get('playlists', defaultValue: [])!;
      
      if (playlists.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red[900],
              content: Text('No playlists available. Create a playlist first.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Show playlist selection dialog
      String? selectedPlaylist;
      await showDialog<String>(
        context: context,
        builder: (context) => AddToPlaylistDialog(
          playlists: playlists,
          onSelect: (playlistName) {
            selectedPlaylist = playlistName;
          },
        ),
      );

      if (selectedPlaylist != null && mounted) {
        // Get current playlist data
        final playlistData = playlistSongsBox.get(selectedPlaylist);
        List<String> songs = [];
        
        if (playlistData != null && playlistData['songs'] != null) {
          songs = List<String>.from(playlistData['songs']);
        }

        // Check if song is already in playlist
        if (songs.contains(_song.path)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red[900],
                content: Text('Song is already in "$selectedPlaylist"'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
          return;
        }

        // Add song to playlist
        songs.add(_song.path);
        await playlistSongsBox.put(selectedPlaylist, {
          'songs': songs,
          'createdAt': playlistData?['createdAt'] ?? DateTime.now().toString(),
          'updatedAt': DateTime.now().toString(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red[900],
              content: Text('Added "${_song.title}" to "$selectedPlaylist"'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[900],
            content: Text('Error adding to playlist: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: buildAppBar(context, 'Song Options', showBackButton: true),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      _song.artwork != null
                          ? Image.memory(
                              _song.artwork!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.music_note,
                              color: Theme.of(context).textTheme.bodyLarge!.color,
                              size: 20,
                            ),
                      const SizedBox(width: 30),
                      Expanded(
                        child: Text(
                          _song.title,
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _song.artist,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  PlayPauseWidget(song: _song, audioPlayer: widget.audioPlayer),
                  _buildMenuItem(
                    context,
                    Icons.skip_next,
                    'Play Next',
                    onTap: _playNextSong,
                  ),
                  _buildMenuItem(
                    context,
                    _song.isFavorite ? Icons.favorite : Icons.favorite_border,
                    _song.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                    onTap: _toggleFavorite,
                  ),
                  _buildMenuItem(
                    context,
                    Icons.playlist_add,
                    'Add to Playlist',
                    onTap: _addToPlaylist,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String text, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            Icon(
              icon,
              color: icon == Icons.favorite && _song.isFavorite
                  ? Colors.red
                  : Theme.of(context).textTheme.bodyLarge!.color,
              size: 30,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}