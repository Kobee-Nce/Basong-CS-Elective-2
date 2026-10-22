import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/pokedex_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: PokedexApp(),
    ),
  );
}

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const PokedexPage(),
    );
  }
}
