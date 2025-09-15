import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/favourites/add_favourite_songs.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';
import 'package:musicvoxaplay/screens/services/song_service.dart';
import 'package:musicvoxaplay/screens/menubars/song_menubar/playnext_service.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';
import 'package:musicvoxaplay/screens/widgets/bottom_navigationbar.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';
import 'package:musicvoxaplay/screens/audio/audio_fullscreen.dart';
import 'package:musicvoxaplay/screens/audio/audio_playermanager.dart';
import 'package:musicvoxaplay/screens/menubars/song_menubar/song_menubar.dart';
import 'package:just_audio/just_audio.dart';

class Favourites extends StatefulWidget {
  const Favourites({super.key});

  @override
  State<Favourites> createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  int _currentIndex = 3;
  final SongService _songService = SongService();
  final AudioPlayer _audioPlayer = AudioPlayerManager().player;
  late final PlayNextService _playNextService;

  @override
  void initState() {
    super.initState();
    _playNextService = PlayNextService(songService: _songService, audioPlayer: _audioPlayer);
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _toggleFavorite(Song song) async {
    try {
      setState(() {
        song.isFavorite = !song.isFavorite;
      });
      await _songService.updateFavoriteStatus(song);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            song.isFavorite
                ? 'Added to Favorites'
                : 'Removed from Favorites',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          backgroundColor: Colors.red[900],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating favorite: $e'),
          backgroundColor: Colors.red[900],
        ),
      );
      setState(() {
        song.isFavorite = !song.isFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: buildAppBar(context, 'Favourites', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FutureBuilder<List<Song>>(
                  future: _songService.getFavoriteSongs(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading favourites',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'Favourites list is empty',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }

                    final songs = snapshot.data!;
                    return ListView.builder(
                      clipBehavior: Clip.hardEdge,
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
                                      : AppColors.grey,
                                ),
                          ),
                          subtitle: Text(
                            song.artist,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: isPlayable
                                      ? Theme.of(context).textTheme.bodyMedium!.color
                                      : AppColors.grey,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    song.isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: song.isFavorite
                                        ? AppColors.red
                                        : Theme.of(context).textTheme.bodyLarge!.color,
                                    size: 20.0,
                                  ),
                                  onPressed: () => _toggleFavorite(song),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
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
                                          playNextService: _playNextService,
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
                                    await _songService.addToRecentlyPlayed(song); 
                                    await _songService.incrementPlayCount(song); 
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AudioFullScreen(
                                          song: song,
                                          songs: songs,
                                          songService: _songService, 
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error playing song: $e'),
                                        backgroundColor: Colors.red[900],
                                      ),
                                    );
                                  }
                                }
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddFavoriteSongsPage(
                        songService: _songService,
                      ),
                    ),
                  );
                  setState(() {}); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Add New Songs',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        context: context,
      ),
    );
  }
}