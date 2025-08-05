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
  static const String _boxName = 'videoBox'; 
  static const String _mostPlayedBoxName = 'mostPlayedVideos';
  static const String _recentlyPlayedBoxName = 'recentlyPlayedVideos';

  Future<Box<Video>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Video>(_boxName);
    }
    return Hive.box<Video>(_boxName);
  }

  Future<Box<Video>> _getMostPlayedBox() async {
    if (!Hive.isBoxOpen(_mostPlayedBoxName)) {
      await Hive.openBox<Video>(_mostPlayedBoxName);
    }
    return Hive.box<Video>(_mostPlayedBoxName);
  }

  Future<Box<Video>> _getRecentlyPlayedBox() async {
    if (!Hive.isBoxOpen(_recentlyPlayedBoxName)) {
      await Hive.openBox<Video>(_recentlyPlayedBoxName);
    }
    return Hive.box<Video>(_recentlyPlayedBoxName);
  }

  Future<Video?> _createVideoFromFile(File file) async {
    try {
      print("Creating video from file:  [38;5;2m");
      
      FileStat stat = await file.stat();
      print("File size:  [38;5;2m");
      
      if (stat.size == 0) {
        print("Skipping empty file:  [38;5;2m");
        return null;
      }

    
      Duration? duration;
      Uint8List? thumbnail;

      try {
        print("Initializing video controller for:  [38;5;2m");
        final controller = VideoPlayerController.file(file);
        await controller.initialize();
        duration = controller.value.duration;
        print("Video duration:  [38;5;2m");
        
        await controller.dispose();
        
        thumbnail = await VideoThumbnail.thumbnailData(
          video: file.path,
          imageFormat: ImageFormat.PNG,
          maxWidth: 128, 
          quality: 75,
        );
      } catch (e) {
        print("Error extracting video metadata for  [38;5;2m");
      }

      
      String fileNameClean = file.path.split('/').last;
      int dotIndex = fileNameClean.lastIndexOf('.');
      String cleanTitle = dotIndex != -1 ? fileNameClean.substring(0, dotIndex) : fileNameClean;
      final video = Video(
        title: cleanTitle,
        path: file.path,
        duration: duration,
        thumbnail: thumbnail,
        isFavorite: false, // Default to false
        playcount: 0,
        playedAt: null,
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

  Future<List<Video>> fetchVideos() async {
    List<Video> videos = [];
    try {
      print("Starting video fetch...");
      
      // Request permissions
      final storagePermission = await Permission.storage.request();
      final videosPermission = await Permission.videos.request();
      
      print("Storage permission: ${storagePermission.isGranted}");
      print("Videos permission: ${videosPermission.isGranted}");
      
      if (!storagePermission.isGranted && !videosPermission.isGranted) {
        print("Storage permission denied");
        return videos;
      }

      
      final box = await _getBox();
      await box.clear();
      print("Cleared existing videos from Hive");

     
      Directory? externalDir = await getExternalStorageDirectory();
      print("External storage directory: ${externalDir?.path}");
      
      if (externalDir == null) {
        print("Could not access external storage");
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

      // Prevent duplicates
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
            // Only add if not already in the list 
            if (!videos.any((v) => v.path == video.path)) {
              videos.add(video);
            }
          }
        }
      } else {
        print("File picker was cancelled or returned null");
      }

      // Remove duplicates 
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

  Future<String> exportVideosToJson() async {
    final box = await _getBox();
    final videos = box.values.toList();
    final jsonList = videos.map((video) => video.toJson()).toList();
    return jsonEncode(jsonList);
  }

  List<Video> getAllVideos() {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<Video>(_boxName).values.toList();
    }
    return []; 
  }

  Future<List<Video>> getMostPlayedVideos() async {
    try {
      final box = await _getMostPlayedBox();
      final videos = box.values.toList();
      videos.sort((a, b) => b.playcount.compareTo(a.playcount));
      return videos;
    } catch (e) {
      print('Error getting most played videos: $e');
      return [];
    }
  }

  Future<List<Video>> getRecentlyPlayedVideos() async {
    try {
      final box = await _getRecentlyPlayedBox();
      final videos = box.values.toList();
      videos.sort((a, b) => (b.playedAt ?? DateTime(0)).compareTo(a.playedAt ?? DateTime(0)));
      return videos;
    } catch (e) {
      print('Error getting recently played videos: $e');
      return [];
    }
  }

  Future<void> incrementPlayCount(Video video) async {
    try {
      final box = await _getBox();
      final mostPlayedBox = await _getMostPlayedBox();
      final recentlyPlayedBox = await _getRecentlyPlayedBox();

      // Create updated video with current timestamp and incremented play count
      final updatedVideo = Video(
        title: video.title,
        path: video.path,
        duration: video.duration,
        thumbnail: video.thumbnail,
        playedAt: DateTime.now(),
        isFavorite: video.isFavorite,
        playcount: video.playcount + 1,
      );
      
      // Find the video in the main box
      final videoIndex = box.values.toList().indexWhere(
        (v) => v.path == video.path,
      );
      
      if (videoIndex != -1) {
        await box.putAt(videoIndex, updatedVideo);
      } else {
        // If video not in main box, add it
        await box.put(video.path, updatedVideo);
      }
      
      // Update in most played box
      final mostPlayedIndex = mostPlayedBox.values.toList().indexWhere(
        (v) => v.path == video.path,
      );
      if (mostPlayedIndex != -1) {
        await mostPlayedBox.putAt(mostPlayedIndex, updatedVideo);
      } else {
        await mostPlayedBox.add(updatedVideo);
      }
      
      // Add to recently played
      await addToRecentlyPlayed(updatedVideo);
      
      await mostPlayedBox.compact();
      await recentlyPlayedBox.compact();
      
      print('Incremented play count for "${video.title}" to ${updatedVideo.playcount}');
    } catch (e) {
      print('Error incrementing play count: $e');
    }
  }

  Future<void> updateFavoriteStatus(Video video) async {
    try {
      final box = await _getBox(); // Use videoBox instead of videoFavoritesBox
      final videoIndex = box.values.toList().indexWhere(
        (v) => v.path == video.path,
      );
      if (videoIndex != -1) {
        final existingVideo = box.getAt(videoIndex)!;
        final updatedVideo = Video(
          title: existingVideo.title,
          path: existingVideo.path,
          duration: existingVideo.duration,
          thumbnail: existingVideo.thumbnail,
          isFavorite: !existingVideo.isFavorite, // Toggle isFavorite
          playcount: existingVideo.playcount,
          playedAt: existingVideo.playedAt,
        );
        await box.putAt(videoIndex, updatedVideo);
        print('Updated favorite status for "${updatedVideo.title}" to ${updatedVideo.isFavorite} in videoBox');
      } else {
        print('Video "${video.title}" not found in videoBox');
      }
    } catch (e) {
      print('Error updating favorite status: $e');
    }
  }

  Future<List<Video>> getFavoriteVideos() async {
    try {
      final box = await _getBox();
      if (box.isEmpty) {
        print('videoBox is empty');
        return [];
      }
      final favoriteVideos = box.values
          .where((video) => video.isFavorite ?? false) // Handle null isFavorite
          .toList();
      print('Fetched ${favoriteVideos.length} favorite videos');
      return favoriteVideos;
    } catch (e) {
      print('Error fetching favorite videos: $e');
      return [];
    }
  }

  Future<void> addToRecentlyPlayed(Video video) async {
    try {
      final box = await _getRecentlyPlayedBox();
      
      print('Adding video to recently played: ${video.title}');
      print('Current box length: ${box.length}');
      
      // Remove existing entry if it exists
      final existingIndex = box.values.toList().indexWhere(
        (v) => v.path == video.path,
      );
      if (existingIndex != -1) {
        await box.deleteAt(existingIndex);
        print('Removed existing video at index: $existingIndex');
      }
      
      // Add to the beginning by using a unique key
      final key = DateTime.now().millisecondsSinceEpoch.toString();
      await box.put(key, video);
      print('Added video to recently played box. New length: ${box.length}');
      
      // Keep only the last 50 videos
      if (box.length > 50) {
        final videos = box.values.toList();
        videos.sort((a, b) => (b.playedAt ?? DateTime(0)).compareTo(a.playedAt ?? DateTime(0)));
        await box.clear();
        await box.addAll(videos.take(50));
        print('Trimmed recently played to 50 videos');
      }
    } catch (e) {
      print('Error adding to recently played: $e');
    }
  }
}