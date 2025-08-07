import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_player/video_player.dart';
import 'dart:typed_data';
import 'package:musicvoxaplay/screens/models/video_models.dart';
import 'package:musicvoxaplay/screens/services/video_service/video_metadata.dart';


class VideoUtils {
  static Future<bool> requestPermissions() async {
    final storagePermission = await Permission.storage.request();
    final videosPermission = await Permission.videos.request();
    return storagePermission.isGranted && videosPermission.isGranted;
  }

  static Future<Uint8List?> generateThumbnail(String videoPath) async {
    try {
      return await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.PNG,
        maxWidth: 128,
        quality: 75,
      );
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  static Future<Duration?> getVideoDuration(File file) async {
    try {
      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      final duration = controller.value.duration;
      await controller.dispose();
      return duration;
    } catch (e) {
      print('Error getting video duration: $e');
      return null;
    }
  }

  static Future<void> scanDirectoryForVideos(
    Directory directory,
    List<String> videoExtensions,
    List<Video> videos,
    Function(Video) onVideoFound,
  ) async {
    try {
      print('Scanning directory: ${directory.path}');
      int fileCount = 0;
      int videoCount = 0;

      await for (FileSystemEntity entity in directory.list(recursive: true)) {
        if (entity is File) {
          fileCount++;
          String fileName = entity.path.split('/').last.toLowerCase();
          if (videoExtensions.any((ext) => fileName.endsWith(ext))) {
            videoCount++;
            print('Found video file: $fileName');
            final video = await VideoMetadata.createVideoFromFile(entity as File);
            if (video != null) {
              onVideoFound(video);
            }
          }
        }
      }
      print('Scanned $fileCount files, found $videoCount video files in ${directory.path}');
    } catch (e) {
      print('Error scanning directory ${directory.path}: $e');
    }
  }
}