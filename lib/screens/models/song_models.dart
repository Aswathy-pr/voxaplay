import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';

class Song {
  final String title;
  final String artist;
  final Uint8List? artwork;
  final String path;
  bool isFavorite;
  final DateTime? playedAt;
  int playcount;

  Song(
    this.title,
    this.artist,
    this.path, {
    this.artwork,
    this.isFavorite = false,
    this.playedAt,
    this.playcount = 0,
  }) {
    if (path.isEmpty) {
      throw ArgumentError('Song path cannot be empty');
    }
  }

  Song copyWith({
    String? title,
    String? artist,
    String? path,
    Uint8List? artwork,
    bool? isFavorite,
    DateTime? playedAt,
    int? playcount,
  }) {
    return Song(
      title ?? this.title,
      artist ?? this.artist,
      path ?? this.path,
      artwork: artwork ?? this.artwork,
      isFavorite: isFavorite ?? this.isFavorite,
      playedAt: playedAt ?? this.playedAt,
      playcount: playcount ?? this.playcount,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'artist': artist,
        'artwork': artwork,
        'path': path,
        'playedAt': playedAt?.toIso8601String(),
        'isFavorite': isFavorite,
        'playcount': playcount,
      };

  static Song fromJson(Map<String, dynamic> json) {
    if (json['path'] == null || json['path'].isEmpty) {
      throw ArgumentError('Song path cannot be empty in JSON');
    }
    return Song(
      json['title'] ?? 'Unknown Title',
      json['artist'] ?? 'Unknown Artist',
      json['path'],
      artwork: json['artwork'] != null
          ? Uint8List.fromList(List<int>.from(json['artwork']))
          : null,
      isFavorite: json['isFavorite'] ?? false,
      playedAt: json['playedAt'] != null
          ? DateTime.tryParse(json['playedAt'])
          : null,
      playcount: json['playcount'] ?? 0, 
    );
  }
}

class SongAdapter extends TypeAdapter<Song> {
  @override
  final int typeId = 0;

  @override
  Song read(BinaryReader reader) {
    try {
      final json = reader.readMap();
      return Song.fromJson(Map<String, dynamic>.from(json));
    } catch (e) {
      print('Error reading Song from Hive: $e');
      rethrow;
    }
  }

  @override
  void write(BinaryWriter writer, Song obj) {
    try {
      writer.writeMap(obj.toJson());
    } catch (e) {
      print('Error writing Song to Hive: $e');
      rethrow;
    }
  }
}