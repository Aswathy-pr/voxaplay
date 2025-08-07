import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';
import 'package:musicvoxaplay/screens/playlist/audio_terms/dialoge_helper.dart';

class PlaylistCreationHelper {
  static Future<void> handleCreatePlaylist(
    BuildContext context,
    Box playlistsBox,
    Box playlistSongsBox,
    Song? currentSong,
  ) async {
    try {
      final playlists = playlistsBox.get('playlists', defaultValue: [])!;
      if (playlists.length >= 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 3 playlists allowed')),
        );
        return;
      }

      final newPlaylistName = await DialogHelper.showCreatePlaylistDialog(context);
      if (newPlaylistName == null || newPlaylistName.isEmpty) return;

      if (playlists.contains(newPlaylistName)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Playlist already exists')),
        );
        return;
      }

      await playlistsBox.put('playlists', [...playlists, newPlaylistName]);

      if (currentSong != null) {
        await playlistSongsBox.put(newPlaylistName, {
          'songs': [currentSong.path],
          'createdAt': DateTime.now().toString(),
        });
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Created playlist: $newPlaylistName')),
        );
      }
    } catch (e) {
      debugPrint('Error creating playlist: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create playlist')),
        );
      }
    }
  }
}