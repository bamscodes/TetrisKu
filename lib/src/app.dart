import 'package:flutter/material.dart';
import 'menu/main_menu.dart';

class TetrisApp extends StatelessWidget {
  const TetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seedColor = Colors.deepOrange;
    return MaterialApp(
      title: 'Tetrisku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seedColor,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seedColor,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const MainMenu(),
    );
  }
}