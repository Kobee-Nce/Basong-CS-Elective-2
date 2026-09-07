import 'game_credit.dart';

class CartItem {
  final GameCredit credit;
  int quantity;

  CartItem({
    required this.credit,
    this.quantity = 1,
  });

  double get subtotal => credit.price * quantity;
}