import 'package:hive/hive.dart';
import 'dart:typed_data';

class Video {
  final String title;
  final String path;
  final Duration? duration;
  final Uint8List? thumbnail;

  Video({
    required this.title, 
    required this.path, 
    this.duration, 
    this.thumbnail
  }) {
    if (path.isEmpty) {
      throw ArgumentError('Video path cannot be empty');
    }
  }

  Video copyWith({
    String? title, 
    String? path, 
    Duration? duration, 
    Uint8List? thumbnail
  }) {
   return Video(
    title: title ?? this.title,
    path: path ?? this.path,
    duration: duration ?? this.duration,
    thumbnail: thumbnail ?? this.thumbnail,
  );
  }

  Map<String, dynamic> toJson() => {
    'title': title, 
    'path': path, 
    'duration': duration?.inMilliseconds,
    'thumbnail': thumbnail?.toList(),
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
