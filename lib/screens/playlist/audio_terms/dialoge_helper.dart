import 'package:flutter/material.dart';

class DialogHelper {
  static Future<String?> showCreatePlaylistDialog(BuildContext context) async {
    String playlistName = '';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Playlist', style: TextStyle(color: Colors.black)),
        content: TextField(
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

  static Future<String?> showRenamePlaylistDialog(BuildContext context, String currentName) async {
    String newPlaylistName = currentName;
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Playlist', style: TextStyle(color: Colors.black)),
        content: TextField(
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