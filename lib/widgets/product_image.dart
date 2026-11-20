import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_theme.dart';

/// A product's picture: uploaded image (Supabase Storage URL), bundled
/// asset (the original PrelimExam items), or a generated card.
class ProductImage extends StatelessWidget {
  final Product product;
  final BoxFit fit;

  const ProductImage({super.key, required this.product, this.fit = BoxFit.contain});

  @override
  Widget build(BuildContext context) {
    final url = product.imageUrl;
    final placeholder = _Placeholder(product);

    if (url == null || url.isEmpty) return placeholder;

    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: fit,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorBuilder: (context, error, stackTrace) => placeholder,
      );
    }

    return Image.asset(
      url,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }
}

class _Placeholder extends StatelessWidget {
  final Product product;

  const _Placeholder(this.product);

  @override
  Widget build(BuildContext context) {
    final isValorant =
        (product.categoryName ?? '').toLowerCase().contains('valorant');

    final colors = isValorant
        ? const [AppTheme.valorantDark, AppTheme.valorantRed]
        : const [AppTheme.steamDark, AppTheme.steamBlue];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isValorant ? Icons.diamond_rounded : Icons.sports_esports_rounded,
                  color: Colors.white,
                  size: 36,
                ),
                const SizedBox(height: 6),
                Text(
                  product.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  (product.categoryName ?? '').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
