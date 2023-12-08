import 'package:flutter/material.dart';

ThemeData myTheme = ThemeData(
    primaryColor: Colors.black54,
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal));

ThemeData lightMode = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
        background: Colors.grey.shade200,
        primary: Colors.grey.shade800,
        secondary: Colors.grey.shade300),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade800,
        foregroundColor: Colors.white,
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: Colors.grey.shade100,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16.0,
        color: Color.fromARGB(255, 54, 54, 54),
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14.0,
        color: Color.fromARGB(255, 54, 54, 54),
      ),
    ),
    bottomAppBarTheme: BottomAppBarTheme(
      color: Colors.grey.shade300,
    ));

ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
        background: Colors.grey.shade900,
        primary: Colors.grey.shade200,
        secondary: Colors.grey.shade800),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black12,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade700,
          foregroundColor: Colors.white70),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: Colors.grey.shade800,
    ),
    cardTheme: CardTheme(
      color: Colors.grey.shade800,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16.0,
        color: Color.fromARGB(255, 237, 237, 237),
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14.0,
        color: Color.fromARGB(255, 237, 237, 237),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Colors.white70)),
    bottomAppBarTheme: BottomAppBarTheme(
      color: Colors.grey.shade800,
    ));
