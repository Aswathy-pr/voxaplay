import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/models/video_models.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';
import 'package:musicvoxaplay/screens/widgets/video/thumbnail.dart';

class VideoListWidget extends StatelessWidget {
  final Future<List<Video>> videosFuture;
  final Video? currentVideo;
  final Function(Video, List<Video>) onVideoTap;
  final Function(Video) onMenuTap;
  final Future<void> Function() onRetry;

  const VideoListWidget({
    super.key,
    required this.videosFuture,
    required this.currentVideo,
    required this.onVideoTap,
    required this.onMenuTap,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Video>>(
      future: videosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading videos',
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
                  'No videos found',
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

        final videos = snapshot.data!;
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            final isPlayable = video.path.isNotEmpty;
            final isCurrentVideo = currentVideo?.path == video.path;

            return Container(
              color: isCurrentVideo ? AppColors.red.withOpacity(0.3) : Colors.transparent,
              child: ListTile(
                leading: Thumbnail(
                  thumbnail: video.thumbnail,
                  size: 50,
                ),
                title: Text(
                  video.title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                subtitle: Text(
                  video.duration != null ? _formatDuration(video.duration!) : 'Unknown duration',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.more_horiz,
                        color: AppColors.grey,
                      ),
                      onPressed: () => onMenuTap(video),
                    ),
                  ],
                ),
                onTap: isPlayable ? () => onVideoTap(video, videos) : null,
              ),
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }
} 