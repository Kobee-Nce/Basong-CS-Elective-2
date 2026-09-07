
import 'package:flutter/material.dart';

import 'router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const GameCreditsShop());
}

class GameCreditsShop extends StatefulWidget {
  const GameCreditsShop({super.key});

  static _GameCreditsShopState of(BuildContext context) =>
      context.findAncestorStateOfType<_GameCreditsShopState>()!;

  @override
  State<GameCreditsShop> createState() => _GameCreditsShopState();
}

class _GameCreditsShopState extends State<GameCreditsShop> {
  ThemeMode themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      themeMode = themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Game Credits Shop',

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      routerConfig: router,
    );
  }
}