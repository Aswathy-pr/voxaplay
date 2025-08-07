import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:musicvoxaplay/screens/playlist/video_terms/video_playlist_detail_page.dart';

class VideoNavigationHelper {
  static void navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  static void navigateToPlaylist(
    BuildContext context,
    String playlistName,
    Box playlistVideosBox,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlaylistDetailPage(
          playlistName: playlistName,
          playlistVideosBox: playlistVideosBox,
        ),
      ),
    );
  }
}