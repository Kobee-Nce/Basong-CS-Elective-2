import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/game_credit.dart';

class CartController extends ChangeNotifier {
  static final CartController instance = CartController._();

  CartController._();

  final List<CartItem> items = [];

  void add(GameCredit credit) {
    final existing = items.where((e) => e.credit.id == credit.id);

    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      items.add(CartItem(credit: credit));
    }

    notifyListeners();
  }

  void increase(CartItem item) {
    item.quantity++;
    notifyListeners();
  }

  void decrease(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      items.remove(item);
    }

    notifyListeners();
  }

  void remove(CartItem item) {
    items.remove(item);
    notifyListeners();
  }

  double get total =>
      items.fold(0, (sum, item) => sum + item.subtotal);

  int get totalItems =>
      items.fold(0, (sum, item) => sum + item.quantity);

  void clear() {
    items.clear();
    notifyListeners();
  }
}