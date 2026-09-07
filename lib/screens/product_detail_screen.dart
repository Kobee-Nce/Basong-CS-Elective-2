import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/game_credit.dart';
import '../state/cart_controller.dart';
import '../theme/app_theme.dart';

class ProductDetailScreen extends StatelessWidget {
  final GameCredit credit;

  const ProductDetailScreen({
    super.key,
    required this.credit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final isSteam = credit.platform == 'Steam';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(),

      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.darkGradient
              : AppTheme.lightGradient,
        ),

        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Responsive portrait image
              Center(
                child: Hero(
                  tag: credit.id,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.55,
                      constraints: const BoxConstraints(
                        maxWidth: 220,
                        maxHeight: 300,
                      ),
                      color: Colors.black12,
                      child: AspectRatio(
                        aspectRatio: 4 / 5,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            credit.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: 110,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSteam
                      ? const Color(0xFF00ADFF)
                      : const Color(0xFFFF4654),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  credit.platform,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                credit.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                '₱${credit.price.toStringAsFixed(0)}',
                style: TextStyle(
                  color: isSteam
                      ? const Color(0xFF8EDBFF)
                      : const Color(0xFFFF9AA5),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  credit.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart),
                label: const Text(
                  'Add to Cart',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  CartController.instance.add(credit);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${credit.title} added to cart!',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                icon: const Icon(Icons.shopping_cart_checkout),
                label: const Text(
                  'Go to Cart',
                  style: TextStyle(fontSize: 18),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
                onPressed: () {
                  context.push('/cart');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}