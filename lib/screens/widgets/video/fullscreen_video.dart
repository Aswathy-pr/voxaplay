import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoFullscreenWidget extends StatefulWidget {
  final VideoPlayerController controller;
  final bool isInitialized;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final String currentTime;
  final String totalTime;
  final bool isPlaying;

  const VideoFullscreenWidget({
    Key? key,
    required this.controller,
    required this.isInitialized,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.currentTime,
    required this.totalTime,
    required this.isPlaying,
  }) : super(key: key);

  @override
  State<VideoFullscreenWidget> createState() => _VideoFullscreenWidgetState();
}

class _VideoFullscreenWidgetState extends State<VideoFullscreenWidget> {
  bool _isFullscreen = false;
  // bool _isLandscape = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _setupOrientation();
  }

  void _setupOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      // Enter fullscreen mode
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      // Exit fullscreen mode
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  
  

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  void dispose() {
    // Reset orientation when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video Player
          AspectRatio(
            aspectRatio: widget.controller.value.aspectRatio,
            child: VideoPlayer(widget.controller),
          ),
          
          // Controls overlay
          if (_showControls) ...[
            // Top-left crop/focus indicator
            Positioned(
              top: 20,
              left: 20,
              child: Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.crop_free,
                      color: Colors.black,
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 2,
                    height: 40,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
            
            // Center-right rotation controls
            Positioned(
              right: 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Top triangle with line
                    Column(
                      children: [
                        Container(
                          width: 0,
                          height: 0,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.black, width: 8),
                              left: BorderSide(color: Colors.transparent, width: 6),
                              right: BorderSide(color: Colors.transparent, width: 6),
                            ),
                          ),
                        ),
                        Container(
                          width: 12,
                          height: 2,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Middle double lines
                    Column(
                      children: [
                        Container(
                          width: 12,
                          height: 2,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: 12,
                          height: 2,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Bottom triangle with line
                    Column(
                      children: [
                        Container(
                          width: 12,
                          height: 2,
                          color: Colors.black,
                        ),
                        Container(
                          width: 0,
                          height: 0,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.black, width: 8),
                              left: BorderSide(color: Colors.transparent, width: 6),
                              right: BorderSide(color: Colors.transparent, width: 6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom-left timestamp
            Positioned(
              bottom: 20,
              left: 20,
              child: RotatedBox(
                quarterTurns: 1,
                child: Text(
                  widget.currentTime,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ),
            ),
            
            // Top-right fullscreen button
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: Icon(
                  _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: _toggleFullscreen,
              ),
            ),
            
            // Bottom playback controls
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Playback controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.skip_previous,
                          color: Colors.white,
                          size: 40,
                        ),
                        onPressed: widget.onPrevious,
                      ),
                      IconButton(
                        icon: Icon(
                          widget.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 50,
                        ),
                        onPressed: widget.onPlayPause,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.skip_next,
                          color: Colors.white,
                          size: 40,
                        ),
                        onPressed: widget.onNext,
                      ),
                    ],
                  ),
                  
                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(
                          widget.currentTime,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        Expanded(
                          child: VideoProgressIndicator(
                            widget.controller,
                            allowScrubbing: true,
                            colors: VideoProgressColors(
                              playedColor: Colors.red,
                              backgroundColor: Colors.white24,
                              bufferedColor: Colors.white54,
                            ),
                          ),
                        ),
                        Text(
                          widget.totalTime,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
} 