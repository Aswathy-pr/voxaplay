import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/audio/audiopage.dart';
import 'package:musicvoxaplay/screens/video/videopage.dart';
import 'package:musicvoxaplay/screens/playlist/playlist_tabs.dart';
import 'package:musicvoxaplay/screens/favourites/favourites.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';

Widget buildBottomNavigationBar({
  required int currentIndex,
  required Function(int) onTap,
  required BuildContext context, 
}) {
  return Container(
    height: 90, // Increase the height
    child: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.red,
      selectedItemColor: AppColors.black,
      unselectedItemColor: AppColors.white,
      currentIndex: currentIndex,
      onTap: (index) {
        onTap(index); 
    
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AudioPage()),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  VideoPage()),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  PlaylistPage()),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Favourites()),
            );
            break;
        }
      },
      iconSize: 30,
      selectedFontSize: 14,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(Icons.audio_file),
          ),
          label: 'audio',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(Icons.video_library),
          ),
          label: 'video',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(Icons.playlist_play),
          ),
          label: 'playlist',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Icon(Icons.favorite),
          ),
          label: 'favourites',
        ),
      ],
    ),
  );
}
