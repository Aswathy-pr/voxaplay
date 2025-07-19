import 'package:hive/hive.dart';

class Video {
  final String title;
  final String path;

  Video({required this.title, required this.path}) {
    if (path.isEmpty) {
      throw ArgumentError('Video path cannot be empty');
    }
  }

  Video copyWith({String? title, String? path}) {
   return Video(
    title: title ?? this.title,
    path: path ?? this.path,
  );
  }

  Map<String, dynamic> toJson() => {'title': title, 'path': path};

  static Video fromJson(Map<String, dynamic> json) {
    if (json['path'] == null || json['path'].isEmpty) {
      throw ArgumentError('Video path cannot be empty in JSON');
    }
    return Video(title: json['title'] ?? 'Unknown Title', path: json['path']);
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
