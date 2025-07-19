
// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:musicvoxaplay/screens/models/video_models.dart';
// import 'package:musicvoxaplay/screens/services/video_service.dart';

// class VideoPage extends StatefulWidget {
//   const VideoPage({Key? key}) : super(key: key);

//   @override
//   _VideoPageState createState() => _VideoPageState();
// }

// class _VideoPageState extends State<VideoPage> {
//   final VideoService _videoService = VideoService();
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _videoService.fetchVideos().then((_) {
//       setState(() {
//         _isLoading = false; // Stop loading after fetch
//       });
//     }).catchError((e) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching videos: $e')),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('All videos'),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : ValueListenableBuilder(
//               valueListenable: Hive.box<Video>('videoBox').listenable(), 
//               builder: (context, Box<Video> box, _) {
//                 final videos = _videoService.getAllVideos();
//                 if (videos.isEmpty) {
//                   return const Center(child: Text('No videos found'));
//                 }
//                 return ListView.builder(
//                   itemCount: videos.length,
//                   itemBuilder: (context, index) {
//                     final video = videos[index];
//                     return ListTile(
//                       title: Text(
//                         video.title,
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           setState(() {
//             _isLoading = true;
//           });
//           try {
//             await _videoService.fetchVideos();
//           } catch (e) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Error fetching videos: $e')),
//             );
//           }
//           setState(() {
//             _isLoading = false;
//           });
//         },
//         child: const Icon(Icons.refresh),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';

import 'package:musicvoxaplay/screens/models/video_models.dart';
import 'package:musicvoxaplay/screens/services/video_service.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({Key? key}) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late Future<List<Video>> _videosFuture;
  final VideoService _videoService = VideoService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _videosFuture = _videoService.fetchVideos().then((videos) {
      setState(() {
        _isLoading = false;
      });
      return videos;
    }).catchError((e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching videos: $e')),
      ); 

      return <Video>[];
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: buildAppBar(context, 'All video'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: FutureBuilder<List<Video>>(
                  future: _videosFuture,
                  builder: (context, snapshot) {
                    if (_isLoading || snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No videos found'));
                    }
                    final videos = snapshot.data!;
                    return ListView.builder(
                      itemCount: videos.length,
                      itemBuilder: (context, index) {
                        final video = videos[index];
                        return ListTile(
                          title: Text(
                            video.title,
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            _isLoading = true;
          });
          try {
            final videos = await _videoService.fetchVideos();
            setState(() {
              _videosFuture = Future.value(videos);
              _isLoading = false;
            });
          } catch (e) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error fetching videos: $e')),
            );
          }
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}