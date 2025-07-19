import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/search.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';
import 'package:musicvoxaplay/screens/theme_setup/theme_toggle_widget.dart';

PreferredSizeWidget buildAppBar(
  BuildContext context,
  String title, {
  PreferredSizeWidget? bottom,
  bool showBackButton = false,
}) {
  return AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: AppColors.red,
    leading: showBackButton
        ? IconButton(
            icon: const Icon(CupertinoIcons.back, color: AppColors.white),
            onPressed: () => Navigator.pop(context),
          )
        : null,
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.search, color: AppColors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Searchpage()),
          );
        },
      ),
      const ThemeToggleWidget(),
    ],
    bottom: bottom,
  );
}
