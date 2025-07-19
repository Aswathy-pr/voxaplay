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
              backgroundColor: AppColors.black,
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
                  'repeat',
                  style: TextStyle(
                    color: isRepeat ? AppColors.red : AppColors.grey,
                    fontSize: 14,
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
              backgroundColor: AppColors.black,
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
                  'shuffle',
                  style: TextStyle(
                    color: isShuffle ? AppColors.red : AppColors.grey,
                    fontSize: 14,
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