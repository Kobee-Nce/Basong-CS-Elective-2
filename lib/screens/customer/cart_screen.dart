import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatters.dart';
import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_providers.dart';
import '../../widgets/app_bar_actions.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/product_image.dart';
import '../../widgets/state_views.dart';

/// Cart: change quantities, remove items, running total + item count,
/// and the Checkout button.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  Future<void> _checkout(BuildContext context, WidgetRef ref) async {
    final placed = await ref.read(checkoutProvider.notifier).placeOrder();
    if (!context.mounted) return;

    if (placed != null) {
      context.go('/checkout/${placed.orderId}');
    } else {
      final error = ref.read(checkoutProvider).error;
      showMessage(
        context,
        error?.toString() ?? 'Checkout failed. Nothing was charged.',
        error: true,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final count = ref.watch(cartCountProvider);
    final total = ref.watch(cartTotalProvider);
    final checkout = ref.watch(checkoutProvider);
    final busy = checkout.isLoading;

    return GradientScaffold(
      title: const Text('Shopping Cart'),
      actions: const [AppBarActions()],
      body: items.isEmpty
          ? MessageView(
              icon: Icons.remove_shopping_cart_outlined,
              title: 'Your cart is empty',
              message: 'Add some game credits from the shop.',
              actionLabel: 'Browse the shop',
              onAction: () => context.go('/shop'),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _CartTile(item: items[index], disabled: busy),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .15),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      _row('Items', '$count', small: true),
                      const SizedBox(height: 6),
                      _row('Total', peso(total)),
                      const SizedBox(height: 4),
                      const Text(
                        'Prices and stock are confirmed by the shop at checkout.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: busy ? null : () => _checkout(context, ref),
                          icon: busy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.lock_rounded),
                          label: Text(
                            busy ? 'Placing order…' : 'Checkout',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _row(String label, String value, {bool small = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white, fontSize: small ? 17 : 20)),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: small ? 17 : 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _CartTile extends ConsumerWidget {
  final CartItem item;
  final bool disabled;

  const _CartTile({required this.item, required this.disabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartProvider.notifier);
    final product = item.product;
    final atMax = item.quantity >= product.stock;

    void show(String? error) {
      if (error != null) showMessage(context, error, error: true);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(width: 70, height: 70, child: ProductImage(product: product)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text('${peso(product.price)} • ${product.stock} in stock'),
                  Row(
                    children: [
                      IconButton(
                        tooltip: item.quantity == 1 ? 'Remove' : 'Decrease',
                        onPressed: disabled ? null : () => show(cart.decrement(product.id)),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('${item.quantity}', style: const TextStyle(fontSize: 18)),
                      IconButton(
                        tooltip: atMax ? 'No more stock' : 'Increase',
                        onPressed: disabled || atMax
                            ? null
                            : () => show(cart.increment(product.id)),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Remove from cart',
                  onPressed: disabled ? null : () => cart.remove(product.id),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
                Text(
                  peso(item.subtotal),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
