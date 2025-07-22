import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:musicvoxaplay/screens/models/video_models.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoService {
  static const String _boxName = 'videoBox'; // Matches initializeHive

  // Ensure box is open before accessing
  Future<Box<Video>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Video>(_boxName);
    }
    return Hive.box<Video>(_boxName);
  }

  Future<Video?> _createVideoFromFile(File file) async {
    try {
      print("Creating video from file:  [38;5;2m");
      
      // Get file info
      FileStat stat = await file.stat();
      print("File size:  [38;5;2m");
      
      if (stat.size == 0) {
        print("Skipping empty file:  [38;5;2m");
        return null;
      }

      // Extract video metadata
      Duration? duration;
      Uint8List? thumbnail;

      try {
        print("Initializing video controller for:  [38;5;2m");
        final controller = VideoPlayerController.file(file);
        await controller.initialize();
        duration = controller.value.duration;
        print("Video duration:  [38;5;2m");
        
        await controller.dispose();
        // Generate thumbnail using video_thumbnail package
        thumbnail = await VideoThumbnail.thumbnailData(
          video: file.path,
          imageFormat: ImageFormat.PNG,
          maxWidth: 128, // reasonable size for list
          quality: 75,
        );
      } catch (e) {
        print("Error extracting video metadata for  [38;5;2m");
      }

      // Clean up title (remove extension)
      String fileNameClean = file.path.split('/').last;
      int dotIndex = fileNameClean.lastIndexOf('.');
      String cleanTitle = dotIndex != -1 ? fileNameClean.substring(0, dotIndex) : fileNameClean;
      final video = Video(
        title: cleanTitle,
        path: file.path,
        duration: duration,
        thumbnail: thumbnail,
      );
      
      print("Created video:  [38;5;2m");
      return video;
    } catch (e) {
      print("Error creating video from file  [38;5;2m");
      return null;
    }
  }

  Future<void> _scanDirectoryForVideos(
    Directory directory, 
    List<String> videoExtensions, 
    List<Video> videos, 
    Box<Video> box
  ) async {
    try {
      print("Scanning directory: ${directory.path}");
      int fileCount = 0;
      int videoCount = 0;
      
      await for (FileSystemEntity entity in directory.list(recursive: true)) {
        if (entity is File) {
          fileCount++;
          String fileName = entity.path.split('/').last.toLowerCase();
          bool isVideo = videoExtensions.any((ext) => fileName.endsWith(ext));
          
          if (isVideo) {
            videoCount++;
            print("Found video file: $fileName");
            try {
              // Check if video already exists
              if (!videos.any((v) => v.path == entity.path)) {
                final video = await _createVideoFromFile(entity);
                if (video != null) {
                  await box.put(video.path, video);
                  videos.add(video);
                  print("Added video: ${video.title}");
                }
              }
            } catch (e) {
              print("Error processing video file ${entity.path}: $e");
            }
          }
        }
      }
      
      print("Scanned $fileCount files, found $videoCount video files in ${directory.path}");
    } catch (e) {
      print("Error scanning directory ${directory.path}: $e");
    }
  }

  // Fetch videos from local device and save to Hive
  Future<List<Video>> fetchVideos() async {
    List<Video> videos = [];
    try {
   ("Starting video fetch...");
      
      // Request permissions
      final storagePermission = await Permission.storage.request();
      final videosPermission = await Permission.videos.request();
      
      print("Storage permission: ${storagePermission.isGranted}");
      print("Videos permission: ${videosPermission.isGranted}");
      
      if (!storagePermission.isGranted && !videosPermission.isGranted) {
        print("Storage permission denied");
        return videos;
      }

      // Clear existing videos to prevent duplicates
      final box = await _getBox();
      await box.clear();
      print("Cleared existing videos from Hive");

      // Get external storage directory
      Directory? externalDir = await getExternalStorageDirectory();
      print("External storage directory: ${externalDir?.path}");
      
      if (externalDir == null) {
        print("Could not access external storage");
        return videos;
      }

      // Common video directories to scan
      List<String> videoDirectories = [
        '/storage/emulated/0/DCIM',
        '/storage/emulated/0/Movies',
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Videos',
        externalDir.path,
      ];

      // Video file extensions
      List<String> videoExtensions = [
        '.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm', '.m4v', '.3gp'
      ];

      print("Scanning directories: $videoDirectories");
      print("Looking for extensions: $videoExtensions");

      for (String directoryPath in videoDirectories) {
        try {
          Directory directory = Directory(directoryPath);
          bool exists = await directory.exists();
          print("Directory $directoryPath exists: $exists");
          
          if (exists) {
            await _scanDirectoryForVideos(directory, videoExtensions, videos, box);
          }
        } catch (e) {
          print("Error scanning directory $directoryPath: $e");
        }
      }

      print("Found ${videos.length} videos after scanning directories");

      // Remove duplicates and filter out trashed/system videos before saving to Hive and returning
      final uniqueVideos = <String, Video>{};
      for (var video in videos) {
        uniqueVideos[video.path] = video;
      }
      await box.clear();
      await box.putAll({for (var v in uniqueVideos.values) v.path: v});
      print("Final video count:  [38;5;2m");
      return uniqueVideos.values.toList();
    } catch (e) {
      print("Error fetching videos: $e");
    }
    return [];
  }

  // Fetch videos using file picker only
  Future<List<Video>> fetchVideosWithPicker() async {
    List<Video> videos = [];
    try {
      print("Starting video fetch with picker...");
      
      // Request permissions
      final storagePermission = await Permission.storage.request();
      final videosPermission = await Permission.videos.request();
      
      print("Storage permission: ${storagePermission.isGranted}");
      print("Videos permission: ${videosPermission.isGranted}");
      
      if (!storagePermission.isGranted && !videosPermission.isGranted) {
        print("Storage permission denied");
        return videos;
      }

      // Clear existing videos to prevent duplicates
      final box = await _getBox();
      await box.clear();
      print("Cleared existing videos from Hive");

      print("Opening file picker for video selection...");
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );

      if (result != null) {
        print("File picker returned ${result.files.length} files");
        final videoFiles = result.files.map((file) => File(file.path!)).toList();
        
        for (var file in videoFiles) {
          final video = await _createVideoFromFile(file);
          if (video != null) {
            // Only add if not already in the list (by path)
            if (!videos.any((v) => v.path == video.path)) {
              videos.add(video);
            }
          }
        }
      } else {
        print("File picker was cancelled or returned null");
      }

      // Remove duplicates and filter out trashed/system videos before saving to Hive and returning
      final uniqueVideos = <String, Video>{};
      for (var video in videos) {
        uniqueVideos[video.path] = video;
      }
      await box.clear();
      await box.putAll({for (var v in uniqueVideos.values) v.path: v});
      return uniqueVideos.values.toList();
    } catch (e) {
      print("Error fetching videos with picker: $e");
    }
    return [];
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