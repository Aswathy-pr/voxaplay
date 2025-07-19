import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';

class AlbumArtwork extends StatelessWidget {
  final Song song;

  const AlbumArtwork({required this.song, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color:AppColors.grey, width: 3),
      ),
      child: song.artwork != null
          ? Image.memory(
              song.artwork!,
              fit: BoxFit.cover,
              width: 300,
              height: 300,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.music_note,
                  size: 100,
                  color: AppColors.grey,
                );
              },
            )
          : const Icon(
              Icons.music_note,
              size: 100,
              color: AppColors.grey,
            ),
    );
  }
}