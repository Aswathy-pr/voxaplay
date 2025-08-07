import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';

class AboutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
     appBar: buildAppBar(context, 'settings', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to MusicVoxaPlay',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.red,
                fontWeight: FontWeight.bold,
                fontSize: 30
              ),
            ),
            SizedBox(height: 18),
            Text(
              'MusicVoxaPlay is a multimedia player designed to help you enjoy your local audio and video files with ease. Built with Flutter, this app allows you to fetch and play media directly from your device, offering a seamless experience with features like playlists, favorites, and search functionality.',
              style: Theme.of(context).textTheme.bodyLarge,
            
            ),
            SizedBox(height: 16),
            Text(
              'Key Features:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20
              ),
            ),
            SizedBox(height: 8),
            Text(
              '- Fetch and play audio and video files from your local storage.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              '- Create and manage custom playlists for both audio and video.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              '- Mark your favorite tracks and videos for quick access.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              '- Search your media library with ease.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 16),
            Text(
              'Version: 1.0.0\nDeveloped by: [Your Name/Company]\n© 2025 MusicVoxaPlay',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}