import 'package:flutter/material.dart';

class RenamePlaylistDialog extends StatefulWidget {
  final List<dynamic> playlists;
  final Function(String?) onSelect;

  const RenamePlaylistDialog({
    super.key,
    required this.playlists,
    required this.onSelect,
  });

  @override
  _RenamePlaylistDialogState createState() => _RenamePlaylistDialogState();
}

class _RenamePlaylistDialogState extends State<RenamePlaylistDialog> {
  String? selectedPlaylist;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      title: Text(
        'Select Playlist to Rename',
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
                    Icons.edit,
                    color: selectedPlaylist == playlist ? Colors.blue : Colors.grey[800],
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
                    widget.onSelect(selectedPlaylist);
                    Navigator.pop(context);
                  }
                },
          style: TextButton.styleFrom(
            backgroundColor: Colors.blue[400],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text(
            'Select',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
} 