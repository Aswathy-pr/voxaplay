import 'dart:typed_data';
import 'package:flutter/material.dart';

class Thumbnail extends StatelessWidget {
  final Uint8List? thumbnail;
  final double size;

  const Thumbnail({
    Key? key,
    required this.thumbnail,
    this.size = 50.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (thumbnail != null && thumbnail!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          thumbnail!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.video_library,
          size: 32,
          color: Colors.grey,
        ),
      );
    }
  }
} 