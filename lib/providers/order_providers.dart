import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import 'auth_providers.dart';
import 'cart_provider.dart';
import 'product_providers.dart';
import 'service_providers.dart';

// ------------------------------------------------------------------
// Customer
// ------------------------------------------------------------------

/// The signed-in customer's orders, newest first.
final myOrdersProvider = FutureProvider<List<ShopOrder>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const [];
  final service = ref.watch(orderServiceProvider);
  return service.fetchMyOrders(userId);
});

/// One order (checkout confirmation).
final orderByIdProvider =
    FutureProvider.autoDispose.family<ShopOrder, int>((ref, id) {
  return ref.watch(orderServiceProvider).fetchOrder(id);
});

/// Checkout: loading / error / the placed order.
class CheckoutNotifier extends Notifier<AsyncValue<PlacedOrder?>> {
  @override
  AsyncValue<PlacedOrder?> build() => const AsyncData(null);

  /// Returns the placed order, or null when it failed (see [state]).
  Future<PlacedOrder?> placeOrder() async {
    final items = ref.read(cartProvider);

    state = const AsyncLoading();
    final result = await AsyncValue.guard<PlacedOrder?>(
      () => ref.read(orderServiceProvider).placeOrder(items),
    );
    state = result;

    // Stock changed (or turned out to be lower) either way.
    ref.invalidate(productsPageProvider);

    final placed = result.value;
    if (result.hasError || placed == null) return null;

    ref.read(cartProvider.notifier).clear();
    ref.invalidate(myOrdersProvider);
    return placed;
  }

  void reset() => state = const AsyncData(null);
}

final checkoutProvider =
    NotifierProvider<CheckoutNotifier, AsyncValue<PlacedOrder?>>(
  CheckoutNotifier.new,
);

// ------------------------------------------------------------------
// Admin
// ------------------------------------------------------------------

/// Status filter on the admin order list (null = all).
class OrderStatusFilter extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? status) => state = status;
}

final orderStatusFilterProvider =
    NotifierProvider<OrderStatusFilter, String?>(OrderStatusFilter.new);

/// Every order (admin), newest first.
final allOrdersProvider = FutureProvider<List<ShopOrder>>((ref) {
  ref.watch(currentUserIdProvider); // refetch for a newly signed-in admin
  final status = ref.watch(orderStatusFilterProvider);
  return ref.watch(orderServiceProvider).fetchAllOrders(status: status);
});

class OrderActions {
  OrderActions(this._ref);

  final Ref _ref;

  Future<void> updateStatus(int orderId, String status) async {
    await _ref.read(orderServiceProvider).updateStatus(orderId, status);
    _ref.invalidate(allOrdersProvider);
  }
}

final orderActionsProvider = Provider<OrderActions>(
  (ref) => OrderActions(ref),
);
