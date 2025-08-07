import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:musicvoxaplay/screens/models/video_models.dart';
import 'package:musicvoxaplay/screens/services/video_service/video_service.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';
import 'package:musicvoxaplay/screens/widgets/video/rotation.dart';
import 'package:musicvoxaplay/screens/widgets/video/fullscreen.dart';
import 'package:musicvoxaplay/screens/widgets/video/video_controllers.dart';
import 'package:musicvoxaplay/screens/widgets/video/video_progress_row.dart';

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
          ..initialize()
              .then((_) {
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
              })
              .catchError((error) {
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
      appBar: VideoFullscreenService.isFullscreen
          ? null
          : buildAppBar(context, 'Video', showBackButton: true),
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
                   
                    VideoProgressRow(
                      controller: _controller,
                      formatDuration: _formatDuration,
                    ),

                    const SizedBox(height: 1),

                    VideoControls(
                      isPlaying: _isPlaying,
                      isInitialized: _isInitialized,
                      currentIndex: _currentIndex,
                      totalVideos: widget.videos.length,
                      onPlayPause: _togglePlayPause,
                      onNext: _playNext,
                      onPrevious: _playPrevious,
                      onToggleRotation: _toggleRotation,
                      onToggleFullscreen: _toggleFullscreen,
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
           
              _isInitialized
                  ? VideoProgressRow(
                      controller: _controller,
                      formatDuration: _formatDuration,
                    )
                  : const SizedBox.shrink(),

              const SizedBox(height: 1),

              VideoControls(
                isPlaying: _isPlaying,
                isInitialized: _isInitialized,
                currentIndex: _currentIndex,
                totalVideos: widget.videos.length,
                onPlayPause: _togglePlayPause,
                onNext: _playNext,
                onPrevious: _playPrevious,
                onToggleRotation: _toggleRotation,
                onToggleFullscreen: _toggleFullscreen,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
