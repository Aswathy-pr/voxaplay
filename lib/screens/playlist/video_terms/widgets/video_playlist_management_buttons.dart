import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicvoxaplay/screens/models/video_models.dart';
import 'package:musicvoxaplay/screens/playlist/video_terms/video_content_helper.dart';
import 'package:musicvoxaplay/screens/widgets/video/video_playlist_button_widget.dart';

class VideoPlaylistManagementButtons extends StatelessWidget {
  final Box playlistsBox;
  final Box playlistVideosBox;
  final Video? currentVideo;
  final VoidCallback onRefresh;

  const VideoPlaylistManagementButtons({
    super.key,
    required this.playlistsBox,
    required this.playlistVideosBox,
    required this.currentVideo,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        VideoPlaylistButtonWidget(
          icon: Icons.add,
          label: 'Create New Playlist',
          onTap: () =>
              VideoContentHelper.handleCreatePlaylist(
                context,
                playlistsBox,
                playlistVideosBox,
                currentVideo,
              ),
        ),
        const SizedBox(height: 20),

        // Rename playlist
        VideoPlaylistButtonWidget(
          icon: Icons.edit,
          label: 'Rename Playlist',
          onTap: () =>
              VideoContentHelper.handleRenamePlaylist(
                context,
                playlistsBox,
                playlistVideosBox,
                onRefresh: onRefresh,
              ),
        ),
        const SizedBox(height: 20),

        // Delete playlist
        VideoPlaylistButtonWidget(
          icon: Icons.delete,
          label: 'Delete Playlist',
          onTap: () =>
              VideoContentHelper.handleDeletePlaylist(
                context,
                playlistsBox,
                playlistVideosBox,
                onRefresh: onRefresh,
              ),
        ),
      ],
    );
  }
} 