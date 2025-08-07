import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/widgets/video/rotation.dart';
import 'package:musicvoxaplay/screens/widgets/video/fullscreen.dart';

class VideoControls extends StatelessWidget {
  final bool isPlaying;
  final bool isInitialized;
  final int currentIndex;
  final int totalVideos;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onToggleRotation;
  final VoidCallback onToggleFullscreen;

  const VideoControls({
    Key? key,
    required this.isPlaying,
    required this.isInitialized,
    required this.currentIndex,
    required this.totalVideos,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onToggleRotation,
    required this.onToggleFullscreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            VideoRotationService.isLandscape
                ? Icons.screen_rotation
                : Icons.screen_rotation_alt,
            color: Colors.white,
            size: 30,
          ),
          onPressed: onToggleRotation,
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(
            Icons.skip_previous,
            color: Colors.white,
            size: 35,
          ),
          onPressed: currentIndex > 0 ? onPrevious : null,
        ),
        const SizedBox(width: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 45,
            ),
            onPressed: isInitialized ? onPlayPause : null,
          ),
        ),
        const SizedBox(width: 20),
        IconButton(
          icon: const Icon(
            Icons.skip_next,
            color: Colors.white,
            size: 35,
          ),
          onPressed: currentIndex < totalVideos - 1 ? onNext : null,
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: Icon(
            VideoFullscreenService.isFullscreen
                ? Icons.fullscreen_exit
                : Icons.fullscreen,
            color: Colors.white,
            size: 30,
          ),
          onPressed: onToggleFullscreen,
        ),
      ],
    );
  }
}
