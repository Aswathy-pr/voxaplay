import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';
import 'package:musicvoxaplay/screens/models/video_models.dart';
import 'package:musicvoxaplay/screens/services/video_service.dart';
import 'package:musicvoxaplay/screens/widgets/video/video_list_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:musicvoxaplay/screens/widgets/bottom_navigationbar.dart';
import 'package:musicvoxaplay/screens/video/video_fullscreen.dart';
import 'package:musicvoxaplay/screens/video/video_menu_page.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({Key? key}) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  Future<List<Video>>? _videosFuture;
  final VideoService _videoService = VideoService();
  bool _isLoading = true;
  int _currentIndex = 1;

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadVideosFromCacheOrFetch();
  }

  Future<void> _loadVideosFromCacheOrFetch() async {
    setState(() {
      _isLoading = true;
    });
    try {
    
      List<Video> cachedVideos = _videoService.getAllVideos();
      if (cachedVideos.isNotEmpty) {
        setState(() {
          _videosFuture = Future.value(cachedVideos);
          _isLoading = false;
        });
      } else {
      
        final videos = await _videoService.fetchVideos();
        setState(() {
          _videosFuture = Future.value(videos);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _videosFuture = Future.value(<Video>[]);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading videos: $e')),
        );
      }
    }
  }

  Future<void> _refreshVideos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final videos = await _videoService.fetchVideos();
      setState(() {
        _videosFuture = Future.value(videos);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _videosFuture = Future.value(<Video>[]);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing videos: $e')),
        );
      }
    }
  }

  Future<void> _playVideo(Video video, List<Video> videos) async {
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error playing video: $e')));
      }
    }
  }

  Future<void> _navigateToVideoMenu(Video video) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoMenuPage(video: video),
      ),
    );
    
    if (result != null && mounted) {
      switch (result) {
        case 'play':
          _playVideo(video, [video]);
          break;
        case 'favorite':
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added ${video.title} to favorites')),
          );
          break;
        case 'playlist':
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Add to playlist functionality coming soon')),
          );
          break;
        case 'share':
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Share functionality coming soon')),
          );
          break;
        case 'info':
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Video info: ${video.title}')),
          );
          break;
        case 'delete':
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Delete functionality coming soon')),
          );
          break;
      }
    }
  }

  Widget _buildNoVideosFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.video_library_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          Text(
            'No videos found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(
            'No videos were found on your device.\nTry selecting videos manually.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });

              try {
                final videos = await _videoService.fetchVideosWithPicker();
                setState(() {
                  _videosFuture = Future.value(videos);
                  _isLoading = false;
                });
              } catch (e) {
                setState(() {
                  _isLoading = false;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error selecting videos: $e')),
                  );
                }
              }
            },
            icon: const Icon(Icons.folder_open),
            label: const Text('Select Videos Manually'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: buildAppBar(context, 'All videos' , showBackButton: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: _isLoading || _videosFuture == null
                    ? const Center(child: CircularProgressIndicator())
                    : FutureBuilder<List<Video>>(
                        future: _videosFuture!,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 80,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Error loading videos',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: _refreshVideos,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            );
                          }
                          final videos = snapshot.data ?? [];
                          if (videos.isEmpty) {
                            return _buildNoVideosFound();
                          }
                          return VideoListWidget(
                            videosFuture: _videosFuture!,
                            currentVideo:
                                null,
                            onVideoTap: _playVideo,
                            onMenuTap: _navigateToVideoMenu,
                            onRetry: () async {
                              await Permission.storage.request();
                              _refreshVideos();
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        context: context,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
