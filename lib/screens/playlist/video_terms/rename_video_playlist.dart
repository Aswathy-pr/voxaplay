import 'package:flutter/material.dart';

class RenameVideoPlaylistDialog extends StatefulWidget {
  final List<String> playlists;
  final ValueChanged<String> onSelect;

  const RenameVideoPlaylistDialog({
    super.key,
    required this.playlists,
    required this.onSelect,
  });

  @override
  _RenameVideoPlaylistDialogState createState() => _RenameVideoPlaylistDialogState();
}

class _RenameVideoPlaylistDialogState extends State<RenameVideoPlaylistDialog> {
  String? selectedPlaylist;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      title: Text(
        'Select Video Playlist to Rename',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
      content: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: ListView.builder(
          clipBehavior: Clip.hardEdge,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: widget.playlists.length,
          itemBuilder: (context, index) {
            final playlist = widget.playlists[index];
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
          },
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
                  widget.onSelect(selectedPlaylist!);
                  Navigator.pop(context);
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