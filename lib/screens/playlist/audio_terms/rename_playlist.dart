import 'package:flutter/material.dart';

class RenamePlaylistDialog extends StatelessWidget {
  final List<String> playlists;
  final ValueChanged<String> onSelect;

  const RenamePlaylistDialog({
    super.key,
    required this.playlists,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Select Playlist to Rename',
        style: TextStyle(color: Colors.black),
      ),
      content: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: ListView.builder(
          clipBehavior: Clip.hardEdge,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            final playlistName = playlists[index];
            return ListTile(
              title: Text(
                playlistName,
                style: const TextStyle(color: Colors.black),
              ),
              onTap: () {
                onSelect(playlistName);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}