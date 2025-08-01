import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicvoxaplay/screens/favourites/favourites.dart';
import 'package:musicvoxaplay/screens/recently_played/audio_recently.dart';
import 'package:musicvoxaplay/screens/most_played/audio_mostplayed.dart';
import 'package:musicvoxaplay/screens/playlist/audio_terms/audio_content_helper.dart';
import 'package:musicvoxaplay/screens/widgets/audio/playlist_button_widget.dart';

class PlaylistGridWidget extends StatelessWidget {
  final List<dynamic> playlists;
  final Box playlistSongsBox;

  const PlaylistGridWidget({
    super.key,
    required this.playlists,
    required this.playlistSongsBox,
  });

  @override
  Widget build(BuildContext context) {
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
                          playlistSongsBox,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PlaylistButtonWidget(
                        icon: Icons.playlist_play,
                        label: playlists[i],
                        onTap: () =>
                            AudioContentHelper.navigateToPlaylist(
                              context,
                              playlists[i],
                              playlistSongsBox,
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
                                playlistSongsBox,
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
          ],
        );
      },
    );
  }
} 