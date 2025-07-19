import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';
import 'package:musicvoxaplay/screens/audio/audio_fullscreen.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';
import 'package:musicvoxaplay/screens/widgets/bottom_navigationbar.dart';


class RecentlyPlayedPage extends StatefulWidget {
  const RecentlyPlayedPage({super.key});

  @override
  _RecentlyPlayedPageState createState() => _RecentlyPlayedPageState();
}

class _RecentlyPlayedPageState extends State<RecentlyPlayedPage> {
  int _currentIndex = 2; 

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: buildAppBar(context, 'Recently Played', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: ValueListenableBuilder<Box<Song>>(
            valueListenable: Hive.box<Song>('recentlyPlayed').listenable(),
            builder: (context, box, _) {
              print('RecentlyPlayedPage: Box contains ${box.length} songs');
              // Filter duplicates by path
              final songsMap = <String, Song>{};
              for (var song in box.values) {
                songsMap[song.path] = song;
              }
              final songs = songsMap.values.toList()
                ..sort((a, b) => (b.playedAt ?? DateTime(0)).compareTo(a.playedAt ?? DateTime(0)));

              if (songs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No recently played songs.',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontSize: 20,
                            ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return ListTile(
                    leading: song.artwork != null
                        ? Image.memory(
                            song.artwork!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.music_note,
                                size: 50,
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
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      song.artist,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: Icon(
                      Icons.more_horiz,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AudioFullScreen(song: song, songs: songs),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        context: context,
      ),
    );
  }
}