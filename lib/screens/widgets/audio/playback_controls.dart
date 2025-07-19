import 'package:flutter/material.dart';


class PlaybackControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
 
  const PlaybackControls({
    required this.isPlaying,
    required this.onPrevious,
    required this.onPlayPause,
    required this.onNext,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.skip_previous, color: Theme.of(context).textTheme.bodyLarge!.color, size: 40),
          onPressed: onPrevious,
        ),
        IconButton(
          icon: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: Theme.of(context).textTheme.bodyLarge!.color,
            size: 50,
          ),
          onPressed: onPlayPause,
        ),
        IconButton(
          icon: Icon(Icons.skip_next, color: Theme.of(context).textTheme.bodyLarge!.color, size: 40),
          onPressed: onNext,
        ),
        const SizedBox(width: 20), // Add some spacing
      ],
    );
  }
}