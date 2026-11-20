import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/app_bar_actions.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/product_card.dart';
import '../../widgets/product_catalog.dart';

/// Customer product list: same list as the admin's, but each card only
/// has "Add to cart" — no add / edit / delete controls.
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuild cards when cart quantities change ("2 in cart").
    ref.watch(cartProvider);
    final cart = ref.read(cartProvider.notifier);

    void addToCart(Product product) {
      final error = cart.add(product);
      showMessage(
        context,
        error ?? '${product.name} added to cart.',
        error: error != null,
      );
    }

    return GradientScaffold(
      title: const Text('Game Credits Shop'),
      actions: const [AppBarActions()],
      body: ProductCatalog(
        cardBuilder: (context, product) => ProductCard(
          product: product,
          inCart: cart.quantityOf(product.id),
          onTap: () => context.push('/product/${product.id}', extra: product),
          onAddToCart: () => addToCart(product),
        ),
      ),
    );
  }
}
