

import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';

class SongService {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  late Box<Song> _songsBox;
  late Box<Song> _recentlyPlayedBox;
  late Box<Song> _mostPlayedBox;

  SongService() {
    _songsBox = Hive.box<Song>('songsBox');
    _recentlyPlayedBox = Hive.box<Song>('recentlyPlayed');
    _mostPlayedBox = Hive.box<Song>('mostPlayed');
    print(
      'SongService initialized: recentlyPlayed contains ${_recentlyPlayedBox.length} songs',
    );
  }

  Future<List<Song>> fetchSongsFromDevice() async {
    try {
      await _songsBox.clear();
      print('Cleared songsBox to prevent duplicates');

      PermissionStatus permissionStatus = await Permission.audio.status;
      if (!permissionStatus.isGranted) {
        permissionStatus = await Permission.audio.request();
        if (!permissionStatus.isGranted) {
          print('Audio permission denied');
          return [];
        }
      }

      List<SongModel> deviceSongs = await _audioQuery.querySongs();
      print('Queried ${deviceSongs.length} songs from device');
      if (deviceSongs.isEmpty) {
        print('No songs found on device');
        return [];
      }

      final Map<String, Song> uniqueSongs = {};
      for (var deviceSong in deviceSongs) {
        String path = deviceSong.data; 
        if (path.isEmpty) {
          print('Skipping song "${deviceSong.title}" due to empty path');
          continue;
        }

        if (uniqueSongs.containsKey(path)) {
          print(
            'Skipping duplicate song "${deviceSong.title}" with path "$path"',
          );
          continue;
        }

        Uint8List? artwork = await _audioQuery.queryArtwork(
          deviceSong.id,
          ArtworkType.AUDIO,
          size: 200,
        );
        Song song = Song(
          deviceSong.title,
          deviceSong.artist ?? 'Unknown Artist',
          path,
          artwork: artwork,
          isFavorite: false,
          playcount: 0,
          playedAt: null,
        );

        final recentlyPlayedSong = _recentlyPlayedBox.values.firstWhere(
          (s) => s.path == path,
          orElse: () => song,
        );
        final mostPlayedSong = _mostPlayedBox.values.firstWhere(
          (s) => s.path == path,
          orElse: () => song,
        );
        song = Song(
          song.title,
          song.artist,
          song.path,
          artwork: song.artwork,
          isFavorite:
              recentlyPlayedSong.isFavorite || mostPlayedSong.isFavorite,
          playcount: mostPlayedSong.playcount,
          playedAt: recentlyPlayedSong.playedAt,
        );

        uniqueSongs[path] = song;
      }

      await _songsBox.putAll({
        for (var song in uniqueSongs.values) song.path: song,
      });
      final songs = uniqueSongs.values.toList();
      print('Fetched ${songs.length} unique songs');
      return songs;
    } catch (e) {
      print('Error fetching songs: $e');
      return [];
    }
  }

  Future<void> updateFavoriteStatus(Song song) async {
    try {
      final songIndex = _songsBox.values.toList().indexWhere(
        (s) => s.path == song.path,
      );
      if (songIndex != -1) await _songsBox.putAt(songIndex, song);

      final recentlyPlayedIndex = _recentlyPlayedBox.values.toList().indexWhere(
        (s) => s.path == song.path,
      );
      if (recentlyPlayedIndex != -1)
        await _recentlyPlayedBox.putAt(recentlyPlayedIndex, song);

      final mostPlayedIndex = _mostPlayedBox.values.toList().indexWhere(
        (s) => s.path == song.path,
      );
      if (mostPlayedIndex != -1)
        await _mostPlayedBox.putAt(mostPlayedIndex, song);

      await _recentlyPlayedBox.compact();
      await _mostPlayedBox.compact();
      print(
        'Updated favorite status for "${song.title}" to ${song.isFavorite}, recentlyPlayed: ${_recentlyPlayedBox.length} songs',
      );
    } catch (e) {
      print('Error updating favorite status: $e');
    }
  }

  Future<List<Song>> getFavoriteSongs() async {
    try {
      final favoriteSongs = _songsBox.values
          .where((song) => song.isFavorite)
          .toList();
      print('Fetched ${favoriteSongs.length} favorite songs');
      return favoriteSongs;
    } catch (e) {
      print('Error fetching favorite songs: $e');
      return [];
    }
  }

  Future<void> incrementPlayCount(Song song) async {
    try {
      final songIndex = _songsBox.values.toList().indexWhere(
        (s) => s.path == song.path,
      );
      if (songIndex != -1) {
        final updatedSong = Song(
          song.title,
          song.artist,
          song.path,
          artwork: song.artwork,
          playedAt: DateTime.now(),
          isFavorite: song.isFavorite,
          playcount: song.playcount + 1,
        );
        await _songsBox.putAt(songIndex, updatedSong);
        final mostPlayedIndex = _mostPlayedBox.values.toList().indexWhere(
          (s) => s.path == song.path,
        );
        if (mostPlayedIndex != -1) {
          await _mostPlayedBox.putAt(mostPlayedIndex, updatedSong);
        } else {
          await _mostPlayedBox.add(updatedSong);
        }
        await _mostPlayedBox.compact();
        print(
          'Incremented play count for "${song.title}" to ${updatedSong.playcount}, mostPlayed: ${_mostPlayedBox.length} songs',
        );
      } else {
        print('Song "${song.title}" not found in songsBox');
      }
    } catch (e) {
      print('Error incrementing play count: $e');
    }
  }

  Future<void> addToRecentlyPlayed(Song song) async {
    try {
      final updatedSong = Song(
        song.title,
        song.artist,
        song.path,
        artwork: song.artwork,
        playedAt: DateTime.now(),
        isFavorite: song.isFavorite,
        playcount: song.playcount,
      );

      // Load existing songs into a map to ensure uniqueness by path
      final songsMap = <String, Song>{};
      for (var s in _recentlyPlayedBox.values) {
        songsMap[s.path] = s;
      }

      // Add or update the song
      songsMap[song.path] = updatedSong;

      // Convert to list, sort by playedAt (newest first), and limit to 10
      final songs = songsMap.values.toList()
        ..sort((a, b) => (b.playedAt ?? DateTime(0)).compareTo(a.playedAt ?? DateTime(0)));
      final limitedSongs = songs.length > 10 ? songs.sublist(0, 10) : songs;

      // Clear and repopulate the box
      await _recentlyPlayedBox.clear();
      for (var s in limitedSongs) {
        await _recentlyPlayedBox.add(s);
      }

      await _recentlyPlayedBox.compact();
      print('Updated recentlyPlayed box with "${song.title}", size: ${_recentlyPlayedBox.length} songs');
    } catch (e) {
      print('Error adding to recently played: $e');
    }
  }

  Future<List<Song>> getMostPlayedSongs({int limit = 10}) async {
    try {
      final mostPlayedSongs =
          _mostPlayedBox.values
              .toList()
              .where((song) => song.playcount > 0)
              .toList()
            ..sort((a, b) => b.playcount.compareTo(a.playcount));
      print(
        'Fetched ${mostPlayedSongs.length} most played songs from mostPlayed box',
      );
      return mostPlayedSongs.take(limit).toList();
    } catch (e) {
      print('Error fetching most played songs: $e');
      return [];
    }
  }
}