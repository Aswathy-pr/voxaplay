import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';

class AddSongsPage extends StatefulWidget {
  final String playlistName;
  final Box playlistSongsBox;

  const AddSongsPage({
    super.key,
    required this.playlistName,
    required this.playlistSongsBox,
  });

  @override
  State<AddSongsPage> createState() => _AddSongsPageState();
}

class _AddSongsPageState extends State<AddSongsPage> {
  late Box<Song> songsBox;
  List<String> playlistSongs = [];
  bool showRecentlyPlayed = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    songsBox = Hive.box<Song>('songsBox');
    _loadPlaylistSongs();
  }

  void _loadPlaylistSongs() {
    final playlistData = widget.playlistSongsBox.get(widget.playlistName);
    if (playlistData != null && playlistData['songs'] != null) {
      setState(() {
        playlistSongs = List<String>.from(playlistData['songs'] ?? []);
      });
    }
  }

  List<Song> _filterSongs(List<Song> allSongs) {
    var filtered = allSongs.where((song) =>
        song.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
        song.artist.toLowerCase().contains(searchQuery.toLowerCase()));

    if (showRecentlyPlayed) {
      filtered = filtered.where((song) => song.playedAt != null);
    }

    return filtered.toList();
  }

  Future<void> _toggleSongInPlaylist(Song song) async {
    final playlistData = widget.playlistSongsBox.get(widget.playlistName) ?? {};
    final currentSongs = List<String>.from(playlistData['songs'] ?? []);

    setState(() {
      if (currentSongs.contains(song.path)) {
        currentSongs.remove(song.path);
      } else {
        currentSongs.add(song.path);
      }
    });

    await widget.playlistSongsBox.put(widget.playlistName, {
      ...playlistData,
      'songs': currentSongs,
      'updatedAt': DateTime.now().toIso8601String(),
    });

    _loadPlaylistSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: buildAppBar(
        context,
        'Add Songs to ${widget.playlistName}',
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search songs...',
                hintStyle: TextStyle(color: AppColors.grey),
                prefixIcon: Icon(Icons.search, color: AppColors.white),
                filled: true,
                fillColor: AppColors.grey.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: AppColors.white),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Checkbox(
                  value: showRecentlyPlayed,
                  onChanged: (value) => setState(() => showRecentlyPlayed = value ?? false),
                  fillColor: MaterialStateProperty.resolveWith<Color>(
                    (states) => states.contains(MaterialState.selected)
                        ? AppColors.red
                        : AppColors.grey,
                  ),
                ),
                const Text(
                  'Recently played',
                  style: TextStyle(color: AppColors.white),
                ),
                const Spacer(),
                Text(
                  '${playlistSongs.length} songs in playlist',
                  style: TextStyle(color: AppColors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ValueListenableBuilder(
                valueListenable: songsBox.listenable(),
                builder: (context, Box<Song> box, _) {
                  final allSongs = box.values.toList();
                  final displayedSongs = _filterSongs(allSongs);

                  return displayedSongs.isEmpty
                      ? Center(
                          child: Text(
                            searchQuery.isEmpty
                                ? 'No songs available'
                                : 'No matching songs found',
                            style: TextStyle(color: AppColors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: displayedSongs.length,
                          itemBuilder: (context, index) {
                            final song = displayedSongs[index];
                            final isInPlaylist = playlistSongs.contains(song.path);

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
                                          color: AppColors.grey.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(4),
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
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      song.artist,
                                      style: TextStyle(color: AppColors.grey),
                                    ),
                                    if (song.playedAt != null)
                                      Text(
                                        'Played ${song.playedAt!.toString().split(' ')[0]}',
                                        style: TextStyle(
                                          color: AppColors.red.withOpacity(0.8),
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    isInPlaylist ? Icons.check : Icons.add,
                                    color: isInPlaylist ? AppColors.white : AppColors.red,
                                    size: 24,
                                  ),
                                  onPressed: () => _toggleSongInPlaylist(song),
                                ),
                              ),
                            );
                          },
                        );
                },
              ),
            ),
          ],
        ),
     ),
);
}
}