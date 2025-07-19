
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:musicvoxaplay/screens/splashscreen.dart';
import 'package:musicvoxaplay/screens/widgets/initialize_hive.dart';
import 'package:musicvoxaplay/screens/theme_setup/theme_data.dart';
import 'package:musicvoxaplay/screens/theme_setup/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await clearHiveData();
  // log('clear is done');
  await initializeHive();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeNotifier(lightTheme),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeNotifier.getTheme(),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
