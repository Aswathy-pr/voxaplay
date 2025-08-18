import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DeletePlaylistDialog extends StatelessWidget {
  final List<String> playlists;
  final Box playlistSongsBox;
  final ValueChanged<String> onDelete;

  const DeletePlaylistDialog({
    super.key,
    required this.playlists,
    required this.playlistSongsBox,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Delete Playlist',
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
              trailing: Icon(
                Icons.delete,
                color: Colors.red[900],
              ),
              onTap: () async {
                await playlistSongsBox.delete(playlistName);
                final playlistsBox = Hive.box('playlistsBox');
                final updatedPlaylists = List<String>.from(playlists)..remove(playlistName);
                await playlistsBox.put('playlists', updatedPlaylists);
                onDelete(playlistName);
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