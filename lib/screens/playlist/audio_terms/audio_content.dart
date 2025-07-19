import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicvoxaplay/screens/favourites/favourites.dart';
import 'package:musicvoxaplay/screens/recently_played/audio_recently.dart';
import 'package:musicvoxaplay/screens/most_played/audio_mostplayed.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';
import 'package:musicvoxaplay/screens/playlist/audio_terms/audio_content_helper.dart';
import 'package:musicvoxaplay/screens/widgets/audio/playlist_button_widget.dart';

class AudioContent extends StatefulWidget {
  final Song? currentSong;
  const AudioContent({super.key, this.currentSong});

  @override
  State<AudioContent> createState() => _AudioContentState();
}

class _AudioContentState extends State<AudioContent> {
  late final Box _playlistsBox;
  late final Box _playlistSongsBox;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeHiveBoxes();
  }

  Future<void> _initializeHiveBoxes() async {
    try {
      _playlistsBox = await Hive.openBox('playlistsBox');
      _playlistSongsBox = await Hive.openBox('playlistSongsBox');
      await AudioContentHelper.migrateOldPlaylistFormat(_playlistSongsBox);
    } catch (e) {
      debugPrint('Error initializing Hive boxes: $e');
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder(
                valueListenable: _playlistsBox.listenable(),
                builder: (context, Box box, _) {
                  final playlists = box.get('playlists', defaultValue: [])!;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final halfWidth = constraints.maxWidth / 2 - 8;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row 1: Favourites & Recently Played
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              PlaylistButtonWidget(
                                icon: Icons.favorite,
                                label: 'Favourites',
                                onTap: () => AudioContentHelper.navigateTo(
                                  context,
                                  const Favourites(),
                                ),
                                width: halfWidth,
                              ),
                              PlaylistButtonWidget(
                                icon: Icons.history,
                                label: 'Recently Played',
                                onTap: () => AudioContentHelper.navigateTo(
                                  context,
                                  const RecentlyPlayedPage(),
                                ),
                                width: halfWidth,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Row 2: Most Played & First Custom Playlist
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              PlaylistButtonWidget(
                                icon: Icons.bar_chart,
                                label: 'Most Played',
                                onTap: () => AudioContentHelper.navigateTo(
                                  context,
                                  const MostPlayed(),
                                ),
                                width: halfWidth,
                              ),
                              if (playlists.isNotEmpty)
                                PlaylistButtonWidget(
                                  icon: Icons.playlist_play,
                                  label: playlists[0],
                                  onTap: () =>
                                      AudioContentHelper.navigateToPlaylist(
                                        context,
                                        playlists[0],
                                        _playlistSongsBox,
                                      ),
                                  width: halfWidth,
                                )
                              else
                                const SizedBox(width: 8), // Empty space if no playlists
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Remaining Custom playlists in 2-column layout
                          if (playlists.length > 1) ...[
                            for (int i = 1; i < playlists.length; i += 2)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    PlaylistButtonWidget(
                                      icon: Icons.playlist_play,
                                      label: playlists[i],
                                      onTap: () =>
                                          AudioContentHelper.navigateToPlaylist(
                                            context,
                                            playlists[i],
                                            _playlistSongsBox,
                                          ),
                                      width: halfWidth,
                                    ),
                                    if (i + 1 < playlists.length)
                                      PlaylistButtonWidget(
                                        icon: Icons.playlist_play,
                                        label: playlists[i + 1],
                                        onTap: () =>
                                            AudioContentHelper.navigateToPlaylist(
                                              context,
                                              playlists[i + 1],
                                              _playlistSongsBox,
                                            ),
                                        width: halfWidth,
                                      )
                                    else
                                      SizedBox(
                                        width: halfWidth,
                                      ), // Empty to align last odd item
                                  ],
                                ),
                              ),
                            const SizedBox(height: 20),
                          ],

                          const SizedBox(height: 30),
                          Text(
                            'My Playlist',
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                          ),
                          const SizedBox(height: 20),

                          // Create new playlist
                          PlaylistButtonWidget(
                            icon: Icons.add,
                            label: 'Create New Playlist',
                            onTap: () =>
                                AudioContentHelper.handleCreatePlaylist(
                                  context,
                                  _playlistsBox,
                                  _playlistSongsBox,
                                  widget.currentSong,
                                ),
                          ),
                          const SizedBox(height: 20),

                          // Delete playlist
                          PlaylistButtonWidget(
                            icon: Icons.delete,
                            label: 'Delete Playlist',
                            onTap: () =>
                                AudioContentHelper.handleDeletePlaylist(
                                  context,
                                  _playlistsBox,
                                  _playlistSongsBox,
                                  onRefresh: () => setState(() {}),
                                ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _playlistsBox.close();
    _playlistSongsBox.close();
    super.dispose();
  }
}
