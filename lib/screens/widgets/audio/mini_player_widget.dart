import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';

class MiniPlayerWidget extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onTogglePlay;
  final VoidCallback onClose;
  final VoidCallback onTap;

  const MiniPlayerWidget({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.onTogglePlay,
    required this.onClose,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        color: AppColors.darkGrey,
        child: ListTile(
          leading: song.artwork != null
              ? Image.memory(song.artwork!, width: 50, height: 50, fit: BoxFit.cover)
              : const Icon(Icons.music_note, size: 40, color: AppColors.white),
          title: Text(
            song.title,
            style: Theme.of(context).textTheme.bodyLarge,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            song.artist,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: AppColors.white),
                onPressed: onTogglePlay,
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.white),
                onPressed: onClose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}