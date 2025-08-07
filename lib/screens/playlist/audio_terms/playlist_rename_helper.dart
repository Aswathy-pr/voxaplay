import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:musicvoxaplay/screens/playlist/audio_terms/dialoge_helper.dart';
import 'package:musicvoxaplay/screens/playlist/audio_terms/rename_playlist.dart';

class PlaylistRenameHelper {
  static Future<void> handleRenamePlaylist(
    BuildContext context,
    Box playlistsBox,
    Box playlistSongsBox, {
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
        builder: (context) => RenamePlaylistDialog(
          playlists: playlists,
          onSelect: (selectedName) {
            oldPlaylistName = selectedName;
          },
        ),
      );

      if (oldPlaylistName != null && context.mounted) {
        newPlaylistName = await DialogHelper.showRenamePlaylistDialog(context, oldPlaylistName!);

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

          final oldPlaylistData = playlistSongsBox.get(oldPlaylistName!);
          if (oldPlaylistData != null) {
            await playlistSongsBox.put(newPlaylistName, oldPlaylistData);
            await playlistSongsBox.delete(oldPlaylistName!);
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