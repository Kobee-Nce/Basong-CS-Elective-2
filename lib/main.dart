import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Skipped while the placeholders are still in supabase_config.dart;
  // the home screen then shows a "not configured" message instead.
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

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