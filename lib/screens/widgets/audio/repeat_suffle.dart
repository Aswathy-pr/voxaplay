import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';

class PlaybackOptions extends StatelessWidget {
  final bool isRepeat;
  final bool isShuffle;
  final VoidCallback onRepeat;
  final VoidCallback onShuffle;

  const PlaybackOptions({
    required this.isRepeat,
    required this.isShuffle,
    required this.onRepeat,
    required this.onShuffle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 35),
          child: OutlinedButton(
            onPressed: onRepeat,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: isRepeat ? AppColors.red: AppColors.grey,
                width: 2,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              backgroundColor: Colors.grey[500],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.repeat,
                  color: isRepeat ? AppColors.red : AppColors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Repeat',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Shuffle Button
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 35),
          child: OutlinedButton(
            onPressed: onShuffle,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: isShuffle ? AppColors.red: AppColors.grey,
                width: 2,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              backgroundColor: AppColors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shuffle,
                  color: isShuffle ? AppColors.red : AppColors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Shuffle',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}