import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/audio/audiopage.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  AudioPage ()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/download (1).jpg',
            fit: BoxFit.cover,
          ),
          Container(
            color: AppColors.black.withOpacity(0.1),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                       Text(
                    'VoxAplay..',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 500),
                   Text(
                    'your world of sounds and screens.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 40),

                  
                  RotationTransition(
                    turns: _controller,
                    child:  Icon(
                      Icons.sync,
                      color: AppColors.grey,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}