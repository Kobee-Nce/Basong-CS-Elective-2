import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_exception.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import 'profile_service.dart';
import 'supabase_errors.dart';

/// Checkout and order history.
class OrderService {
  OrderService(this._client, this._profiles);

  final SupabaseClient _client;
  final ProfileService _profiles;

  static const _columns = '*, order_items(*)';

  /// Checkout. Sends ONLY product ids and quantities to the
  /// `place_order` database function, which reads names, prices and
  /// stock itself, reduces stock, saves the order + items, and sets the
  /// status to 'done' — all in one transaction (all or nothing).
  Future<PlacedOrder> placeOrder(List<CartItem> items) {
    return guard(() async {
      if (items.isEmpty) {
        throw const AppException('Your cart is empty.', AppErrorKind.validation);
      }
      final result = await _client.rpc(
        'place_order',
        params: {
          'p_items': [
            for (final item in items)
              {'product_id': item.product.id, 'quantity': item.quantity},
          ],
        },
      );
      return PlacedOrder.fromMap(Map<String, dynamic>.from(result as Map));
    });
  }

  /// The signed-in customer's orders, newest first.
  /// (RLS already limits customers to their own rows; the filter makes
  /// the intent explicit.)
  Future<List<ShopOrder>> fetchMyOrders(String userId) {
    return guard(() async {
      final rows = await _client
          .from('orders')
          .select(_columns)
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return rows.map(ShopOrder.fromMap).toList();
    });
  }

  Future<ShopOrder> fetchOrder(int id) {
    return guard(() async {
      final row = await _client
          .from('orders')
          .select(_columns)
          .eq('id', id)
          .maybeSingle();
      if (row == null) {
        throw const AppException('Order not found.', AppErrorKind.notFound);
      }
      return ShopOrder.fromMap(row);
    });
  }

  /// Every order (admin), newest first, with the customer's name/email.
  Future<List<ShopOrder>> fetchAllOrders({String? status}) {
    return guard(() async {
      var query = _client.from('orders').select(_columns);
      if (status != null) query = query.eq('status', status);
      final rows = await query.order('created_at', ascending: false);
      final orders = rows.map(ShopOrder.fromMap).toList();

      final contacts = await _profiles.fetchContactInfo(
        orders.map((o) => o.userId).toSet().toList(),
      );

      return [
        for (final order in orders)
          order.withCustomer(
            name: _name(contacts[order.userId]),
            email: contacts[order.userId]?['email'] as String?,
          ),
      ];
    });
  }

  /// Admin only (RLS + column grant: status is the only editable column).
  Future<void> updateStatus(int orderId, String status) {
    return guard(() async {
      final rows = await _client
          .from('orders')
          .update({'status': status})
          .eq('id', orderId)
          .select('id');
      if (rows.isEmpty) {
        throw const AppException(
          "The status wasn't changed. You may not have permission.",
          AppErrorKind.permissionDenied,
        );
      }
    });
  }

  static String? _name(Map<String, dynamic>? row) {
    if (row == null) return null;
    final name = [row['firstname'], row['lastname']]
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .join(' ');
    return name.isEmpty ? null : name;
  }
}
