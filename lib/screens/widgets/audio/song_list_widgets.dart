import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';


class SongListWidget extends StatelessWidget {
  final Future<List<Song>> songsFuture;
  final Song? currentSong;
  final Function(Song, List<Song>) onSongTap;
  final Function(Song) onMenuTap;
  final Future<void> Function() onRetry;

  const SongListWidget({
    super.key,
    required this.songsFuture,
    required this.currentSong,
    required this.onSongTap,
    required this.onMenuTap,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Song>>(
      future: songsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading songs',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No valid songs found',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
              ],
            ),
          );
        }

        final songs = snapshot.data!;
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            final isPlayable = song.path.isNotEmpty;
            final isCurrentSong = currentSong?.path == song.path;

            return Container(
              color: isCurrentSong ? AppColors.red.withOpacity(0.3) : Colors.transparent,
              child: ListTile(
                leading: song.artwork != null
                    ? Image.memory(
                        song.artwork!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.music_note,
                        size: 50,
                        color: AppColors.grey,
                      ),
                title: Text(
                  song.title,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: isPlayable ? Theme.of(context).textTheme.bodyLarge!.color : AppColors.grey,
                      ),
                ),
                subtitle: Text(
                  song.artist,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: isPlayable ? Theme.of(context).textTheme.bodyMedium!.color : AppColors.grey,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.more_horiz,
                        color: AppColors.grey,
                      ),
                      onPressed: () => onMenuTap(song),
                    ),
                  ],
                ),
                onTap: isPlayable ? () => onSongTap(song, songs) : null,
              ),
            );
          },
        );
      },
    );
  }
}