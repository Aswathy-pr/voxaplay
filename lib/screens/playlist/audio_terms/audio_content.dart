import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';
import 'package:musicvoxaplay/screens/playlist/audio_terms/audio_content_helper.dart';
import 'package:musicvoxaplay/screens/playlist/audio_terms/widgets/playlist_grid_widget.dart';
import 'package:musicvoxaplay/screens/playlist/audio_terms/widgets/playlist_management_buttons.dart';

class AudioContent extends StatefulWidget {
  final Song? currentSong;
  const AudioContent({super.key, this.currentSong});

  @override
  State<AudioContent> createState() => _AudioContentState();
}

class _AudioContentState extends State<AudioContent> {
  late final Box _playlistsBox;
  late final Box _playlistSongsBox;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeHiveBoxes();
  }

  Future<void> _initializeHiveBoxes() async {
    try {
      _playlistsBox = await Hive.openBox('playlistsBox');
      _playlistSongsBox = await Hive.openBox('playlistSongsBox');
      await AudioContentHelper.migrateOldPlaylistFormat(_playlistSongsBox);
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
                      // Playlist Grid Widget
                      PlaylistGridWidget(
                        playlists: playlists,
                        playlistSongsBox: _playlistSongsBox,
                      ),
                      
                      // Management Buttons Widget
                      PlaylistManagementButtons(
                        playlistsBox: _playlistsBox,
                        playlistSongsBox: _playlistSongsBox,
                        currentSong: widget.currentSong,
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
    _playlistSongsBox.close();
    super.dispose();
  }
}
