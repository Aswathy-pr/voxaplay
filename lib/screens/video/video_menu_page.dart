import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/models/video_models.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';

class VideoMenuPage extends StatelessWidget {
  final Video video;

  const VideoMenuPage({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: buildAppBar(context, 'Video Options', showBackButton: true),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      // Video Thumbnail
                      video.thumbnail != null && video.thumbnail!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                video.thumbnail!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.video_library,
                                color: Theme.of(context).textTheme.bodyLarge!.color,
                                size: 30,
                              ),
                            ),
                      const SizedBox(width: 30),
                      // Video Title
                      Expanded(
                        child: Text(
                          video.title,
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Video Duration
                
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  _buildMenuItem(
                    context,
                    Icons.play_arrow,
                    'Play Video',
                    onTap: () => Navigator.pop(context, 'play'),
                  ),
                 
                  _buildMenuItem(
                    context,
                    Icons.favorite_border,
                    'Add to Favorites',
                    onTap: () => Navigator.pop(context, 'favorite'),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.playlist_add,
                    'Add to Playlist',
                    onTap: () => Navigator.pop(context, 'playlist'),
                  ),
              
               _buildMenuItem(
                    context,
                    Icons.info_outline,
                    'video info',
                    onTap: () => Navigator.pop(context, 'favorite'),
                  ),
               
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String text, {
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive 
                  ? Colors.red 
                  : Theme.of(context).textTheme.bodyLarge!.color,
              size: 30,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: 20,
                color: isDestructive ? Colors.red : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

 
}
