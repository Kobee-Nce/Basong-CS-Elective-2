import 'package:flutter/material.dart';

import 'router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const GameCreditsApp());
}

class GameCreditsApp extends StatefulWidget {
  const GameCreditsApp({super.key});

  static _GameCreditsAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_GameCreditsAppState>()!;

  @override
  State<GameCreditsApp> createState() => _GameCreditsAppState();
}

class _GameCreditsAppState extends State<GameCreditsApp> {
  ThemeMode mode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      mode = mode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Game Credits Shop',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      routerConfig: router,
    );
  }
}