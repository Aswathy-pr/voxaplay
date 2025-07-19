import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_data.dart';
import 'theme_notifier.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';


class ThemeToggleWidget extends StatelessWidget {
  const ThemeToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return IconButton(
      icon: Icon(
        themeNotifier.getTheme() == lightTheme ? Icons.dark_mode : Icons.light_mode,
        color: AppColors.white,
      ),
      tooltip: 'Toggle Theme',
      onPressed: () {
        themeNotifier.setTheme(
          themeNotifier.getTheme() == lightTheme ? darkTheme : lightTheme,
        );
      },
    );
  }
}