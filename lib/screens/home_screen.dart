import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/game_credits.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import '../widgets/credit_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 700 ? 3 : 2;

    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: const Text('Game Credits Shop'),

        actions: [
          IconButton(
            onPressed: () {
              GameCreditsShop.of(context).toggleTheme();
            },
            icon: Icon(
              isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
          ),

          IconButton(
            onPressed: () {
              context.push('/cart');
            },
            icon: const Icon(Icons.shopping_cart),
          ),
        ],
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.darkGradient
              : AppTheme.lightGradient,
        ),

        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),

              const Text(
                'Steam • Valorant',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Official Game Credits',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),

                  itemCount: credits.length,

                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: .72,
                  ),

                  itemBuilder: (context, index) {
                    final item = credits[index];

                    return CreditCard(
                      credit: item,
                      onTap: () {
                        context.push('/detail/${item.id}');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}