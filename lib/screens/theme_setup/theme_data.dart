import 'package:flutter/material.dart';
import 'package:musicvoxaplay/screens/widgets/colors.dart';

// Define light theme
final ThemeData lightTheme = ThemeData(
  primarySwatch: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.red,
    foregroundColor: AppColors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black54),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
  ),
  iconTheme: const IconThemeData(
    color: Colors.black, // Icons will be black in light theme
  ),

  cardTheme: const CardThemeData(
    color: Colors.black ,
  )
);

// Define dark theme
final ThemeData darkTheme = ThemeData(
  primarySwatch: Colors.teal,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.red,
    foregroundColor: AppColors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    ),
  ),
  iconTheme: const IconThemeData(
    color: Colors.white, 
  ),
  cardTheme: const CardThemeData(
    color: Colors.red
  )
);