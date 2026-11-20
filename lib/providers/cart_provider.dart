import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import 'auth_providers.dart';

/// The cart, held in app state (not autoDispose), so it survives screen
/// changes. Emptied after a successful order and on logout.
///
/// Methods that can be refused return an error message (or null when
/// they succeeded) so the screen can show it.
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    // Signing out (or in as someone else) empties the cart.
    ref.listen<String?>(currentUserIdProvider, (previous, next) {
      if (previous != next) state = const [];
    });
    return const [];
  }

  int quantityOf(int productId) {
    for (final item in state) {
      if (item.product.id == productId) return item.quantity;
    }
    return 0;
  }

  String? add(Product product, {int quantity = 1}) {
    if (!product.inStock) return '${product.name} is out of stock.';

    final current = quantityOf(product.id);
    if (current + quantity > product.stock) {
      return 'Only ${product.stock} of ${product.name} in stock '
          '(you have $current in your cart).';
    }

    if (current == 0) {
      state = [...state, CartItem(product: product, quantity: quantity)];
    } else {
      state = [
        for (final item in state)
          if (item.product.id == product.id)
            item.copyWith(product: product, quantity: current + quantity)
          else
            item,
      ];
    }
    return null;
  }

  /// 0 or less removes the item. Above the stock is refused.
  String? setQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      remove(productId);
      return null;
    }

    final index = state.indexWhere((i) => i.product.id == productId);
    if (index < 0) return null;

    final product = state[index].product;
    if (quantity > product.stock) {
      return 'Only ${product.stock} of ${product.name} in stock.';
    }

    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: quantity)
        else
          item,
    ];
    return null;
  }

  String? increment(int productId) =>
      setQuantity(productId, quantityOf(productId) + 1);

  String? decrement(int productId) =>
      setQuantity(productId, quantityOf(productId) - 1);

  void remove(int productId) {
    state = [
      for (final item in state)
        if (item.product.id != productId) item,
    ];
  }

  void clear() => state = const [];
}

final cartProvider =
    NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

/// Number of units in the cart (badge + summary).
final cartCountProvider = Provider<int>(
  (ref) => ref.watch(cartProvider).fold(0, (sum, i) => sum + i.quantity),
);

/// Running total shown in the cart. The amount actually charged is
/// computed by the database at checkout.
final cartTotalProvider = Provider<double>(
  (ref) => ref.watch(cartProvider).fold(0.0, (sum, i) => sum + i.subtotal),
);
