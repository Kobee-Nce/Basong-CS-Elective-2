import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/game_credits.dart';
import '../main.dart';
import '../widgets/credit_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 600 ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Credits Shop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: () {
              GameCreditsApp.of(context).toggleTheme();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: credits.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: .72,
          ),
          itemBuilder: (context, index) {
            final item = credits[index];

            return CreditCard(
              credit: item,
              onTap: () => context.push('/detail/${item.id}'),
            );
          },
        ),
      ),
    );
  }
}