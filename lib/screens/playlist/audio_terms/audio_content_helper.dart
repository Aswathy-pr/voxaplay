import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';
import 'package:musicvoxaplay/screens/playlist/audio_terms/navigation_helper.dart';
import 'package:musicvoxaplay/screens/playlist/audio_terms/playlist_creation_helper.dart';
import 'package:musicvoxaplay/screens/playlist/audio_terms/playlist_delete_helper.dart';
import 'package:musicvoxaplay/screens/playlist/audio_terms/playlist_migration_helper.dart';
import 'package:musicvoxaplay/screens/playlist/audio_terms/playlist_rename_helper.dart';

class AudioContentHelper {
  static Future<void> migrateOldPlaylistFormat(Box playlistSongsBox) async {
    await PlaylistMigrationHelper.migrateOldPlaylistFormat(playlistSongsBox);
  }

  static void navigateTo(BuildContext context, Widget page) {
    NavigationHelper.navigateTo(context, page);
  }

  static void navigateToPlaylist(
    BuildContext context,
    String playlistName,
    Box playlistSongsBox,
  ) {
    NavigationHelper.navigateToPlaylist(context, playlistName, playlistSongsBox);
  }

  static Future<void> handleCreatePlaylist(
    BuildContext context,
    Box playlistsBox,
    Box playlistSongsBox,
    Song? currentSong,
  ) async {
    await PlaylistCreationHelper.handleCreatePlaylist(context, playlistsBox, playlistSongsBox, currentSong);
  }

  static Future<void> handleRenamePlaylist(
    BuildContext context,
    Box playlistsBox,
    Box playlistSongsBox, {
    required VoidCallback onRefresh,
  }) async {
    await PlaylistRenameHelper.handleRenamePlaylist(context, playlistsBox, playlistSongsBox, onRefresh: onRefresh);
  }

  static Future<void> handleDeletePlaylist(
    BuildContext context,
    Box playlistsBox,
    Box playlistSongsBox, {
    required VoidCallback onRefresh,
  }) async {
    await PlaylistDeleteHelper.handleDeletePlaylist(context, playlistsBox, playlistSongsBox, onRefresh: onRefresh);
  }
}