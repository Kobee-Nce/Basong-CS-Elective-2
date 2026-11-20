import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/core/formatters.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/models/product_filter.dart';
import 'package:flutter_application_1/providers/auth_providers.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';

Product _product({int id = 1, double price = 250, int stock = 3}) => Product(
      id: id,
      name: 'Steam Wallet ₱$price',
      description: null,
      price: price,
      stock: stock,
      imageUrl: null,
      categoryId: 1,
      categoryName: 'Steam Wallet',
      createdAt: DateTime(2026),
    );

void main() {
  group('formatters', () {
    test('peso', () {
      expect(peso(1250), '₱1,250');
      expect(peso(5199.5), '₱5,199.50');
      expect(peso(0), '₱0');
    });

    test('order number', () => expect(orderNumber(42), '#000042'));
  });

  group('pagination', () {
    test('page math', () {
      final page = ProductPage(
        items: List.generate(1, (i) => _product(id: i)),
        totalCount: 13,
        page: 2,
      );
      expect(page.totalPages, 3);
      expect(page.firstShown, 13);
      expect(page.lastShown, 13);
      expect(page.hasNext, isFalse);
      expect(page.hasPrevious, isTrue);
    });
  });

  group('cart', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [currentUserIdProvider.overrideWithValue('user-1')],
      );
    });

    tearDown(() => container.dispose());

    test('adds, totals and counts', () {
      final cart = container.read(cartProvider.notifier);
      expect(cart.add(_product(id: 1, price: 250)), isNull);
      expect(cart.add(_product(id: 1, price: 250)), isNull);
      expect(cart.add(_product(id: 2, price: 500, stock: 5)), isNull);

      expect(container.read(cartCountProvider), 3);
      expect(container.read(cartTotalProvider), 1000);
    });

    test('refuses out-of-stock and above-stock quantities', () {
      final cart = container.read(cartProvider.notifier);
      expect(cart.add(_product(stock: 0)), isNotNull);
      expect(container.read(cartProvider), isEmpty);

      cart.add(_product(stock: 2));
      expect(cart.increment(1), isNull);
      expect(cart.increment(1), isNotNull); // 3 > stock 2
      expect(cart.quantityOf(1), 2);
    });

    test('decrement to zero removes, clear empties', () {
      final cart = container.read(cartProvider.notifier);
      cart.add(_product(id: 1));
      cart.add(_product(id: 2));
      cart.decrement(1);
      expect(container.read(cartProvider).length, 1);
      cart.clear();
      expect(container.read(cartProvider), isEmpty);
    });
  });
}
