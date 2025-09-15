import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/models/video_models.dart';
import 'package:musicvoxaplay/screens/services/video_service.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';

class VideoFavoriteService {
  final VideoService videoService;

  VideoFavoriteService(this.videoService);

  Future<void> toggleFavorite(
    BuildContext context,
    Video video,
    Function(Video) updateVideoCallback,
  ) async {
    if (video == null || video.path == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid video data.'),
            backgroundColor: AppColors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    try {
      final updatedVideo = Video(
        title: video.title ?? 'Unknown',
        path: video.path,
        thumbnail: video.thumbnail,
        duration: video.duration,
        isFavorite: !video.isFavorite,
        playcount: video.playcount,
        playedAt: video.playedAt,
      );

      updateVideoCallback(updatedVideo);
      await videoService.updateFavoriteStatus(updatedVideo);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedVideo.isFavorite
                  ? 'Added "${updatedVideo.title}" to Favorites'
                  : 'Removed "${updatedVideo.title}" from Favorites',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: updatedVideo.isFavorite ? AppColors.red : Colors.grey,
          ),
        );
      }
    } catch (e) {
      updateVideoCallback(video); 
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating favorite: $e'),
            backgroundColor: AppColors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      debugPrint('Error in toggleFavorite: $e');
    }
  }
}