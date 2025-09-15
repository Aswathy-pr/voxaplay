

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';
import 'package:musicvoxaplay/screens/playlist/audio_terms/delete_playlist.dart';
import 'package:musicvoxaplay/screens/playlist/audio_terms/playlist_detail_page.dart';
import 'package:musicvoxaplay/screens/playlist/audio_terms/rename_playlist.dart';

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
      final playlists = List<String>.from(playlistsBox.get('playlists', defaultValue: []) ?? []);
      final newPlaylistName = await _showCreatePlaylistDialog(context);
      if (newPlaylistName == null || newPlaylistName.isEmpty) return;

      if (playlists.contains(newPlaylistName)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playlist already exists'),
            backgroundColor: Colors.red[900],
          ),
        );
        return;
      }

      await playlistsBox.put('playlists', [...playlists, newPlaylistName]);

      if (currentSong != null) {
        await playlistSongsBox.put(newPlaylistName, {
          'songs': [currentSong.path],
          'createdAt': DateTime.now().toString(),
          'updatedAt': DateTime.now().toString(),
        });
      } else {
        await playlistSongsBox.put(newPlaylistName, {
          'songs': [],
          'createdAt': DateTime.now().toString(),
          'updatedAt': DateTime.now().toString(),
        });
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Created playlist: $newPlaylistName'),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error creating playlist: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create playlist'),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    }
  }

  static Future<void> handleRenamePlaylist(
    BuildContext context,
    Box playlistsBox,
    Box playlistSongsBox, {
    required VoidCallback onRefresh,
  }) async {
    try {
      final playlists = List<String>.from(playlistsBox.get('playlists', defaultValue: []) ?? []);
      if (playlists.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No playlists to rename'),
            backgroundColor: Colors.red[900],
          ),
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
        newPlaylistName = await _showRenamePlaylistDialog(context, oldPlaylistName!);

        if (newPlaylistName != null && newPlaylistName.isNotEmpty && context.mounted) {
          if (playlists.contains(newPlaylistName)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Playlist name already exists'),
                backgroundColor: Colors.red[900],
              ),
            );
            return;
          }

          final oldPlaylistData = playlistSongsBox.get(oldPlaylistName!);
          final updatedPlaylists = List<String>.from(playlists);
          final index = updatedPlaylists.indexOf(oldPlaylistName!);
          if (index != -1) {
            updatedPlaylists[index] = newPlaylistName;
            await playlistsBox.put('playlists', updatedPlaylists);
          }

          if (oldPlaylistData != null) {
            await playlistSongsBox.put(newPlaylistName, oldPlaylistData);
            await playlistSongsBox.delete(oldPlaylistName!);
          }

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Renamed playlist: $oldPlaylistName → $newPlaylistName'),
                backgroundColor: Colors.red[900],
              ),
            );
            onRefresh();
          }
        }
      }
    } catch (e) {
      debugPrint('Error renaming playlist: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to rename playlist'),
            backgroundColor: Colors.red[900],
          ),
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
      final playlists = List<String>.from(playlistsBox.get('playlists', defaultValue: []) ?? []);
      if (playlists.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No playlists to delete'),
            backgroundColor: Colors.red[900],
          ),
        );
        return;
      }

      String? deletedPlaylist;
      await showDialog<String>(
        context: context,
        builder: (context) => DeletePlaylistDialog(
          playlists: playlists,
          playlistSongsBox: playlistSongsBox,
          onDelete: (deletedName) {
            deletedPlaylist = deletedName;
          },
        ),
      );

      if (deletedPlaylist != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted playlist: $deletedPlaylist'),
            backgroundColor: Colors.red[900],
          ),
        );
        onRefresh();
      }
    } catch (e) {
      debugPrint('Error deleting playlist: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete playlist'),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    }
  }

  static Future<String?> _showCreatePlaylistDialog(BuildContext context) async {
    String playlistName = '';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Create New Playlist',
          style: TextStyle(color: Colors.black),
        ),
        content: SingleChildScrollView(
          child: TextField(
            autofocus: true,
            onChanged: (value) => playlistName = value,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              hintText: 'Enter playlist name',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
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

  static Future<String?> _showRenamePlaylistDialog(BuildContext context, String currentName) async {
    String newPlaylistName = currentName;
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Rename Playlist',
          style: TextStyle(color: Colors.black),
        ),
        content: SingleChildScrollView(
          child: TextField(
            autofocus: true,
            controller: TextEditingController(text: currentName),
            onChanged: (value) => newPlaylistName = value,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              hintText: 'Enter new playlist name',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (newPlaylistName.isNotEmpty) {
                Navigator.pop(context, newPlaylistName);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }
}
