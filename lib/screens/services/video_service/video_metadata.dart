import 'dart:io';
import 'package:musicvoxaplay/screens/models/video_models.dart';
import 'package:musicvoxaplay/screens/services/video_service/video_utils.dart';

class VideoMetadata {
  static Future<Video?> createVideoFromFile(File file) async {
    try {
      print('Creating video from file: ${file.path}');
      FileStat stat = await file.stat();
      if (stat.size == 0) {
        print('Skipping empty file: ${file.path}');
        return null;
      }

      final duration = await VideoUtils.getVideoDuration(file);
      final thumbnail = await VideoUtils.generateThumbnail(file.path);

      String fileNameClean = file.path.split('/').last;
      int dotIndex = fileNameClean.lastIndexOf('.');
      String cleanTitle = dotIndex != -1 ? fileNameClean.substring(0, dotIndex) : fileNameClean;

      final video = Video(
        title: cleanTitle,
        path: file.path,
        duration: duration,
        thumbnail: thumbnail,
        isFavorite: false,
        playcount: 0,
        playedAt: null,
      );
      print('Created video: ${video.title}');
      return video;
    } catch (e) {
      print('Error creating video from file ${file.path}: $e');
      return null;
    }
  }
}