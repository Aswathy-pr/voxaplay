import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:musicvoxaplay/screens/playlist/video_terms/delete_video_playlist.dart';

class VideoPlaylistDeleteHelper {
  static Future<void> handleDeletePlaylist(
    BuildContext context,
    Box playlistsBox,
    Box playlistVideosBox, {
    required VoidCallback onRefresh,
  }) async {
    try {
      final playlists = playlistsBox.get('playlists', defaultValue: [])!;
      if (playlists.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No playlists to delete')),
        );
        return;
      }

      String? deletedPlaylist;
      await showDialog<String>(
        context: context,
        builder: (context) => DeleteVideoPlaylistDialog(
          playlists: playlists,
          playlistVideosBox: playlistVideosBox,
          onDelete: (deletedName) {
            deletedPlaylist = deletedName;
          },
        ),
      );

      if (deletedPlaylist != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted playlist: $deletedPlaylist')),
        );
        onRefresh();
      }
    } catch (e) {
      debugPrint('Error deleting playlist: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete playlist')),
        );
      }
    }
  }
}