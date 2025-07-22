import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:musicvoxaplay/screens/models/video_models.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';

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
          });
  }

  void _playPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  void _playNext() {
    if (_currentIndex < widget.videos.length - 1) {
      setState(() {
        _currentIndex++;
        _isInitialized = false;
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
      });
      _controller.dispose();
      _initializeController();
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '${d.inHours > 0 ? '${twoDigits(d.inHours)}:' : ''}$minutes:$seconds';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: buildAppBar(context, 'Now playing' , showBackButton: true),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: _isInitialized
            ? Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.skip_previous,
                            color: Colors.white,
                            size: 40,
                          ),
                          onPressed: _playPrevious,
                        ),
                        IconButton(
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 50,
                          ),
                          onPressed: _playPause,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.skip_next,
                            color: Colors.white,
                            size: 40,
                          ),
                          onPressed: _playNext,
                        ),
                        // Icon(
                        //   Icons.favorite_border,
                        //   color: Colors.white,
                        //   size: 32,
                        // ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Row(
                      children: [
                        Text(
                          _formatDuration(_controller.value.position),
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
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
                        Text(
                          _formatDuration(_controller.value.duration),
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  // Positioned(
                  //   top: 40,
                  //   left: 10,
                  //   child: IconButton(
                  //     icon: Icon(
                  //       Icons.arrow_back,
                  //       color: Colors.white,
                  //       size: 30,
                  //     ),
                  //     onPressed: () => Navigator.pop(context),
                  //   ),
                  // ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
