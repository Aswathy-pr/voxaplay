import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/favourites/add_favourite_video.dart';
import 'package:musicvoxaplay/screens/models/video_models.dart';
import 'package:musicvoxaplay/screens/services/video_service.dart';
import 'package:musicvoxaplay/screens/video/video_fullscreen.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';
import 'package:musicvoxaplay/screens/widgets/bottom_navigationbar.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';
import 'package:musicvoxaplay/screens/menubars/video_menubar/video_menu_page.dart';


class VideoFavourites extends StatefulWidget {
  const VideoFavourites({super.key});

  @override
  _VideoFavouritesState createState() => _VideoFavouritesState();
}

class _VideoFavouritesState extends State<VideoFavourites> {
  int _currentIndex = 2;
  final VideoService _videoService = VideoService();

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
  }

  void _toggleFavorite(Video video) async {
    if (!mounted) return;

    try {
      setState(() {
      
      });
      await _videoService.updateFavoriteStatus(video);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              video.isFavorite ? 'Added to Favorites' : 'Removed from Favorites',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating favorite: $e'),
            backgroundColor: Colors.red[900],
          ),
        );
        setState(() {
        
        });
      }
      print('Error in _toggleFavorite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: buildAppBar(context, 'Video Favourites', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FutureBuilder<List<Video>>(
                  future: _videoService.getFavoriteVideos(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      print('Error in FutureBuilder: ${snapshot.error}');
                      return Center(
                        child: Text(
                          'Error loading favourites: ${snapshot.error}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 60,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Favourites list is empty',
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    fontSize: 15,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }

                    final videos = snapshot.data!;
                    return ListView.builder(
                      clipBehavior: Clip.hardEdge,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: videos.length,
                      itemBuilder: (context, index) {
                        final video = videos[index];
                        final isPlayable = video.path.isNotEmpty;

                        return ListTile(
                          leading: video.thumbnail != null && video.thumbnail!.isNotEmpty
                              ? Image.memory(
                                  video.thumbnail!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : Icon(
                                  Icons.video_library,
                                  size: 50,
                                  color: Theme.of(context).textTheme.bodyLarge!.color,
                                ),
                          title: Text(
                            video.title,
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  color: isPlayable
                                      ? Theme.of(context).textTheme.bodyLarge!.color
                                      : AppColors.grey,
                                ),
                          ),
                          subtitle: Text(
                            video.duration != null
                                ? '${video.duration!.inMinutes}:${(video.duration!.inSeconds % 60).toString().padLeft(2, '0')}'
                                : 'Unknown duration',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: isPlayable
                                      ? Theme.of(context).textTheme.bodyMedium!.color
                                      : AppColors.grey,
                                ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  video.isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: video.isFavorite
                                      ? AppColors.red
                                      : Theme.of(context).textTheme.bodyLarge!.color,
                                  size: 20.0,
                                ),
                                onPressed: () => _toggleFavorite(video),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 8.0),
                              IconButton(
                                icon: Icon(
                                  Icons.more_horiz,
                                  color: Theme.of(context).textTheme.bodyLarge!.color,
                                  size: 20.0,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VideoMenuPage(
                                        video: video,
                                        videoService: _videoService,
                                        allVideos: videos,
                                      ),
                                    ),
                                  ).then((_) {
                                    setState(() {});
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
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
                                          initialIndex: index,
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error playing video: $e'),
                                        backgroundColor: Colors.red[900],
                                      ),
                                    );
                                  }
                                }
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddFavoriteVideosPage(
                        videoService: _videoService,
                      ),
                    ),
                  );
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Add New Videos',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        context: context,
      ),
    );
  }
}