import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicvoxaplay/screens/models/video_models.dart';
import 'package:musicvoxaplay/screens/video/video_fullscreen.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';
import 'package:musicvoxaplay/screens/widgets/bottom_navigationbar.dart';

class VideoFavourites extends StatefulWidget {
  const VideoFavourites({super.key});

  @override
  _VideoFavouritesState createState() => _VideoFavouritesState();
}

class _VideoFavouritesState extends State<VideoFavourites> {
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
      appBar: buildAppBar(context, 'Video Favourites', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: ValueListenableBuilder<Box<Video>>(
            valueListenable: Hive.box<Video>('videoFavoritesBox').listenable(),
            builder: (context, box, _) {
              print('VideoFavourites: Box contains ${box.length} videos');
            
              final videos = box.values.toList();

              if (videos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No favourite videos',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontSize: 20,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add videos to favourites to see them here',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.grey,
                            ),
                      ),
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
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
                        IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () async {
                            try {
                              await box.delete(video.path);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Removed ${video.title} from favourites')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error removing from favourites: $e')),
                                );
                              }
                            }
                          },
                        ),
                      ],
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