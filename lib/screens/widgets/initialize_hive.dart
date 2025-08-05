// import 'dart:developer';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:musicvoxaplay/screens/models/song_models.dart';
// import 'package:musicvoxaplay/screens/models/video_models.dart';

// Future<void> initializeHive() async {
//   try {
//     await Hive.initFlutter();
//     Hive.registerAdapter(SongAdapter());
//     Hive.registerAdapter(VideoAdapter());
//     await Hive.openBox<Song>('songsBox');
//     await Hive.openBox<Song>('recentlyPlayed');
//     await Hive.openBox<Song>('mostPlayed');
//     await Hive.openBox('playlistsBox');
//     await Hive.openBox('playlistSongsBox');
//     await Hive.openBox<Video>('videoBox');
//     await Hive.openBox<Video>('mostPlayedVideos');
//     await Hive.openBox<Video>('recentlyPlayedVideos');
//     await Hive.openBox<Video>('videoFavoritesBox');
//     await Hive.openBox('videoPlaylistsBox');
//     await Hive.openBox('videoPlaylistVideosBox');

//     final playlistsBox = Hive.box('playlistsBox');

//     if (playlistsBox.isEmpty) {
//       await playlistsBox.put('playlistsBox', []);
//       log('Initialized playlistsBox with empty playlists list.');
//     }

//     final playlistSongsBox = Hive.box('playlistSongsBox');

//     if (playlistSongsBox.isEmpty) {
//       await playlistSongsBox.put('playlistSongsBox', {});
//       log('Initialized playlistSongsBox with empty map.');
//     }

//     final videoBox = Hive.box<Video>('videoBox');
//     if (videoBox.isEmpty) {
//       log('initialized video with ${videoBox.length} videos.');
//     }

//     final videoPlaylistsBox = Hive.box('videoPlaylistsBox');
//     if (videoPlaylistsBox.isEmpty) {
//       await videoPlaylistsBox.put('playlists', []);
//       log('Initialized videoPlaylistsBox with empty playlists list.');
//     }

//     final videoPlaylistVideosBox = Hive.box('videoPlaylistVideosBox');
//     if (videoPlaylistVideosBox.isEmpty) {
//       await videoPlaylistVideosBox.put('playlistVideosBox', {});
//       log('Initialized videoPlaylistVideosBox with empty map.');
//     }

//     // Migrate any invalid data during initialization
//     final keys = playlistSongsBox.keys.toList();
//     for (var key in keys) {
//       final data = playlistSongsBox.get(key);
//       if (data is Map && !data.containsKey('songs')) {
//         final songs = data[key] is List<String>
//             ? List<String>.from(data[key] as List<String>)
//             : [];
//         await playlistSongsBox.put(key.toString(), {
//           'songs': songs,
//           'createdAt': DateTime.now().toString(),
//           'updatedAt': DateTime.now().toString(),
//         });
//       } else if (data is! Map) {
//         await playlistSongsBox.put(key.toString(), {
//           'songs': [],
//           'createdAt': DateTime.now().toString(),
//           'updatedAt': DateTime.now().toString(),
//         });
//       }
//     }

//     log('Hive initialized.');
//     log('songsBox opened with ${Hive.box<Song>('songsBox').length} songs.');
//     log(
//       'recentlyPlayed box opened with ${Hive.box<Song>('recentlyPlayed').length} songs.',
//     );
//     log(
//       'mostPlayed box opened with ${Hive.box<Song>('mostPlayed').length} songs.',
//     );
//     log('playlistsBox opened with ${playlistsBox.length} entries.');
//     log('playlistSongsBox opened with ${playlistSongsBox.length} entries.');
//     log('videoBox opened with ${videoBox.length} videos.');
//   } catch (e) {
//     log('Error initializing Hive: $e');
//     rethrow;
//   }
// }

// Future<void> clearHiveData() async {
//   await Hive.box<Song>('songsBox').clear();

//   await Hive.box<Song>('recentlyPlayed').clear();

//   await Hive.box<Song>('mostPlayed').clear();

//   await Hive.box('playlistsBox').clear();

//   await Hive.box('playlistSongsBox').clear();

//   await Hive.box<Video>('videoBox').clear();
//   await Hive.box<Video>('mostPlayedVideos').clear();
//   await Hive.box<Video>('recentlyPlayedVideos').clear();
//   await Hive.box<Video>('videoFavoritesBox').clear();
//   await Hive.box('videoPlaylistsBox').clear();
//   await Hive.box('videoPlaylistVideosBox').clear();
// }



import 'dart:developer';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';
import 'package:musicvoxaplay/screens/models/video_models.dart';

Future<void> initializeHive() async {
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(SongAdapter());
    Hive.registerAdapter(VideoAdapter());
    await Hive.openBox<Song>('songsBox');
    await Hive.openBox<Song>('recentlyPlayed');
    await Hive.openBox<Song>('mostPlayed');
    await Hive.openBox('playlistsBox');
    await Hive.openBox('playlistSongsBox');
    await Hive.openBox<Video>('videoBox');
    await Hive.openBox<Video>('mostPlayedVideos');
    await Hive.openBox<Video>('recentlyPlayedVideos');
    // Removed videoFavoritesBox as favorites are now stored in videoBox with isFavorite
    await Hive.openBox('videoPlaylistsBox');
    await Hive.openBox('videoPlaylistVideosBox');

    final playlistsBox = Hive.box('playlistsBox');

    if (playlistsBox.isEmpty) {
      await playlistsBox.put('playlistsBox', []);
      log('Initialized playlistsBox with empty playlists list.');
    }

    final playlistSongsBox = Hive.box('playlistSongsBox');

    if (playlistSongsBox.isEmpty) {
      await playlistSongsBox.put('playlistSongsBox', {});
      log('Initialized playlistSongsBox with empty map.');
    }

    final videoBox = Hive.box<Video>('videoBox');
    if (videoBox.isEmpty) {
      log('Initialized videoBox with ${videoBox.length} videos.');
    }

    final videoPlaylistsBox = Hive.box('videoPlaylistsBox');
    if (videoPlaylistsBox.isEmpty) {
      await videoPlaylistsBox.put('playlists', []);
      log('Initialized videoPlaylistsBox with empty playlists list.');
    }

    final videoPlaylistVideosBox = Hive.box('videoPlaylistVideosBox');
    if (videoPlaylistVideosBox.isEmpty) {
      await videoPlaylistVideosBox.put('playlistVideosBox', {});
      log('Initialized videoPlaylistVideosBox with empty map.');
    }

    // Migrate any invalid data during initialization
    final keys = playlistSongsBox.keys.toList();
    for (var key in keys) {
      final data = playlistSongsBox.get(key);
      if (data is Map && !data.containsKey('songs')) {
        final songs = data[key] is List<String>
            ? List<String>.from(data[key] as List<String>)
            : [];
        await playlistSongsBox.put(key.toString(), {
          'songs': songs,
          'createdAt': DateTime.now().toString(),
          'updatedAt': DateTime.now().toString(),
        });
      } else if (data is! Map) {
        await playlistSongsBox.put(key.toString(), {
          'songs': [],
          'createdAt': DateTime.now().toString(),
          'updatedAt': DateTime.now().toString(),
        });
      }
    }

    log('Hive initialized.');
    log('songsBox opened with ${Hive.box<Song>('songsBox').length} songs.');
    log(
      'recentlyPlayed box opened with ${Hive.box<Song>('recentlyPlayed').length} songs.',
    );
    log(
      'mostPlayed box opened with ${Hive.box<Song>('mostPlayed').length} songs.',
    );
    log('playlistsBox opened with ${playlistsBox.length} entries.');
    log('playlistSongsBox opened with ${playlistSongsBox.length} entries.');
    log('videoBox opened with ${videoBox.length} videos.');
  } catch (e) {
    log('Error initializing Hive: $e');
    rethrow;
  }
}

Future<void> clearHiveData() async {
  await Hive.box<Song>('songsBox').clear();
  await Hive.box<Song>('recentlyPlayed').clear();
  await Hive.box<Song>('mostPlayed').clear();
  await Hive.box('playlistsBox').clear();
  await Hive.box('playlistSongsBox').clear();
  await Hive.box<Video>('videoBox').clear();
  await Hive.box<Video>('mostPlayedVideos').clear();
  await Hive.box<Video>('recentlyPlayedVideos').clear();
  // Removed videoFavoritesBox clear as it’s no longer used
  await Hive.box('videoPlaylistsBox').clear();
  await Hive.box('videoPlaylistVideosBox').clear();
}