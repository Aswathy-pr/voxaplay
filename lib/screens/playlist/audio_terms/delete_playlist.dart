import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DeletePlaylistDialog extends StatefulWidget {
  final List<dynamic> playlists;
  final Box playlistSongsBox;
  final Function(String?) onDelete;

  const DeletePlaylistDialog({
    super.key,
    required this.playlists,
    required this.playlistSongsBox, 
    required this.onDelete,
  });

  @override
  _DeletePlaylistDialogState createState() => _DeletePlaylistDialogState();
}

class _DeletePlaylistDialogState extends State<DeletePlaylistDialog> {
  String? selectedPlaylist;

  @override
  Widget build(BuildContext context) {
    final Box playlistsBox = Hive.box('playlistsBox');

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      title: Text(
        'Delete Playlist',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
      content: Container(
        constraints: const BoxConstraints(maxHeight: 200),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.playlists.map((playlist) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.delete,
                    color: selectedPlaylist == playlist ? Colors.red : Colors.grey[800],
                  ),
                  title: Text(
                    playlist,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selectedPlaylist = playlist;
                    });
                  },
                  selected: selectedPlaylist == playlist,
                  selectedTileColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                ),
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.black87),
          ),
        ),
        TextButton(
          onPressed: selectedPlaylist == null
              ? null
              : () {
                  if (selectedPlaylist != null) {
                    final updatedPlaylists = List<String>.from(playlistsBox.get('playlists') ?? []);
                    if (updatedPlaylists.contains(selectedPlaylist)) {
                      updatedPlaylists.remove(selectedPlaylist!);
                      playlistsBox.put('playlists', updatedPlaylists);
                      widget.playlistSongsBox.delete(selectedPlaylist!); // Use passed box
                      widget.onDelete(selectedPlaylist);
                      Navigator.pop(context);
                    }
                  }
                },
          style: TextButton.styleFrom(
            backgroundColor: Colors.red[400],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text(
            'Delete',
            style: TextStyle(color: Colors.white),
          ),
        ),
     ],
);
}
}