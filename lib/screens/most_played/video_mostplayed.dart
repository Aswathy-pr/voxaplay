import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/models/video_models.dart';
import 'package:musicvoxaplay/screens/services/video_service.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';
import 'package:musicvoxaplay/screens/widgets/bottom_navigationbar.dart';
import 'package:musicvoxaplay/screens/video/video_fullscreen.dart';

class VideoMostPlayed extends StatefulWidget {
  const VideoMostPlayed({super.key});

  @override
  State<VideoMostPlayed> createState() => _VideoMostPlayedState();
}

class _VideoMostPlayedState extends State<VideoMostPlayed> {
  int _currentIndex = 2; 
  final VideoService _videoService = VideoService();

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: buildAppBar(context, 'Most Played Videos', showBackButton: true),
      body: FutureBuilder<List<Video>>(
        future: _videoService.getMostPlayedVideos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading most played videos',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 20,
                    ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No videos played yet',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 20,
                    ),
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

              return ListTile(
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[300],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: video.thumbnail != null
                        ? Image.memory(
                            video.thumbnail!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.video_library,
                                color: Colors.grey,
                              );
                            },
                          )
                        : const Icon(
                            Icons.video_library,
                            color: Colors.grey,
                          ),
                  ),
                ),
                title: Text(
                  video.title,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.duration != null 
                          ? '${video.duration!.inMinutes}:${(video.duration!.inSeconds % 60).toString().padLeft(2, '0')}'
                          : 'Unknown duration',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    Text(
                      'Played ${video.playcount} times',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: isPlayable
                      ? () async {
                          try {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoFullScreen(
                                  videos: videos,
                                  initialIndex: videos.indexOf(video),
                                ),
                              ),
                            );
                            setState(() {});
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error playing video: $e')),
                              );
                            }
                          }
                        }
                      : null,
                ),
                onTap: isPlayable
                    ? () async {
                        try {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoFullScreen(
                                videos: videos,
                                initialIndex: videos.indexOf(video),
                              ),
                            ),
                          );
                          setState(() {});
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error playing video: $e')),
                            );
                          }
                        }
                      }
                    : null,
              );
            },
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return buildBottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      context: context,
    );
  }
} 