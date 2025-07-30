
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';
import 'package:musicvoxaplay/screens/playlist/audio_terms/delete_playlist.dart';
import 'package:musicvoxaplay/screens/playlist/audio_terms/playlist_detail_page.dart';

class AudioContentHelper {
  static Future<void> migrateOldPlaylistFormat(Box playlistSongsBox) async {
    final keys = playlistSongsBox.keys.toList();
    for (final key in keys) {
      final data = playlistSongsBox.get(key);
      if (data is Map) {
        if (!data.containsKey('songs')) {
          final songs = data[key] is List<dynamic>
              ? List<String>.from(data[key] as List<dynamic>)
              : [];
          await playlistSongsBox.put(key, {
            'songs': songs,
            'createdAt': DateTime.now().toString(),
            'updatedAt': DateTime.now().toString(),
          });
        }
      } else {
        await playlistSongsBox.put(key, {
          'songs': [],
          'createdAt': DateTime.now().toString(),
          'updatedAt': DateTime.now().toString(),
        });
      }
    }
  }

  static void navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  static void navigateToPlaylist(BuildContext context, String playlistName, Box playlistSongsBox) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistDetailPage(
          playlistName: playlistName,
          playlistSongsBox: playlistSongsBox,
        ),
      ),
    );
  }

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

      final newPlaylistName = await _showCreatePlaylistDialog(context);
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

  static Future<void> handleDeletePlaylist(
    BuildContext context,
    Box playlistsBox,
    Box playlistSongsBox, {
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

      final deletedPlaylist = await showDialog<String>(
        context: context,
        builder: (context) => DeletePlaylistDialog(
          playlists: playlists,
          playlistSongsBox: playlistSongsBox,
          onDelete: (deletedName) {
            
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

  static Future<String?> _showCreatePlaylistDialog(BuildContext context) async {
    String playlistName = '';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Playlist'),
        content: TextField(
          autofocus: true,
          onChanged: (value) => playlistName = value,
          decoration: const InputDecoration(
            hintText: 'Enter playlist name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (playlistName.isNotEmpty) {
                Navigator.pop(context, playlistName);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
