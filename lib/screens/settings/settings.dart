import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/settings/privacy_policy.dart';
import 'package:musicvoxaplay/screens/settings/about_app.dart';
import 'package:musicvoxaplay/screens/widgets/appbar.dart';
import 'package:musicvoxaplay/screens/widgets/bottom_navigationbar.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  int _currentIndex = 4;

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: buildAppBar(context, 'Settings', showBackButton: true),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header Section
         
          const SizedBox(height: 20),

          // About App Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: Colors.grey,
            child: ListTile(
              leading: Icon(Icons.info_outline, color: AppColors.red),
              title: Text(
                'About App',
                style: TextStyle(color: Colors.black)
              ),
              trailing: Icon(Icons.chevron_right, color: AppColors.white),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AboutApp())),
            ),
          ),
          const SizedBox(height: 10),

          // Privacy Policy Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color:Colors.grey,
            child: ListTile(
              leading: Icon(Icons.privacy_tip, color: AppColors.red),
              title: Text(
                'Privacy Policy',
                style: TextStyle(color: Colors.black)
              ),
              trailing: Icon(Icons.chevron_right, color: AppColors.white),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicy())),
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        context: context,
      ),
    );
  }
}