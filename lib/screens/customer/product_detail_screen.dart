import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatters.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/product_image.dart';
import '../../widgets/state_views.dart';

/// Product details (customer). Opened from the shop with the product
/// already loaded, or by URL, in which case it is fetched by id.
class ProductDetailScreen extends ConsumerWidget {
  final int productId;
  final Product? initial;

  const ProductDetailScreen({super.key, required this.productId, this.initial});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (initial != null) {
      return GradientScaffold(body: _Details(product: initial!));
    }

    final product = ref.watch(productByIdProvider(productId));
    return GradientScaffold(
      body: AsyncValueView<Product>(
        value: product,
        onRetry: () => ref.invalidate(productByIdProvider(productId)),
        data: (p) => _Details(product: p),
      ),
    );
  }
}

class _Details extends ConsumerWidget {
  final Product product;

  const _Details({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(cartProvider);
    final cart = ref.read(cartProvider.notifier);
    final inCart = cart.quantityOf(product.id);
    final accent = AppTheme.accentFor(product.categoryName);
    final canAdd = product.inStock && inCart < product.stock;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Hero(
            tag: 'product-${product.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 240, maxHeight: 300),
                color: Colors.black12,
                child: AspectRatio(
                  aspectRatio: 4 / 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ProductImage(product: product),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            if (product.categoryName != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  product.categoryName!,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            const Spacer(),
            Text(
              product.inStock ? '${product.stock} in stock' : 'Out of stock',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          product.name,
          style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          peso(product.price),
          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 18),
        GlassPanel(
          child: Text(
            (product.description ?? '').isEmpty ? 'No description.' : product.description!,
            style: const TextStyle(color: Colors.white, fontSize: 17, height: 1.5),
          ),
        ),
        const SizedBox(height: 26),
        ElevatedButton.icon(
          icon: const Icon(Icons.add_shopping_cart_rounded),
          label: Text(
            !product.inStock
                ? 'Out of stock'
                : !canAdd
                    ? 'All available stock is in your cart'
                    : inCart > 0
                        ? 'Add another ($inCart in cart)'
                        : 'Add to cart',
          ),
          onPressed: canAdd
              ? () {
                  final error = cart.add(product);
                  showMessage(
                    context,
                    error ?? '${product.name} added to cart!',
                    error: error != null,
                  );
                }
              : null,
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.shopping_cart_checkout_rounded),
          label: const Text('Go to cart', style: TextStyle(fontSize: 17)),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white),
          ),
          onPressed: () => context.go('/cart'),
        ),
      ],
    );
  }
}
