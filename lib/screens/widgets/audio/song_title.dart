import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';

class SongTitle extends StatelessWidget {
  final String title;
  final String artist;

  const SongTitle({required this.title, required this.artist, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8), 
        // Artist 
        Text(
          artist,
          style: const TextStyle(
            color: AppColors.grey,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}