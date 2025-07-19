import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';
import 'package:musicvoxaplay/screens/playlist/audio_terms/add_selected_song.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';

class PlaylistDetailPage extends StatefulWidget {
  final String playlistName;
  final Box playlistSongsBox;

  const PlaylistDetailPage({
    super.key,
    required this.playlistName,
    required this.playlistSongsBox,
  });

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  late Box<Song> songsBox;
  List<String> playlistSongs = [];

  @override
  void initState() {
    super.initState();
    songsBox = Hive.box<Song>('songsBox');
    _loadPlaylistSongs();
  }

  void _loadPlaylistSongs() {
    final playlistData = widget.playlistSongsBox.get(widget.playlistName);
    if (playlistData != null && playlistData['songs'] is List) {
      setState(() {
        playlistSongs = List<String>.from(playlistData['songs']);
      });
    }
  }

  Future<void> _removeSong(int index) async {
    final updatedSongs = List<String>.from(playlistSongs);
    final removedSong = updatedSongs.removeAt(index);

    await widget.playlistSongsBox.put(widget.playlistName, {
      ...widget.playlistSongsBox.get(widget.playlistName) ?? {},
      'songs': updatedSongs,
      'updatedAt': DateTime.now().toString(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed song from ${widget.playlistName}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            updatedSongs.insert(index, removedSong);
            await widget.playlistSongsBox.put(widget.playlistName, {
              ...widget.playlistSongsBox.get(widget.playlistName) ?? {},
              'songs': updatedSongs,
            });
            _loadPlaylistSongs();
          },
        ),
      ),
    );
    _loadPlaylistSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: buildAppBar(context, widget.playlistName, showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder(
          valueListenable: widget.playlistSongsBox.listenable(),
          builder: (context, Box box, _) {
            final playlistData = box.get(widget.playlistName);
            playlistSongs =
                playlistData != null && playlistData['songs'] is List
                ? List<String>.from(playlistData['songs'])
                : [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Songs in Playlist',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '(${playlistSongs.length})',
                      style: TextStyle(color: AppColors.grey, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: playlistSongs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.playlist_add,
                                size: 60,
                                color: AppColors.grey.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No songs in this playlist yet',
                                style: TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: playlistSongs.length,
                          itemBuilder: (context, index) {
                            final songPath = playlistSongs[index];
                            final song = songsBox.values.firstWhere(
                              (s) => s.path == songPath,
                              orElse: () => Song(
                                'Unknown Title',
                                'Unknown Artist',
                                songPath,
                              ),
                            );

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              color: AppColors.grey.withOpacity(0.1),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                leading: song.artwork != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.memory(
                                          song.artwork!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: AppColors.grey.withOpacity(
                                            0.3,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.music_note,
                                          color: AppColors.white,
                                        ),
                                      ),
                                title: Text(
                                  song.title,
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  song.artist,
                                  style: TextStyle(color: AppColors.grey),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.remove_circle,
                                    color: AppColors.red,
                                  ),
                                  onPressed: () => _removeSong(index),
                                ),
                                onTap: () {
                                  // Add your song playback logic here
                                },
                              ),
                            );
                          },
                        ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddSongsPage(
                          playlistName: widget.playlistName,
                          playlistSongsBox: widget.playlistSongsBox,
                        ),
                      ),
                    );
                    // No need to call _loadPlaylistSongs() since ValueListenableBuilder handles updates
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Add New Songs',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
     ),
);
}
}