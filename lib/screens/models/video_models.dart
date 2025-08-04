import 'package:hive/hive.dart';
import 'dart:typed_data';

class Video {
  final String title;
  final String path;
  final Duration? duration;
  final Uint8List? thumbnail;
  final DateTime? playedAt;
  final int playcount;
  final bool isFavorite;

  Video({
    required this.title, 
    required this.path, 
    this.duration, 
    this.thumbnail,
    this.playedAt,
    this.playcount = 0,
    this.isFavorite = false,
  }) {
    if (path.isEmpty) {
      throw ArgumentError('Video path cannot be empty');
    }
  }

  Video copyWith({
    String? title, 
    String? path, 
    Duration? duration, 
    Uint8List? thumbnail,
    DateTime? playedAt,
    int? playcount,
    bool? isFavorite,
  }) {
   return Video(
    title: title ?? this.title,
    path: path ?? this.path,
    duration: duration ?? this.duration,
    thumbnail: thumbnail ?? this.thumbnail,
    playedAt: playedAt ?? this.playedAt,
    playcount: playcount ?? this.playcount,
    isFavorite: isFavorite ?? this.isFavorite,
  );
  }

  Map<String, dynamic> toJson() => {
    'title': title, 
    'path': path, 
    'duration': duration?.inMilliseconds,
    'thumbnail': thumbnail?.toList(),
    'playedAt': playedAt?.toIso8601String(),
    'playcount': playcount,
    'isFavorite': isFavorite,
  };

  static Video fromJson(Map<String, dynamic> json) {
    if (json['path'] == null || json['path'].isEmpty) {
      throw ArgumentError('Video path cannot be empty in JSON');
    }
    return Video(
      title: json['title'] ?? 'Unknown Title', 
      path: json['path'],
      duration: json['duration'] != null ? Duration(milliseconds: json['duration']) : null,
      thumbnail: json['thumbnail'] != null ? Uint8List.fromList(List<int>.from(json['thumbnail'])) : null,
      playedAt: json['playedAt'] != null ? DateTime.parse(json['playedAt']) : null,
      playcount: json['playcount'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}

class VideoAdapter extends TypeAdapter<Video> {
  @override
  final int typeId = 1;

  @override
  Video read(BinaryReader reader) {
    try {
      final json = reader.readMap();
      return Video.fromJson(Map<String, dynamic>.from(json));
    } catch (e) {
      print('Error reading Video from Hive: $e');
      rethrow;
    }
  }

  @override
  void write(BinaryWriter writer, Video obj) {
    try {
      writer.writeMap(obj.toJson());
    } catch (e) {
      print('Error writing Video to Hive: $e');
      rethrow;
    }
  }
}
