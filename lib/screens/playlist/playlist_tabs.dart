import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';
import 'package:musicvoxaplay/screens/widgets/bottom_navigationbar.dart';
import 'package:musicvoxaplay/screens/playlist/audio_terms/audio_content.dart'; 
import 'package:musicvoxaplay/screens/playlist/video_terms/video_content.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  int _currentIndex = 2;

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: buildAppBar(
          context,
          'Playlists' ,showBackButton: true,
          bottom: const TabBar(
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.white,
            indicatorColor: AppColors.white,
            labelStyle: TextStyle(
              fontSize: 20,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 18,
            ),
            tabs: [
              Tab(text: 'Audio'),
              Tab(text: 'Video'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AudioContent(), 
            VideoContent(),
          ],
        ),
        bottomNavigationBar: buildBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
          context: context,
        ),
      ),
    );
  }
}   



