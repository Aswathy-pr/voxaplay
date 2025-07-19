import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:musicvoxaplay/screens/models/video_models.dart';
import 'dart:convert';

class VideoService {
  static const String _boxName = 'videoBox'; // Matches initializeHive

  // Ensure box is open before accessing
  Future<Box<Video>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Video>(_boxName);
    }
    return Hive.box<Video>(_boxName);
  }

  // Fetch videos from local device and save to Hive
  Future<List<Video>> fetchVideos() async {
    List<Video> videos = [];
    try {
      // Request permissions
      if (!await Permission.storage.request().isGranted &&
          !await Permission.videos.request().isGranted) {
        print("Storage permission denied");
        return videos;
      }

      // Fetch videos using file_picker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );

      if (result != null) {
        final videoFiles = result.files.map((file) => File(file.path!)).toList();
        final box = await _getBox(); // Use safe box access

        // Save to Hive
        for (var file in videoFiles) {
          final video = Video(
            title: file.path.split('/').last, // Use file name as title
            path: file.path,
          );
          await box.put(file.path, video);
          videos.add(video);
        }
      }
    } catch (e) {
      print("Error fetching videos: $e");
    }
    return videos;
  }

  // Export videos to JSON
  Future<String> exportVideosToJson() async {
    final box = await _getBox();
    final videos = box.values.toList();
    final jsonList = videos.map((video) => video.toJson()).toList();
    return jsonEncode(jsonList);
  }

  // Get all videos from Hive
  List<Video> getAllVideos() {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<Video>(_boxName).values.toList();
    }
    return []; // Return empty list if box isn't open
  }
}