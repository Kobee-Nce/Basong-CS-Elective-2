import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/product.dart';
import '../../providers/product_providers.dart';
import '../../widgets/app_bar_actions.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/product_card.dart';
import '../../widgets/product_catalog.dart';

/// Admin product list: FAB → Add Product form, Edit & Delete on each card.
class AdminProductsScreen extends ConsumerWidget {
  const AdminProductsScreen({super.key});

  Future<void> _delete(BuildContext context, WidgetRef ref, Product product) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Delete product?',
      message: 'Delete "${product.name}"? This cannot be undone. '
          'Past orders keep their copy of the name and price.',
    );
    if (!confirmed || !context.mounted) return;

    try {
      await ref.read(productActionsProvider).delete(product);
      if (context.mounted) showMessage(context, '"${product.name}" deleted.');
    } catch (e) {
      if (context.mounted) showMessage(context, e.toString(), error: true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GradientScaffold(
      title: const Text('Manage Products'),
      actions: const [AppBarActions()],
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-product',
        onPressed: () => context.push('/admin/products/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add product'),
      ),
      body: ProductCatalog(
        bottomPadding: 80,
        cardBuilder: (context, product) => ProductCard(
          product: product,
          onTap: () => context.push('/admin/products/${product.id}/edit', extra: product),
          onEdit: () => context.push('/admin/products/${product.id}/edit', extra: product),
          onDelete: () => _delete(context, ref, product),
        ),
      ),
    );
  }
}
