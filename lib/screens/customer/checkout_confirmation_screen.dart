import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatters.dart';
import '../../models/order.dart';
import '../../providers/order_providers.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/state_views.dart';

/// Shown after checkout: order number, total and items — all read back
/// from the database, not from the cart.
class CheckoutConfirmationScreen extends ConsumerWidget {
  final int orderId;

  const CheckoutConfirmationScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderByIdProvider(orderId));

    return GradientScaffold(
      showAppBar: false,
      body: AsyncValueView<ShopOrder>(
        value: order,
        onRetry: () => ref.invalidate(orderByIdProvider(orderId)),
        data: (o) => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 100),
                  const SizedBox(height: 14),
                  const Text(
                    'Order placed!',
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Order ${orderNumber(o.id)} • ${OrderStatus.label(o.status)}',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Text(
                    formatDateTime(o.createdAt),
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  GlassPanel(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'ORDER SUMMARY',
                            style: TextStyle(
                              color: Colors.white70,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (final item in o.items)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.productName}\n${item.quantity} × ${peso(item.unitPrice)}',
                                    style: const TextStyle(color: Colors.white, fontSize: 15),
                                  ),
                                ),
                                Text(
                                  peso(item.subtotal),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const Divider(color: Colors.white30, height: 26),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total (${o.itemCount} item${o.itemCount == 1 ? '' : 's'})',
                              style: const TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            Text(
                              peso(o.total),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.storefront_rounded),
                      label: const Text('Continue shopping', style: TextStyle(fontSize: 18)),
                      onPressed: () => context.go('/shop'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    onPressed: () => context.go('/orders'),
                    child: const Text('View my orders', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
