import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:musicvoxaplay/screens/models/video_models.dart';
import 'package:musicvoxaplay/screens/services/video_service.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';
import 'package:musicvoxaplay/screens/widgets/video/rotation.dart';
import 'package:musicvoxaplay/screens/widgets/video/fullscreen.dart';

class VideoFullScreen extends StatefulWidget {
  final List<Video> videos;
  final int initialIndex;

  const VideoFullScreen({
    Key? key,
    required this.videos,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<VideoFullScreen> createState() => _VideoFullScreenState();
}

class _VideoFullScreenState extends State<VideoFullScreen> {
  late int _currentIndex;
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _hasUpdatedRecentlyPlayed = false;
  final VideoService _videoService = VideoService();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initializeController();
  }

  void _initializeController() {
    _controller =
        VideoPlayerController.file(File(widget.videos[_currentIndex].path))
          ..initialize().then((_) {
            setState(() {
              _isInitialized = true;
            });
            _controller.play();
            _updatePlayingState();
            // Update recently played when video starts
            if (!_hasUpdatedRecentlyPlayed) {
              _updateRecentlyPlayed(widget.videos[_currentIndex]);
              _hasUpdatedRecentlyPlayed = true;
            }
          }).catchError((error) {
            print('Error initializing video controller: $error');
          });
  }

  void _updatePlayingState() {
    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _isPlaying = _controller.value.isPlaying;
        });
      }
    });
  }

  Future<void> _updateRecentlyPlayed(Video video) async {
    try {
      await _videoService.incrementPlayCount(video);
      print('Updated recently played for video: ${video.title}');
    } catch (e) {
      print('Error updating recently played: $e');
    }
  }

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
      _isPlaying = _controller.value.isPlaying;
    });
  }

  void _playNext() {
    if (_currentIndex < widget.videos.length - 1) {
      setState(() {
        _currentIndex++;
        _isInitialized = false;
        _hasUpdatedRecentlyPlayed = false;
      });
      _controller.dispose();
      _initializeController();
    }
  }

  void _playPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isInitialized = false;
        _hasUpdatedRecentlyPlayed = false;
      });
      _controller.dispose();
      _initializeController();
    }
  }

  void _toggleRotation() {
    setState(() {
      VideoRotationService.toggleRotation();
    });
  }

  void _toggleFullscreen() {
    setState(() {
      VideoFullscreenService.toggleFullscreen();
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    // Reset orientation when leaving
    VideoRotationService.resetToPortrait();
    VideoFullscreenService.resetToNormal();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: VideoFullscreenService.isFullscreen ? null : buildAppBar(context, 'Video', showBackButton: true),
      body: VideoFullscreenService.isFullscreen 
          ? _buildFullscreenView()
          : _buildNormalView(),
    );
  }

  Widget _buildFullscreenView() {
    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        children: [
          // Fullscreen video
          _isInitialized
              ? VideoPlayer(_controller)
              : const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
          
          // Fullscreen controls overlay
          if (_showControls && _isInitialized)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress bar with time display
                    Row(
                      children: [
                        Text(
                          _formatDuration(_controller.value.position),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: VideoProgressIndicator(
                            _controller,
                            allowScrubbing: true,
                            colors: VideoProgressColors(
                              playedColor: Colors.red,
                              backgroundColor: Colors.white24,
                              bufferedColor: Colors.white54,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          _formatDuration(_controller.value.duration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    // Playback controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            VideoRotationService.isLandscape ? Icons.screen_rotation : Icons.screen_rotation_alt,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: _toggleRotation,
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: Icon(
                            Icons.skip_previous,
                            color: Colors.white,
                            size: 35,
                          ),
                          onPressed: _currentIndex > 0 ? _playPrevious : null,
                        ),
                        const SizedBox(width: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 45,
                            ),
                            onPressed: _isInitialized ? _togglePlayPause : null,
                          ),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          icon: Icon(
                            Icons.skip_next,
                            color: Colors.white,
                            size: 35,
                          ),
                          onPressed: _currentIndex < widget.videos.length - 1 ? _playNext : null,
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: Icon(
                            Icons.fullscreen_exit,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: _toggleFullscreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNormalView() {
    return Column(
      children: [
        // Video Player Section
        Expanded(
          child: GestureDetector(
            onTap: _toggleControls,
            child: _isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
          ),
        ),
        
        // Fixed Controls Section (always visible)
        Container(
          color: Colors.black,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress bar with time display on sides
              Row(
                children: [
                  // Current time (left side)
                  Text(
                    _isInitialized ? _formatDuration(_controller.value.position) : '00:00',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  
                  const SizedBox(width: 5),
                  
                  // Progress bar (center)
                  Expanded(
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: Colors.red,
                        backgroundColor: Colors.white24,
                        bufferedColor: Colors.white54,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 14),
                  
                  // Total duration (right side)
                  Text(
                    _isInitialized ? _formatDuration(_controller.value.duration) : '00:00',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 1),
              
              // Playback controls (rotation, previous, play/pause, next, fullscreen)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Rotation button
                  IconButton(
                    icon: Icon(
                      VideoRotationService.isLandscape ? Icons.screen_rotation : Icons.screen_rotation_alt,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: _toggleRotation,
                  ),
                  
                  const SizedBox(width: 10),
                  
                  // Previous button
                  IconButton(
                    icon: Icon(
                      Icons.skip_previous,
                      color: Colors.white,
                      size: 35,
                    ),
                    onPressed: _currentIndex > 0 ? _playPrevious : null,
                  ),
                  
                  const SizedBox(width: 20),
                  
                  // Play/Pause button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 45,
                      ),
                      onPressed: _isInitialized ? _togglePlayPause : null,
                    ),
                  ),
                  
                  const SizedBox(width: 20),
                  
                  // Next button
                  IconButton(
                    icon: Icon(
                      Icons.skip_next,
                      color: Colors.white,
                      size: 35,
                    ),
                    onPressed: _currentIndex < widget.videos.length - 1 ? _playNext : null,
                  ),
                  
                  const SizedBox(width: 10),
                  
                  // Fullscreen button
                  IconButton(
                    icon: Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: _toggleFullscreen,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
