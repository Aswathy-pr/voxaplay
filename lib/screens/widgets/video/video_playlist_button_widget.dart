import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';

class VideoPlaylistButtonWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double? width;

  const VideoPlaylistButtonWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: width,
      height: 70,
      child: Card(
        color: isDarkTheme ? Colors.white : AppColors.grey.withOpacity(0.3),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isDarkTheme ? Colors.white: Theme.of(context).iconTheme.color,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: isDarkTheme
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 