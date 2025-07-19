import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';

class ProgressBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<double> onChanged;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;

  const ProgressBar({
    required this.position,
    required this.duration,
    required this.onChanged,
     required this.isFavorite,
    required this.onFavoritePressed,
    Key? key,
  }) : super(key: key);

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            _formatDuration(position),
            style: const TextStyle(color: AppColors.white, fontSize: 12),
          ),
          Expanded(
            child: Slider(
              value: position.inSeconds.toDouble(),
              min: 0,
              max: duration.inSeconds.toDouble() > 0
                  ? duration.inSeconds.toDouble()
                  : 1,
              onChanged: onChanged,
              activeColor: AppColors.red,
              inactiveColor: AppColors.grey,
            ),
          ),
       IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppColors.red : AppColors.white,
              size: 24,
            ),
            onPressed: onFavoritePressed,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}