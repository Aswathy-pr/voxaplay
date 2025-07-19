import 'package:flutter/material.dart';

class PlaylistRowWidget extends StatelessWidget {
  final BoxConstraints constraints;
  final List<Widget> children;

  const PlaylistRowWidget({
    super.key,
    required this.constraints,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: constraints.maxWidth),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
  }
}