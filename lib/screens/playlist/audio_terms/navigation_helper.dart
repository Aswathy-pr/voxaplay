import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/playlist/audio_terms/playlist_detail_page.dart';
import 'package:hive/hive.dart';

class NavigationHelper {
  static void navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  static void navigateToPlaylist(
    BuildContext context,
    String playlistName,
    Box playlistSongsBox,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistDetailPage(
          playlistName: playlistName,
          playlistSongsBox: playlistSongsBox,
        ),
      ),
    );
  }
}