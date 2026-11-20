import 'product.dart';

/// A product in the cart. Immutable: the cart provider replaces items.
class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  /// Display only — the real total is computed by the database at checkout.
  double get subtotal => product.price * quantity;

  CartItem copyWith({Product? product, int? quantity}) => CartItem(
        product: product ?? this.product,
        quantity: quantity ?? this.quantity,
      );
}
