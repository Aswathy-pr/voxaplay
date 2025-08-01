import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';
import 'package:musicvoxaplay/screens/playlist/audio_terms/audio_content_helper.dart';
import 'package:musicvoxaplay/screens/widgets/audio/playlist_button_widget.dart';

class PlaylistManagementButtons extends StatelessWidget {
  final Box playlistsBox;
  final Box playlistSongsBox;
  final Song? currentSong;
  final VoidCallback onRefresh;

  const PlaylistManagementButtons({
    super.key,
    required this.playlistsBox,
    required this.playlistSongsBox,
    required this.currentSong,
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
        PlaylistButtonWidget(
          icon: Icons.add,
          label: 'Create New Playlist',
          onTap: () =>
              AudioContentHelper.handleCreatePlaylist(
                context,
                playlistsBox,
                playlistSongsBox,
                currentSong,
              ),
        ),
        const SizedBox(height: 20),

        // Rename playlist
        PlaylistButtonWidget(
          icon: Icons.edit,
          label: 'Rename Playlist',
          onTap: () =>
              AudioContentHelper.handleRenamePlaylist(
                context,
                playlistsBox,
                playlistSongsBox,
                onRefresh: onRefresh,
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
                playlistsBox,
                playlistSongsBox,
                onRefresh: onRefresh,
              ),
        ),
      ],
    );
  }
} 