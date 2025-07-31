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
            icon: Icon(CupertinoIcons.back, color: AppColors.white),
            onPressed: () => Navigator.pop(context),
          )
        : null,
    title: Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        color: AppColors.white, // Force white text color
      ),
    ),
    actions: [
      IconButton(
        icon: Icon(Icons.search, color: AppColors.white), // Force white icon color
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