import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicvoxaplay/screens/models/video_models.dart';
import 'package:musicvoxaplay/screens/playlist/video_terms/video_content_helper.dart';
import 'package:musicvoxaplay/screens/playlist/video_terms/widgets/video_playlist_grid_widget.dart';
import 'package:musicvoxaplay/screens/playlist/video_terms/widgets/video_playlist_management_buttons.dart';

class VideoContent extends StatefulWidget {
  final Video? currentVideo;
  const VideoContent({super.key, this.currentVideo});

  @override
  State<VideoContent> createState() => _VideoContentState();
}

class _VideoContentState extends State<VideoContent> {
  late final Box _playlistsBox;
  late final Box _playlistVideosBox;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeHiveBoxes();
  }

  Future<void> _initializeHiveBoxes() async {
    try {
      _playlistsBox = await Hive.openBox('videoPlaylistsBox');
      _playlistVideosBox = await Hive.openBox('videoPlaylistVideosBox');
      await VideoContentHelper.migrateOldPlaylistFormat(_playlistVideosBox);
    } catch (e) {
      debugPrint('Error initializing Hive boxes: $e');
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder(
                valueListenable: _playlistsBox.listenable(),
                builder: (context, Box box, _) {
                  final playlists = box.get('playlists', defaultValue: [])!;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Video Playlist Grid Widget
                      VideoPlaylistGridWidget(
                        playlists: playlists,
                        playlistVideosBox: _playlistVideosBox,
                      ),
                      
                      // Video Management Buttons Widget
                      VideoPlaylistManagementButtons(
                        playlistsBox: _playlistsBox,
                        playlistVideosBox: _playlistVideosBox,
                        currentVideo: widget.currentVideo,
                        onRefresh: () => setState(() {}),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _playlistsBox.close();
    _playlistVideosBox.close();
    super.dispose();
  }
}
