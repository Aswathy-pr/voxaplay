import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicvoxaplay/screens/favourites/video_favourites.dart';
import 'package:musicvoxaplay/screens/recently_played/video_recentlyplayed.dart';
import 'package:musicvoxaplay/screens/most_played/video_mostplayed.dart';
import 'package:musicvoxaplay/screens/playlist/video_terms/video_content_helper.dart';
import 'package:musicvoxaplay/screens/widgets/video/video_playlist_button_widget.dart';

class VideoPlaylistGridWidget extends StatelessWidget {
  final List<dynamic> playlists;
  final Box playlistVideosBox;

  const VideoPlaylistGridWidget({
    super.key,
    required this.playlists,
    required this.playlistVideosBox,
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
                VideoPlaylistButtonWidget(
                  icon: Icons.favorite,
                  label: 'Favourites',
                  onTap: () => VideoContentHelper.navigateTo(
                    context,
                    const VideoFavourites(),
                  ),
                  width: halfWidth,
                ),
                VideoPlaylistButtonWidget(
                  icon: Icons.history,
                  label: 'Recently Played',
                  onTap: () => VideoContentHelper.navigateTo(
                    context,
                    const VideoRecentlyPlayedPage(),
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
                VideoPlaylistButtonWidget(
                  icon: Icons.bar_chart,
                  label: 'Most Played',
                  onTap: () => VideoContentHelper.navigateTo(
                    context,
                    const VideoMostPlayed(),
                  ),
                  width: halfWidth,
                ),
                if (playlists.isNotEmpty)
                  VideoPlaylistButtonWidget(
                    icon: Icons.playlist_play,
                    label: playlists[0],
                    onTap: () => VideoContentHelper.navigateToPlaylist(
                      context,
                      playlists[0],
                      playlistVideosBox,
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
                      VideoPlaylistButtonWidget(
                        icon: Icons.playlist_play,
                        label: playlists[i],
                        onTap: () => VideoContentHelper.navigateToPlaylist(
                          context,
                          playlists[i],
                          playlistVideosBox,
                        ),
                        width: halfWidth,
                      ),
                      if (i + 1 < playlists.length)
                        VideoPlaylistButtonWidget(
                          icon: Icons.playlist_play,
                          label: playlists[i + 1],
                          onTap: () => VideoContentHelper.navigateToPlaylist(
                            context,
                            playlists[i + 1],
                            playlistVideosBox,
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
