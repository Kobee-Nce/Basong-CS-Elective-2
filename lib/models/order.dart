/// Order statuses allowed by the `orders.status` check constraint.
class OrderStatus {
  static const pending = 'pending';
  static const done = 'done';
  static const cancelled = 'cancelled';

  static const all = [pending, done, cancelled];

  static String label(String status) => switch (status) {
        pending => 'Pending',
        done => 'Done',
        cancelled => 'Cancelled',
        _ => status,
      };
}

/// A row of `order_items`. Name and unit price are the snapshot saved at
/// checkout, so they stay correct after price changes or deletes.
class OrderItem {
  final int id;
  final int? productId;
  final String productName;
  final double unitPrice;
  final int quantity;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  double get subtotal => unitPrice * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
        id: (map['id'] as num).toInt(),
        productId: (map['product_id'] as num?)?.toInt(),
        productName: map['product_name'] as String? ?? 'Removed product',
        unitPrice: (map['unit_price'] as num).toDouble(),
        quantity: (map['quantity'] as num).toInt(),
      );
}

/// A row of `orders` with its items.
class ShopOrder {
  final int id;
  final String userId;
  final String status;
  final double total;
  final DateTime createdAt;
  final List<OrderItem> items;

  /// Filled in for the admin order list (from `profiles`).
  final String? customerName;
  final String? customerEmail;

  const ShopOrder({
    required this.id,
    required this.userId,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.items,
    this.customerName,
    this.customerEmail,
  });

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  /// Expects `select('*, order_items(*)')`.
  factory ShopOrder.fromMap(Map<String, dynamic> map) {
    final items = (map['order_items'] as List<dynamic>? ?? [])
        .map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    return ShopOrder(
      id: (map['id'] as num).toInt(),
      userId: map['user_id'] as String,
      status: map['status'] as String? ?? OrderStatus.pending,
      total: (map['total'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      items: items,
    );
  }

  ShopOrder withCustomer({String? name, String? email}) => ShopOrder(
        id: id,
        userId: userId,
        status: status,
        total: total,
        createdAt: createdAt,
        items: items,
        customerName: name,
        customerEmail: email,
      );
}

/// What `place_order()` returns.
class PlacedOrder {
  final int orderId;
  final double total;
  final String status;

  const PlacedOrder({
    required this.orderId,
    required this.total,
    required this.status,
  });

  factory PlacedOrder.fromMap(Map<String, dynamic> map) => PlacedOrder(
        orderId: (map['order_id'] as num).toInt(),
        total: (map['total'] as num).toDouble(),
        status: map['status'] as String,
      );
}
