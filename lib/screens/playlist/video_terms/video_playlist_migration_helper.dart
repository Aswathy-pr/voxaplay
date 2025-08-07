import 'package:hive/hive.dart';

class VideoPlaylistMigrationHelper {
  static Future<void> migrateOldPlaylistFormat(Box playlistVideosBox) async {
    final keys = playlistVideosBox.keys.toList();
    for (final key in keys) {
      final data = playlistVideosBox.get(key);
      if (data is Map) {
        if (!data.containsKey('videos')) {
          final videos = data[key] is List<dynamic>
              ? List<String>.from(data[key] as List<dynamic>)
              : [];
          await playlistVideosBox.put(key, {
            'videos': videos,
            'createdAt': DateTime.now().toString(),
            'updatedAt': DateTime.now().toString(),
          });
        }
      } else {
        await playlistVideosBox.put(key, {
          'videos': [],
          'createdAt': DateTime.now().toString(),
          'updatedAt': DateTime.now().toString(),
        });
      }
    }
  }
}