import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:musicvoxaplay/screens/models/video_models.dart';
import 'package:musicvoxaplay/screens/services/video_service/video_utils.dart';
import 'package:musicvoxaplay/screens/services/video_service/video_box_manager.dart';
import 'package:musicvoxaplay/screens/services/video_service/video_metadata.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class VideoService {
  Future<List<Video>> fetchVideos() async {
    List<Video> videos = [];
    try {
      print('Starting video fetch...');
      if (!await VideoUtils.requestPermissions()) {
        print('Storage permission denied');
        return videos;
      }

      final box = await VideoBoxManager.getVideoBox();
      await VideoBoxManager.clearBox('videoBox');
      print('Cleared existing videos from Hive');

      Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir == null) {
        print('Could not access external storage');
        return videos;
      }

      List<String> videoDirectories = [
        '/storage/emulated/0/DCIM',
        '/storage/emulated/0/Movies',
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Videos',
        externalDir.path,
      ];

      List<String> videoExtensions = [
        '.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm', '.m4v', '.3gp'
      ];

    ('Scanning directories: $videoDirectories');
      for (String directoryPath in videoDirectories) {
        try {
          Directory directory = Directory(directoryPath);
          if (await directory.exists()) {
            await VideoUtils.scanDirectoryForVideos(
              directory,
              videoExtensions,
              videos,
              (video) => VideoBoxManager.putVideo(box, video.path, video),
            );
          }
        } catch (e) {
       ('Error scanning directory $directoryPath: $e');
        }
      }

      ('Found ${videos.length} videos after scanning directories');
      final uniqueVideos = <String, Video>{for (var v in videos) v.path: v};
      await VideoBoxManager.clearBox('videoBox');
      await VideoBoxManager.putAllVideos(box, {for (var v in uniqueVideos.values) v.path: v});
      return uniqueVideos.values.toList();
    } catch (e) {
     ('Error fetching videos: $e');
    }
    return [];
  }

  Future<List<Video>> fetchVideosWithPicker() async {
    List<Video> videos = [];
    try {
     ('Starting video fetch with picker...');
      if (!await VideoUtils.requestPermissions()) {
        ('Storage permission denied');
        return videos;
      }

      final box = await VideoBoxManager.getVideoBox();
      await VideoBoxManager.clearBox('videoBox');
 ('Cleared existing videos from Hive');

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );

      if (result != null) {
    ('File picker returned ${result.files.length} files');
        for (var file in result.files.map((f) => File(f.path!))) {
          final video = await VideoMetadata.createVideoFromFile(file);
          if (video != null && !videos.any((v) => v.path == video.path)) {
            videos.add(video);
            await VideoBoxManager.putVideo(box, video.path, video);
          }
        }
      } else {
        ('File picker was cancelled or returned null');
      }
      return videos;
    } catch (e) {
      ('Error fetching videos with picker: $e');
    }
    return [];
  }

  Future<String> exportVideosToJson() async {
    final box = await VideoBoxManager.getVideoBox();
    final videos = VideoBoxManager.getBoxValues('videoBox');
    final jsonList = videos.map((video) => video.toJson()).toList();
    return jsonEncode(jsonList);
  }

  List<Video> getAllVideos() {
    return VideoBoxManager.getBoxValues('videoBox');
  }

  Future<List<Video>> getMostPlayedVideos() async {
    try {
      final videos = VideoBoxManager.getBoxValues('mostPlayedVideos');
      videos.sort((a, b) => b.playcount.compareTo(a.playcount));
      return videos;
    } catch (e) {
      print('Error getting most played videos: $e');
      return [];
    }
  }

  Future<List<Video>> getRecentlyPlayedVideos() async {
    try {
      final videos = VideoBoxManager.getBoxValues('recentlyPlayedVideos');
      videos.sort((a, b) => (b.playedAt ?? DateTime(0)).compareTo(a.playedAt ?? DateTime(0)));
      return videos;
    } catch (e) {
      print('Error getting recently played videos: $e');
      return [];
    }
  }

  Future<void> incrementPlayCount(Video video) async {
    try {
      final box = await VideoBoxManager.getVideoBox();
      final mostPlayedBox = await VideoBoxManager.getMostPlayedBox();
      final recentlyPlayedBox = await VideoBoxManager.getRecentlyPlayedBox();

      final updatedVideo = Video(
        title: video.title,
        path: video.path,
        duration: video.duration,
        thumbnail: video.thumbnail,
        playedAt: DateTime.now(),
        isFavorite: video.isFavorite,
        playcount: video.playcount + 1,
      );

      final videoIndex = box.values.toList().indexWhere((v) => v.path == video.path);
      if (videoIndex != -1) await VideoBoxManager.putVideo(box, box.keyAt(videoIndex)!, updatedVideo);

      final mostPlayedIndex = mostPlayedBox.values.toList().indexWhere((v) => v.path == video.path);
      if (mostPlayedIndex != -1) {
        await VideoBoxManager.putVideo(mostPlayedBox, mostPlayedBox.keyAt(mostPlayedIndex)!, updatedVideo);
      } else {
        await VideoBoxManager.putVideo(mostPlayedBox, video.path, updatedVideo);
      }

      await addToRecentlyPlayed(updatedVideo);
    } catch (e) {
      print('Error incrementing play count: $e');
    }
  }

  Future<void> updateFavoriteStatus(Video video) async {
    try {
      final box = await VideoBoxManager.getVideoBox();
      final videoIndex = box.values.toList().indexWhere((v) => v.path == video.path);
      if (videoIndex != -1) {
        final existingVideo = box.getAt(videoIndex)!;
        final updatedVideo = Video(
          title: existingVideo.title,
          path: existingVideo.path,
          duration: existingVideo.duration,
          thumbnail: existingVideo.thumbnail,
          isFavorite: !existingVideo.isFavorite,
          playcount: existingVideo.playcount,
          playedAt: existingVideo.playedAt,
        );
        await VideoBoxManager.putVideo(box, box.keyAt(videoIndex)!, updatedVideo);
      }
    } catch (e) {
      print('Error updating favorite status: $e');
    }
  }

  Future<List<Video>> getFavoriteVideos() async {
    try {
      final box = await VideoBoxManager.getVideoBox();
      return box.values.where((video) => video.isFavorite ?? false).toList();
    } catch (e) {
      print('Error fetching favorite videos: $e');
      return [];
    }
  }

  Future<void> addToRecentlyPlayed(Video video) async {
    try {
      final box = await VideoBoxManager.getRecentlyPlayedBox();
      final existingIndex = box.values.toList().indexWhere((v) => v.path == video.path);
      if (existingIndex != -1) await box.deleteAt(existingIndex);

      final key = DateTime.now().millisecondsSinceEpoch.toString();
      await VideoBoxManager.putVideo(box, key, video);

      if (box.length > 50) {
        final videos = box.values.toList();
        videos.sort((a, b) => (b.playedAt ?? DateTime(0)).compareTo(a.playedAt ?? DateTime(0)));
        await VideoBoxManager.clearBox('recentlyPlayedVideos');
        await box.addAll(videos.take(50));
      }
    } catch (e) {
      print('Error adding to recently played: $e');
    }
  }
}