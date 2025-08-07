import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:musicvoxaplay/screens/playlist/video_terms/rename_video_playlist.dart';
import 'package:musicvoxaplay/screens/playlist/video_terms/video_dialogue_helper.dart';

class VideoPlaylistRenameHelper {
  static Future<void> handleRenamePlaylist(
    BuildContext context,
    Box playlistsBox,
    Box playlistVideosBox, {
    required VoidCallback onRefresh,
  }) async {
    try {
      final playlists = playlistsBox.get('playlists', defaultValue: [])!;
      if (playlists.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No playlists to rename')),
        );
        return;
      }

      String? oldPlaylistName;
      String? newPlaylistName;

      await showDialog<String>(
        context: context,
        builder: (context) => RenameVideoPlaylistDialog(
          playlists: playlists,
          onSelect: (selectedName) {
            oldPlaylistName = selectedName;
          },
        ),
      );

      if (oldPlaylistName != null && context.mounted) {
        newPlaylistName = await VideoDialogHelper.showRenamePlaylistDialog(context, oldPlaylistName!);

        if (newPlaylistName != null && newPlaylistName.isNotEmpty && context.mounted) {
          if (playlists.contains(newPlaylistName)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Playlist name already exists')),
            );
            return;
          }

          final updatedPlaylists = List<String>.from(playlists);
          final index = updatedPlaylists.indexOf(oldPlaylistName!);
          if (index != -1) {
            updatedPlaylists[index] = newPlaylistName;
            await playlistsBox.put('playlists', updatedPlaylists);
          }

          final oldPlaylistData = playlistVideosBox.get(oldPlaylistName!);
          if (oldPlaylistData != null) {
            await playlistVideosBox.put(newPlaylistName, oldPlaylistData);
            await playlistVideosBox.delete(oldPlaylistName!);
          }

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Renamed playlist: $oldPlaylistName → $newPlaylistName')),
            );
            onRefresh();
          }
        }
      }
    } catch (e) {
      debugPrint('Error renaming playlist: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to rename playlist')),
        );
      }
    }
  }
}