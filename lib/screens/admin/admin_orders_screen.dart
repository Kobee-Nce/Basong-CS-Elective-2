import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/order.dart';
import '../../providers/order_providers.dart';
import '../../widgets/app_bar_actions.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/order_card.dart';
import '../../widgets/state_views.dart';

/// Every customer's orders (admin). Admins can change an order's status.
class AdminOrdersScreen extends ConsumerWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(allOrdersProvider);
    final statusFilter = ref.watch(orderStatusFilterProvider);

    Future<void> refresh() async {
      ref.invalidate(allOrdersProvider);
      try {
        await ref.read(allOrdersProvider.future);
      } catch (_) {}
    }

    return GradientScaffold(
      title: const Text('All Orders'),
      actions: const [AppBarActions()],
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              children: [
                for (final status in <String?>[null, ...OrderStatus.all])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status == null ? 'All' : OrderStatus.label(status)),
                      selected: statusFilter == status,
                      onSelected: (_) =>
                          ref.read(orderStatusFilterProvider.notifier).set(status),
                      selectedColor: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: .15),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: statusFilter == status ? Colors.black87 : Colors.white,
                      ),
                      side: const BorderSide(color: Colors.white54),
                      showCheckmark: false,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: AsyncValueView<List<ShopOrder>>(
              value: orders,
              onRetry: refresh,
              isEmpty: (list) => list.isEmpty,
              empty: const MessageView(
                icon: Icons.receipt_long_outlined,
                title: 'No orders',
                message: 'Customer orders will appear here.',
              ),
              data: (list) => RefreshIndicator(
                onRefresh: refresh,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => OrderCard(
                    order: list[i],
                    showCustomer: true,
                    statusEditor: _StatusEditor(order: list[i]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusEditor extends ConsumerStatefulWidget {
  final ShopOrder order;

  const _StatusEditor({required this.order});

  @override
  ConsumerState<_StatusEditor> createState() => _StatusEditorState();
}

class _StatusEditorState extends ConsumerState<_StatusEditor> {
  bool _saving = false;

  Future<void> _change(String? status) async {
    if (status == null || status == widget.order.status) return;
    setState(() => _saving = true);
    try {
      await ref.read(orderActionsProvider).updateStatus(widget.order.id, status);
      if (mounted) showMessage(context, 'Status set to ${OrderStatus.label(status)}.');
    } catch (e) {
      if (mounted) showMessage(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Status: '),
        DropdownButton<String>(
          value: widget.order.status,
          onChanged: _saving ? null : _change,
          items: [
            for (final s in OrderStatus.all)
              DropdownMenuItem(value: s, child: Text(OrderStatus.label(s))),
          ],
        ),
        if (_saving)
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          ),
      ],
    );
  }
}
