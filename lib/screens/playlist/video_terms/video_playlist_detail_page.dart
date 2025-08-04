import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';
import 'package:musicvoxaplay/screens/models/video_models.dart';
import 'package:musicvoxaplay/screens/video/video_fullscreen.dart';

class VideoPlaylistDetailPage extends StatefulWidget {
  final String playlistName;
  final Box playlistVideosBox;

  const VideoPlaylistDetailPage({
    super.key,
    required this.playlistName,
    required this.playlistVideosBox,
  });

  @override
  State<VideoPlaylistDetailPage> createState() => _VideoPlaylistDetailPageState();
}

class _VideoPlaylistDetailPageState extends State<VideoPlaylistDetailPage> {
  late Box<Video> videosBox;
  List<String> playlistVideos = [];

  @override
  void initState() {
    super.initState();
    videosBox = Hive.box<Video>('videoBox');
    _loadPlaylistVideos();
  }

  void _loadPlaylistVideos() {
    final playlistData = widget.playlistVideosBox.get(widget.playlistName);
    if (playlistData != null && playlistData['videos'] is List) {
      setState(() {
        playlistVideos = List<String>.from(playlistData['videos']);
      });
    }
  }

  Future<void> _removeVideo(int index) async {
    final updatedVideos = List<String>.from(playlistVideos);
    final removedVideo = updatedVideos.removeAt(index);

    await widget.playlistVideosBox.put(widget.playlistName, {
      ...widget.playlistVideosBox.get(widget.playlistName) ?? {},
      'videos': updatedVideos,
      'updatedAt': DateTime.now().toString(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed video from ${widget.playlistName}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            updatedVideos.insert(index, removedVideo);
            await widget.playlistVideosBox.put(widget.playlistName, {
              ...widget.playlistVideosBox.get(widget.playlistName) ?? {},
              'videos': updatedVideos,
            });
            _loadPlaylistVideos();
          },
        ),
      ),
    );
    _loadPlaylistVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: buildAppBar(context, widget.playlistName, showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder(
          valueListenable: widget.playlistVideosBox.listenable(),
          builder: (context, Box box, _) {
            final playlistData = box.get(widget.playlistName);
            playlistVideos =
                playlistData != null && playlistData['videos'] is List
                ? List<String>.from(playlistData['videos'])
                : [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Videos in Playlist',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '(${playlistVideos.length})',
                      style: TextStyle(color: AppColors.grey, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: playlistVideos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.playlist_add,
                                size: 60,
                                color: AppColors.grey.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No videos in this playlist yet',
                                style: TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: playlistVideos.length,
                          itemBuilder: (context, index) {
                            final videoPath = playlistVideos[index];
                            final video = videosBox.values.firstWhere(
                              (v) => v.path == videoPath,
                              orElse: () => Video(
                                title: 'Unknown Title',
                                path: videoPath,
                              ),
                            );

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              color: AppColors.grey.withOpacity(0.1),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                leading: video.thumbnail != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.memory(
                                          video.thumbnail!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: AppColors.grey.withOpacity(
                                            0.3,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.video_library,
                                          color: AppColors.white,
                                        ),
                                      ),
                                title: Text(
                                  video.title,
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  video.duration != null 
                                      ? '${video.duration!.inMinutes}:${(video.duration!.inSeconds % 60).toString().padLeft(2, '0')}'
                                      : 'Unknown duration',
                                  style: TextStyle(color: AppColors.grey),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.play_arrow,
                                        color: AppColors.white,
                                      ),
                                      onPressed: () async {
                                        try {
                                          final allVideos = playlistVideos.map((path) {
                                            return videosBox.values.firstWhere(
                                              (v) => v.path == path,
                                              orElse: () => Video(title: 'Unknown', path: path),
                                            );
                                          }).toList();
                                          
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => VideoFullScreen(
                                                videos: allVideos,
                                                initialIndex: allVideos.indexOf(video),
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error playing video: $e')),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.remove_circle,
                                        color: AppColors.red,
                                      ),
                                      onPressed: () => _removeVideo(index),
                                    ),
                                  ],
                                ),
                                onTap: () async {
                                  try {
                                    final allVideos = playlistVideos.map((path) {
                                      return videosBox.values.firstWhere(
                                        (v) => v.path == path,
                                        orElse: () => Video(title: 'Unknown', path: path),
                                      );
                                    }).toList();
                                    
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VideoFullScreen(
                                          videos: allVideos,
                                          initialIndex: allVideos.indexOf(video),
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error playing video: $e')),
                                      );
                                    }
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    // TODO: Implement add videos to playlist functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add videos functionality coming soon')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Add New Videos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
     ),
);
}
} 