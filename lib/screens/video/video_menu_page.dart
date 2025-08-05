// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:musicvoxaplay/screens/models/video_models.dart';
// import 'package:musicvoxaplay/screens/services/video_service.dart';
// import 'package:musicvoxaplay/screens/menubars/song_menubar/add_to_playlist.dart';
// import 'package:musicvoxaplay/screens/menubars/video_menubar/video_favourite_service.dart';
// import 'package:musicvoxaplay/screens/widgets/appbar.dart';
// import 'package:musicvoxaplay/screens/widgets/colors.dart';

// class VideoMenuPage extends StatefulWidget {
//   final Video video;
//   final VideoService videoService;
//   final List<Video> allVideos;

//   const VideoMenuPage({
//     Key? key,
//     required this.video,
//     required this.videoService,
//     required this.allVideos,
//   }) : super(key: key);

//   @override
//   _VideoMenuPageState createState() => _VideoMenuPageState();
// }

// class _VideoMenuPageState extends State<VideoMenuPage> {
//   late Video _video;

//   @override
//   void initState() {
//     super.initState();
//     _video = widget.video ?? Video(title: 'Unknown', path: '');
//   }

//   Future<void> _toggleFavorite() async {
//     if (!mounted) return;
//     try {
//       await VideoFavoriteService(widget.videoService).toggleFavorite(
//         context,
//         _video,
//         (updatedVideo) {
//           if (mounted) {
//             setState(() {
//               _video = updatedVideo;
//             });
//           }
//         },
//       );
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             backgroundColor: AppColors.red,
//             content: Text('Error updating favorite: $e'),
//             duration: const Duration(seconds: 2),
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _addToPlaylist() async {
//     try {
//       final playlistsBox = Hive.box('videoPlaylistsBox');
//       final playlistVideosBox = Hive.box('videoPlaylistVideosBox');
//       final playlists = playlistsBox.get('playlists', defaultValue: [])!;

//       if (playlists.isEmpty) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               backgroundColor: AppColors.red,
//               content: const Text('No playlists available. Create a playlist first.'),
//               duration: const Duration(seconds: 2),
//             ),
//           );
//         }
//         return;
//       }

//       String? selectedPlaylist;
//       await showDialog<String>(
//         context: context,
//         builder: (context) => AddToPlaylistDialog(
//           playlists: playlists,
//           onSelect: (playlistName) {
//             selectedPlaylist = playlistName;
//           },
//         ),
//       );

//       if (selectedPlaylist != null && mounted) {
//         final playlistData = playlistVideosBox.get(selectedPlaylist);
//         List<String> videos = [];

//         if (playlistData != null && playlistData['videos'] != null) {
//           videos = List<String>.from(playlistData['videos']);
//         }

//         if (videos.contains(_video.path)) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               backgroundColor: AppColors.red,
//               content: Text('Video is already in "$selectedPlaylist"'),
//               duration: const Duration(seconds: 2),
//             ),
//           );
//         } else {
//           videos.add(_video.path);
//           await playlistVideosBox.put(selectedPlaylist, {
//             'videos': videos,
//             'createdAt': playlistData?['createdAt'] ?? DateTime.now().toString(),
//             'updatedAt': DateTime.now().toString(),
//           });

//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               backgroundColor: AppColors.red,
//               content: Text('Added "${_video.title}" to "$selectedPlaylist"'),
//               duration: const Duration(seconds: 2),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             backgroundColor: AppColors.red,
//             content: Text('Error adding to playlist: $e'),
//             duration: const Duration(seconds: 2),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       appBar: buildAppBar(context, 'Video Options', showBackButton: true),
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 30),
//                   Row(
//                     children: [
//                       // Video Thumbnail
//                       _video.thumbnail != null && _video.thumbnail!.isNotEmpty
//                           ? ClipRRect(
//                               borderRadius: BorderRadius.circular(8),
//                               child: Image.memory(
//                                 _video.thumbnail!,
//                                 width: 60,
//                                 height: 60,
//                                 fit: BoxFit.cover,
//                               ),
//                             )
//                           : Container(
//                               width: 60,
//                               height: 60,
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[300],
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Icon(
//                                 Icons.video_library,
//                                 color: Theme.of(context).textTheme.bodyLarge!.color,
//                                 size: 30,
//                               ),
//                             ),
//                       const SizedBox(width: 30),
//                       // Video Title
//                       Expanded(
//                         child: Text(
//                           _video.title,
//                           style: Theme.of(context).textTheme.bodyLarge!.copyWith(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   // Video Duration
//                   Text(
//                     _video.duration != null
//                         ? '${_video.duration!.inMinutes}:${(_video.duration!.inSeconds % 60).toString().padLeft(2, '0')}'
//                         : 'Unknown duration',
//                     style: Theme.of(context).textTheme.bodyMedium!.copyWith(
//                           color: Colors.grey[600],
//                         ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: ListView(
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 children: [
//                   _buildMenuItem(
//                     context,
//                     Icons.play_arrow,
//                     'Play Video',
//                     onTap: () => Navigator.pop(context, 'play'),
//                   ),
//                   _buildMenuItem(
//                     context,
//                     _video.isFavorite ? Icons.favorite : Icons.favorite_border,
//                     _video.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
//                     onTap: _toggleFavorite,
//                     iconColor: _video.isFavorite ? AppColors.red : null,
//                   ),
//                   _buildMenuItem(
//                     context,
//                     Icons.playlist_add,
//                     'Add to Playlist',
//                     onTap: _addToPlaylist,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMenuItem(
//     BuildContext context,
//     IconData icon,
//     String text, {
//     VoidCallback? onTap,
//     Color? iconColor,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 20),
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               color: iconColor ?? Theme.of(context).textTheme.bodyLarge!.color,
//               size: 30,
//             ),
//             const SizedBox(width: 12),
//             Text(
//               text,
//               style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 20),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicvoxaplay/screens/models/video_models.dart';
import 'package:musicvoxaplay/screens/services/video_service.dart';
import 'package:musicvoxaplay/screens/menubars/song_menubar/add_to_playlist.dart';
import 'package:musicvoxaplay/screens/menubars/video_menubar/video_favourite_service.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';

class VideoMenuPage extends StatefulWidget {
  final Video video;
  final VideoService videoService;
  final List<Video> allVideos;

  const VideoMenuPage({
    Key? key,
    required this.video,
    required this.videoService,
    required this.allVideos,
  }) : super(key: key);

  @override
  _VideoMenuPageState createState() => _VideoMenuPageState();
}

class _VideoMenuPageState extends State<VideoMenuPage> {
  late Video _video;

  @override
  void initState() {
    super.initState();
    _video = widget.video;
  }

  Future<void> _toggleFavorite() async {
    if (!mounted) return;
    try {
      await VideoFavoriteService(widget.videoService).toggleFavorite(
        context,
        _video,
        (updatedVideo) {
          if (mounted) {
            setState(() {
              _video = updatedVideo;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.red,
            content: Text('Error updating favorite: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _addToPlaylist() async {
    try {
      final playlistsBox = await Hive.openBox('videoPlaylistsBox');
      final playlistVideosBox = await Hive.openBox('videoPlaylistVideosBox');
      final playlists = playlistsBox.get('playlists', defaultValue: [])!;

      if (playlists.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.red,
              content: const Text('No playlists available. Create a playlist first.'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        await playlistsBox.close();
        await playlistVideosBox.close();
        return;
      }

      String? selectedPlaylist;
      await showDialog<String>(
        context: context,
        builder: (context) => AddToPlaylistDialog(
          playlists: playlists,
          onSelect: (playlistName) {
            selectedPlaylist = playlistName;
            Navigator.pop(context); // Close dialog after selection
          },
        ),
      );

      if (selectedPlaylist != null && mounted) {
        final playlistData = playlistVideosBox.get(selectedPlaylist);
        List<String> videos = [];

        if (playlistData != null && playlistData['videos'] != null) {
          videos = List<String>.from(playlistData['videos']);
        }

        if (videos.contains(_video.path)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.red,
              content: Text('Video is already in "$selectedPlaylist"'),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          videos.add(_video.path);
          await playlistVideosBox.put(selectedPlaylist, {
            'videos': videos,
            'createdAt': playlistData?['createdAt'] ?? DateTime.now().toString(),
            'updatedAt': DateTime.now().toString(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.red,
              content: Text('Added "${_video.title}" to "$selectedPlaylist"'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }

      await playlistsBox.close();
      await playlistVideosBox.close();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.red,
            content: Text('Error adding to playlist: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: buildAppBar(context, 'Video Options', showBackButton: true),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      _video.thumbnail != null && _video.thumbnail!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                _video.thumbnail!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.video_library,
                                color: Theme.of(context).textTheme.bodyLarge!.color,
                                size: 30,
                              ),
                            ),
                      const SizedBox(width: 30),
                      Expanded(
                        child: Text(
                          _video.title,
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _video.duration != null
                        ? '${_video.duration!.inMinutes}:${(_video.duration!.inSeconds % 60).toString().padLeft(2, '0')}'
                        : 'Unknown duration',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  _buildMenuItem(
                    context,
                    Icons.play_arrow,
                    'Play Video',
                    onTap: () => Navigator.pop(context, 'play'),
                  ),
                  _buildMenuItem(
                    context,
                    _video.isFavorite ? Icons.favorite : Icons.favorite_border,
                    _video.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                    onTap: _toggleFavorite,
                    iconColor: _video.isFavorite ? AppColors.red : null,
                  ),
                  _buildMenuItem(
                    context,
                    Icons.playlist_add,
                    'Add to Playlist',
                    onTap: _addToPlaylist,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String text, {
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? Theme.of(context).textTheme.bodyLarge!.color,
              size: 30,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}