import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';

class PrivacyPolicy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: buildAppBar(context, 'Privacy Policy', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy for MusicVoxaPlay',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Last Updated: August 06, 2025',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            Text(
              'MusicVoxaPlay ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we handle your data when you use our app to play local audio and video files.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 16),
            Text(
              '1. Information We Collect',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Our app does not collect or store any personal data from your device beyond what is necessary to function. We request the following permissions:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              '- Storage Permission: To access and play audio and video files stored on your device.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              '- Media Permissions: To manage and play multimedia content locally.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'We use Hive, a local database, to store metadata (e.g., file paths, titles) about your media files on your device only. No data is uploaded to remote servers.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 16),
            Text(
              '2. How We Use Your Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'The data collected is used solely to enable app functionality, such as creating playlists, marking favorites, and tracking recently played media. We do not share, sell, or transfer this data to third parties.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 16),
            Text(
              '3. Data Security',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'All data is stored locally on your device using Hive. We implement reasonable security measures to protect this data, but no method is 100% secure. You are responsible for managing access to your device.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 16),
            Text(
              '4. Your Choices',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You can revoke storage permissions at any time through your device settings. Deleting the app will remove all locally stored data.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 16),
            Text(
              '5. Changes to This Policy',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We may update this Privacy Policy as needed. Changes will be effective upon posting the updated policy within the app.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 16),
            Text(
              'For any questions, contact us at [your-email@example.com].',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}