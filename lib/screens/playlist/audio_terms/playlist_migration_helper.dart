import 'package:hive/hive.dart';

class PlaylistMigrationHelper {
  static Future<void> migrateOldPlaylistFormat(Box playlistSongsBox) async {
    final keys = playlistSongsBox.keys.toList();
    for (final key in keys) {
      final data = playlistSongsBox.get(key);
      if (data is Map) {
        if (!data.containsKey('songs')) {
          final songs = data[key] is List<dynamic>
              ? List<String>.from(data[key] as List<dynamic>)
              : [];
          await playlistSongsBox.put(key, {
            'songs': songs,
            'createdAt': DateTime.now().toString(),
            'updatedAt': DateTime.now().toString(),
          });
        }
      } else {
        await playlistSongsBox.put(key, {
          'songs': [],
          'createdAt': DateTime.now().toString(),
          'updatedAt': DateTime.now().toString(),
        });
      }
    }
  }
}