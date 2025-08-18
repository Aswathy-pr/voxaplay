import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DeleteVideoPlaylistDialog extends StatefulWidget {
  final List<String> playlists;
  final Box playlistVideosBox;
  final ValueChanged<String> onDelete;

  const DeleteVideoPlaylistDialog({
    super.key,
    required this.playlists,
    required this.playlistVideosBox,
    required this.onDelete,
  });

  @override
  _DeleteVideoPlaylistDialogState createState() => _DeleteVideoPlaylistDialogState();
}

class _DeleteVideoPlaylistDialogState extends State<DeleteVideoPlaylistDialog> {
  String? selectedPlaylist;

  @override
  Widget build(BuildContext context) {
    final Box playlistsBox = Hive.box('videoPlaylistsBox');

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      title: Text(
        'Delete Video Playlist',
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
                  Icons.delete,
                  color: selectedPlaylist == playlist ? Colors.red[900] : Colors.grey[800],
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
              : () async {
                  try {
                    final updatedPlaylists = List<String>.from(playlistsBox.get('playlists') ?? []);
                    if (updatedPlaylists.contains(selectedPlaylist)) {
                      updatedPlaylists.remove(selectedPlaylist!);
                      await playlistsBox.put('playlists', updatedPlaylists);
                      await widget.playlistVideosBox.delete(selectedPlaylist!);
                      widget.onDelete(selectedPlaylist!);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
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
                },
          style: TextButton.styleFrom(
            backgroundColor: Colors.red[900],
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