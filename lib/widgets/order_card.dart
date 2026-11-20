import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/order.dart';
import '../theme/app_theme.dart';

/// One order with status, date, total and items. Used by the customer
/// order history and the admin order list ([statusEditor] for admins).
class OrderCard extends StatelessWidget {
  final ShopOrder order;
  final bool showCustomer;
  final Widget? statusEditor;
  final bool initiallyExpanded;

  const OrderCard({
    super.key,
    required this.order,
    this.showCustomer = false,
    this.statusEditor,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final hint = Theme.of(context).hintColor;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Row(
          children: [
            Text(
              'Order ${orderNumber(order.id)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(width: 8),
            StatusChip(status: order.status),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formatDateTime(order.createdAt), style: TextStyle(color: hint)),
            if (showCustomer)
              Text(
                [order.customerName, order.customerEmail]
                    .whereType<String>()
                    .join(' • ')
                    .ifEmpty('Unknown customer'),
                style: TextStyle(color: hint),
              ),
            Text(
              '${order.itemCount} item${order.itemCount == 1 ? '' : 's'} • ${peso(order.total)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        children: [
          const Divider(height: 1),
          for (final item in order.items)
            ListTile(
              dense: true,
              title: Text(
                item.productName,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              subtitle: Text('${item.quantity} × ${peso(item.unitPrice)}'),
              trailing: Text(
                peso(item.subtotal),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                if (statusEditor != null) statusEditor!,
                const Spacer(),
                const Text('Total  ', style: TextStyle(fontSize: 16)),
                Text(
                  peso(order.total),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      OrderStatus.done => AppTheme.success,
      OrderStatus.cancelled => AppTheme.valorantRed,
      _ => Colors.orange.shade700,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .15),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        OrderStatus.label(status),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
