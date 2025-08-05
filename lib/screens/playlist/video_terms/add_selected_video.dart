import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicvoxaplay/screens/models/video_models.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';


class AddSelectedVideoPage extends StatefulWidget {
  final String playlistName;
  final Box playlistVideosBox;

  const AddSelectedVideoPage({
    super.key,
    required this.playlistName,
    required this.playlistVideosBox,
  });

  @override
  State<AddSelectedVideoPage> createState() => _AddSelectedVideoPageState();
}

class _AddSelectedVideoPageState extends State<AddSelectedVideoPage> {
  late Box<Video> videosBox;
  List<String> playlistVideos = [];
  bool showRecentlyPlayed = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    videosBox = Hive.box<Video>('videoBox');
    _loadPlaylistVideos();
  }

  void _loadPlaylistVideos() {
    final playlistData = widget.playlistVideosBox.get(widget.playlistName);
    if (playlistData != null && playlistData['videos'] != null) {
      setState(() {
        playlistVideos = List<String>.from(playlistData['videos'] ?? []);
      });
    }
  }

  List<Video> _filterVideos(List<Video> allVideos) {
    var filtered = allVideos.where(
      (video) => video.title.toLowerCase().contains(searchQuery.toLowerCase()),
    );

    if (showRecentlyPlayed) {
      filtered = filtered.where((video) => video.playedAt != null);
    }

    return filtered.toList();
  }

  Future<void> _toggleVideoInPlaylist(Video video) async {
    final playlistData =
        widget.playlistVideosBox.get(widget.playlistName) ?? {};
    final currentVideos = List<String>.from(playlistData['videos'] ?? []);

    setState(() {
      if (currentVideos.contains(video.path)) {
        currentVideos.remove(video.path);
      } else {
        currentVideos.add(video.path);
      }
    });

    await widget.playlistVideosBox.put(widget.playlistName, {
      ...playlistData,
      'videos': currentVideos,
      'updatedAt': DateTime.now().toIso8601String(),
    });

    _loadPlaylistVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: buildAppBar(
        context,
        'Add Videos to ${widget.playlistName}',
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search videos...',
                hintStyle: Theme.of(context).textTheme.bodyMedium,
                prefixIcon: Icon(Icons.search, color: Theme.of(context).textTheme.bodyLarge!.color),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Checkbox(
                  value: showRecentlyPlayed,
                  onChanged: (value) =>
                      setState(() => showRecentlyPlayed = value ?? false),
                  fillColor: MaterialStateProperty.resolveWith<Color>(
                    (states) => states.contains(MaterialState.selected)
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  checkColor: Theme.of(context).colorScheme.onPrimary,
                ),
                Text(
                  'Recently played',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                Text(
                  '${playlistVideos.length} videos in playlist',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ValueListenableBuilder(
                valueListenable: videosBox.listenable(),
                builder: (context, Box<Video> box, _) {
                  final allVideos = box.values.toList();
                  final displayedVideos = _filterVideos(allVideos);

                  return displayedVideos.isEmpty
                      ? Center(
                          child: Text(
                            searchQuery.isEmpty
                                ? 'No videos available'
                                : 'No matching videos found',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      : ListView.builder(
                          itemCount: displayedVideos.length,
                          itemBuilder: (context, index) {
                            final video = displayedVideos[index];
                            final isInPlaylist = playlistVideos.contains(
                              video.path,
                            );

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
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
                                          color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Icon(
                                          Icons.video_library,
                                          color: Theme.of(context).textTheme.bodyLarge!.color,
                                        ),
                                      ),
                                title: Text(
                                  video.title,
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                subtitle: Text(
                                  video.duration != null
                                      ? '${video.duration!.inMinutes}:${(video.duration!.inSeconds % 60).toString().padLeft(2, '0')}'
                                      : 'Unknown duration',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    isInPlaylist ? Icons.check : Icons.add,
                                    color: isInPlaylist
                                        ? Theme.of(context).textTheme.bodyLarge!.color
                                        : Theme.of(context).colorScheme.primary,
                                    size: 24,
                                  ),
                                  onPressed: () => _toggleVideoInPlaylist(video),
                                ),
                              ),
                            );
                          },
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}