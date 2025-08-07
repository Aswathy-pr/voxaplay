import 'package:hive/hive.dart';
import 'package:musicvoxaplay/screens/models/video_models.dart';

class VideoBoxManager {
  static const String _videoBoxName = 'videoBox';
  static const String _mostPlayedBoxName = 'mostPlayedVideos';
  static const String _recentlyPlayedBoxName = 'recentlyPlayedVideos';

  static Future<Box<Video>> getVideoBox() async {
    if (!Hive.isBoxOpen(_videoBoxName)) {
      await Hive.openBox<Video>(_videoBoxName);
    }
    return Hive.box<Video>(_videoBoxName);
  }

  static Future<Box<Video>> getMostPlayedBox() async {
    if (!Hive.isBoxOpen(_mostPlayedBoxName)) {
      await Hive.openBox<Video>(_mostPlayedBoxName);
    }
    return Hive.box<Video>(_mostPlayedBoxName);
  }

  static Future<Box<Video>> getRecentlyPlayedBox() async {
    if (!Hive.isBoxOpen(_recentlyPlayedBoxName)) {
      await Hive.openBox<Video>(_recentlyPlayedBoxName);
    }
    return Hive.box<Video>(_recentlyPlayedBoxName);
  }

  static Future<void> clearBox(String boxName) async {
    final box = await Hive.openBox<Video>(boxName);
    await box.clear();
  }

  static Future<void> putVideo(Box<Video> box, String key, Video video) async {
    await box.put(key, video);
  }

  static Future<void> putAllVideos(Box<Video> box, Map<String, Video> videos) async {
    await box.putAll(videos);
  }

  static List<Video> getBoxValues(String boxName) {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<Video>(boxName).values.toList();
    }
    return [];
  }
}