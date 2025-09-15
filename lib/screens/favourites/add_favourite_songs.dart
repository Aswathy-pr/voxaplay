
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';
import 'package:musicvoxaplay/screens/services/song_service.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';

class AddFavoriteSongsPage extends StatefulWidget {
  final SongService songService;

  const AddFavoriteSongsPage({
    super.key,
    required this.songService,
  });

  @override
  State<AddFavoriteSongsPage> createState() => _AddFavoriteSongsPageState();
}

class _AddFavoriteSongsPageState extends State<AddFavoriteSongsPage> {
  late Box<Song> songsBox;
  bool showRecentlyPlayed = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    songsBox = Hive.box<Song>('songsBox');
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

  Future<void> _toggleFavorite(Song song) async {
    try {
      setState(() {
        song.isFavorite = !song.isFavorite;
      });
      await widget.songService.updateFavoriteStatus(song);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            song.isFavorite ? 'Added to Favorites' : 'Removed from Favorites',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          backgroundColor: Colors.grey[700],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating favorite: $e'),
          backgroundColor: Colors.grey[700],
        ),
      );
      setState(() {
        song.isFavorite = !song.isFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: buildAppBar(
        context,
        'Add Songs to Favorites',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search songs...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: showRecentlyPlayed,
                    onChanged: (value) {
                      setState(() {
                        showRecentlyPlayed = value ?? false;
                      });
                    },
                    fillColor: MaterialStateProperty.resolveWith<Color>(
                      (states) => states.contains(MaterialState.selected)
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    checkColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  Text(
                    'Recently played',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const Spacer(),
                  ValueListenableBuilder(
                    valueListenable: songsBox.listenable(),
                    builder: (context, Box<Song> box, _) {
                      final favoriteCount = box.values.where((song) => song.isFavorite).length;
                      return Text(
                        '$favoriteCount songs in favorites',
                        style: Theme.of(context).textTheme.bodyMedium,
                      );
                    },
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
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          )
                        : ListView.builder(
                            clipBehavior: Clip.hardEdge,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: displayedSongs.length,
                            itemBuilder: (context, index) {
                              final song = displayedSongs[index];
                              final isInFavorites = song.isFavorite;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
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
                                            color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Icon(
                                            Icons.music_note,
                                            color: Theme.of(context).textTheme.bodyLarge!.color,
                                          ),
                                        ),
                                  title: Text(
                                    song.title,
                                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    song.artist,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      isInFavorites ? Icons.favorite : Icons.favorite_border,
                                      color: isInFavorites
                                          ? AppColors.red
                                          : Theme.of(context).colorScheme.primary,
                                      size: 20,
                                    ),
                                    onPressed: () => _toggleFavorite(song),
                                  ),
                                ),
                              );
                            }
                        );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
