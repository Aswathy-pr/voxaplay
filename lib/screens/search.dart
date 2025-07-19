import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';
import 'package:musicvoxaplay/screens/services/song_service.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';
import 'package:musicvoxaplay/screens/audio/audio_fullscreen.dart';
import 'package:musicvoxaplay/screens/audio/audio_playermanager.dart';

class Searchpage extends StatefulWidget {
  const Searchpage({super.key});

  @override
  State<Searchpage> createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  final SongService _songService = SongService();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Song>> _songsFuture;
  List<Song> _filteredSongs = [];

  @override
  void initState() {
    super.initState();
    _songsFuture = _songService.fetchSongsFromDevice();
    _searchController.addListener(_filterSongs);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterSongs);
    _searchController.dispose();
    super.dispose();
  }

  void _filterSongs() {
    _songsFuture.then((songs) {
      final query = _searchController.text.toLowerCase();
      setState(() {
        if (query.isEmpty) {
          _filteredSongs = [];
        } else {
          _filteredSongs = songs.where((song) {
            return song.title.toLowerCase().contains(query) ||
                song.artist.toLowerCase().contains(query);
          }).toList();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: buildAppBar(context, 'Search', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search songs or artists',
                hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Song>>(
                future: _songsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading songs',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No songs found',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }

                  if (_searchController.text.isEmpty) {
                    return Center(
                      child: Text(
                        'Type to search for songs or artists',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  if (_filteredSongs.isEmpty) {
                    return Center(
                      child: Text(
                        'No matching songs found',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: ClampingScrollPhysics(),
                    ),
                    itemCount: _filteredSongs.length,
                    itemBuilder: (context, index) {
                      final song = _filteredSongs[index];
                      final isPlayable = song.path.isNotEmpty;

                      return ListTile(
                        leading: song.artwork != null
                            ? Image.memory(
                                song.artwork!,
                                width: 65,
                                height: 65,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.music_note,
                                    size: 65,
                                    color: Theme.of(context).textTheme.bodyLarge!.color,
                                  );
                                },
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
                        ),
                        trailing: Icon(
                          Icons.more_horiz,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                        onTap: isPlayable
                            ? () {
                                AudioPlayerManager().player.stop();
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                    ) => AudioFullScreen(
                                      song: song,
                                      songs: snapshot.data!,
                                    ),
                                    transitionsBuilder: (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                    transitionDuration: const Duration(
                                      milliseconds: 300,
                                    ),
                                  ),
                                );
                              }
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}