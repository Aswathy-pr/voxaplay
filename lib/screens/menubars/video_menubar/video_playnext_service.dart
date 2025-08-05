// import 'package:flutter/material.dart';
// import 'package:musicvoxaplay/screens/models/video_models.dart';
// import 'package:musicvoxaplay/screens/services/video_service.dart';
// import 'package:musicvoxaplay/screens/video/video_fullscreen.dart';

// class VideoPlayNextService {
//   final VideoService videoService;

//   VideoPlayNextService({required this.videoService});

//   Future<Video?> playNext(BuildContext context, Video currentVideo, List<Video> allVideos) async {
//     try {
//       if (allVideos.isEmpty) {
//         debugPrint('No videos available to play next');
//         return null;
//       }

//       int currentIndex = allVideos.indexWhere((video) => video.path == currentVideo.path);
//       if (currentIndex == -1) {
//         debugPrint('Current video not found in the video list');
//         return null;
//       }

//       int nextIndex = (currentIndex + 1) % allVideos.length;
//       Video nextVideo = allVideos[nextIndex];

//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => VideoFullScreen(
//             videos: allVideos,
//             initialIndex: nextIndex,
//           ),
//         ),
//       );

//       await videoService.incrementPlayCount(nextVideo);
//       debugPrint('Playing next video: "${nextVideo.title}"');
//       return nextVideo;
//     } catch (e) {
//       debugPrint('Error playing next video: $e');
//       return null;
//     }
//   }
// }