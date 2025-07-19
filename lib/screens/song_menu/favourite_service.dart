import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';
import 'package:musicvoxaplay/screens/services/song_service.dart';

class FavoriteService {
  final SongService songService;

  FavoriteService(this.songService);

  Future<void> toggleFavorite(
    BuildContext context,
    Song song,
    Function(Song) updateSongCallback,
  ) async {
    try {

      final updatedSong = Song(
        song.title,
        song.artist,
        song.path,
        artwork: song.artwork,
        isFavorite: !song.isFavorite,
        playcount: song.playcount,
        playedAt: song.playedAt,
      );

      updateSongCallback(updatedSong);

      await songService.updateFavoriteStatus(updatedSong);

     
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedSong.isFavorite
                  ? 'Added "${updatedSong.title}" to Favorites' 
                  : 'Removed "${updatedSong.title}" from Favorites',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: updatedSong.isFavorite ? Colors.red[900] : Colors.grey,
          ),
        );
      }
    } catch (e) {

      updateSongCallback(song);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating favorite: $e'),
            backgroundColor: Colors.red[900],
            duration: const Duration(seconds: 3),
          ),
        );
      }
      debugPrint('Error in toggleFavorite: $e');
    }
  }
}