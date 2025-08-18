import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicvoxaplay/screens/models/video_models.dart';
import 'package:musicvoxaplay/screens/video/video_fullscreen.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';
import 'package:musicvoxaplay/screens/widgets/bottom_navigationbar.dart';

class VideoRecentlyPlayedPage extends StatefulWidget {
  const VideoRecentlyPlayedPage({super.key});

  @override
  _VideoRecentlyPlayedPageState createState() => _VideoRecentlyPlayedPageState();
}

class _VideoRecentlyPlayedPageState extends State<VideoRecentlyPlayedPage> {
  int _currentIndex = 2; 

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
      appBar: buildAppBar(context, 'Recently Played Videos', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: ValueListenableBuilder<Box<Video>>(
            valueListenable: Hive.box<Video>('recentlyPlayedVideos').listenable(),
            builder: (context, box, _) {
              print('VideoRecentlyPlayedPage: Box contains ${box.length} videos');
              
              // Debug: Print all videos in the box
              for (var video in box.values) {
                print('Video in box: ${video.title} - ${video.playedAt}');
              }
            
              final videosMap = <String, Video>{};
              for (var video in box.values) {
                videosMap[video.path] = video;
              }
              final videos = videosMap.values.toList()
                ..sort((a, b) => (b.playedAt ?? DateTime(0)).compareTo(a.playedAt ?? DateTime(0)));
              
              print('Sorted videos count: ${videos.length}');

              if (videos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    
                      const SizedBox(height: 16),
                      Text(
                        'No recently played videos',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontSize: 20,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start watching videos to see them here',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                      const SizedBox(height: 16),
                     
                    ],
                  ),
                );
              }

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
                    subtitle: Text(
                      video.duration != null 
                          ? '${video.duration!.inMinutes}:${(video.duration!.inSeconds % 60).toString().padLeft(2, '0')}'
                          : 'Unknown duration',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.grey[600],
                          ),
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
        ),
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