import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicvoxaplay/screens/models/video_models.dart';
import 'package:musicvoxaplay/screens/services/video_service.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';

class AddFavoriteVideosPage extends StatefulWidget {
  final VideoService videoService;

  const AddFavoriteVideosPage({super.key, required this.videoService});

  @override
  State<AddFavoriteVideosPage> createState() => _AddFavoriteVideosPageState();
}

class _AddFavoriteVideosPageState extends State<AddFavoriteVideosPage> {
  late Box<Video> videosBox;
  bool showRecentlyPlayed = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    videosBox = Hive.box<Video>('videoBox');
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

  Future<void> _toggleFavorite(Video video) async {
    try {
      setState(() {
  
      });
      await widget.videoService.updateFavoriteStatus(video);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            video.isFavorite ? 'Added to Favorites' : 'Removed from Favorites',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          backgroundColor: Colors.red[900],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating favorite: $e'),
          backgroundColor: Colors.red[900],
        ),
      );
      setState(() {
        
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: buildAppBar(
        context,
        'Add Videos to Favorites',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search videos...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surface.withOpacity(0.2),
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
                    onChanged: (value) {
                      setState(() {
                        showRecentlyPlayed = value ?? false;
                      });
                    },
                    fillColor: MaterialStateProperty.resolveWith<Color>(
                      (states) => states.contains(MaterialState.selected)
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    checkColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  Text(
                    'Recently played',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const Spacer(),
                  ValueListenableBuilder(
                    valueListenable: videosBox.listenable(),
                    builder: (context, Box<Video> box, _) {
                      final favoriteCount = box.values
                          .where((video) => video.isFavorite)
                          .length;
                      return Text(
                        '$favoriteCount videos in favorites',
                        style: Theme.of(context).textTheme.bodyMedium,
                      );
                    },
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
                            clipBehavior: Clip.hardEdge,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: displayedVideos.length,
                            itemBuilder: (context, index) {
                              final video = displayedVideos[index];
                              final isInFavorites = video.isFavorite;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                color: Theme.of(
                                  context,
                                ).colorScheme.surface.withOpacity(0.1),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  leading:
                                      video.thumbnail != null &&
                                          video.thumbnail!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
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
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface
                                                .withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.video_library,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge!.color,
                                          ),
                                        ),
                                  title: Text(
                                    video.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        video.duration != null
                                            ? '${video.duration!.inMinutes}:${(video.duration!.inSeconds % 60).toString().padLeft(2, '0')}'
                                            : 'Unknown duration',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                      if (video.playedAt != null)
                                        Text(
                                          'Played ${video.playedAt!.toString().split(' ')[0]}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.8),
                                                fontSize: 12,
                                              ),
                                        ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      isInFavorites
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isInFavorites
                                          ? AppColors.red
                                          : Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      size: 24,
                                    ),
                                    onPressed: () => _toggleFavorite(video),
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
      ),
    );
  }
}
