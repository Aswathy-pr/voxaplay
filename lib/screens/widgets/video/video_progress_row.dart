import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoProgressRow extends StatelessWidget {
  final VideoPlayerController controller;
  final String Function(Duration) formatDuration;

  const VideoProgressRow({
    Key? key,
    required this.controller,
    required this.formatDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          formatDuration(controller.value.position),
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: VideoProgressIndicator(
            controller,
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
          formatDuration(controller.value.duration),
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ],
    );
  }
}
