import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/order.dart';
import '../../providers/order_providers.dart';
import '../../widgets/app_bar_actions.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/order_card.dart';
import '../../widgets/state_views.dart';

/// The customer's own orders, newest first, with status, date, total
/// and items.
class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(myOrdersProvider);

    Future<void> refresh() async {
      ref.invalidate(myOrdersProvider);
      try {
        await ref.read(myOrdersProvider.future);
      } catch (_) {}
    }

    return GradientScaffold(
      title: const Text('My Orders'),
      actions: const [AppBarActions()],
      body: AsyncValueView<List<ShopOrder>>(
        value: orders,
        onRetry: refresh,
        isEmpty: (list) => list.isEmpty,
        empty: MessageView(
          icon: Icons.receipt_long_outlined,
          title: 'No orders yet',
          message: 'Orders you place will show up here.',
          actionLabel: 'Start shopping',
          onAction: () => context.go('/shop'),
        ),
        data: (list) => RefreshIndicator(
          onRefresh: refresh,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) => OrderCard(
              order: list[i],
              initiallyExpanded: i == 0,
            ),
          ),
        ),
      ),
    );
  }
}
