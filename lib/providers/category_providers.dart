import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import 'product_providers.dart';
import 'service_providers.dart';

/// All categories, A–Z (filter chips + product form dropdown).
final categoriesProvider = FutureProvider<List<ProductCategory>>(
  (ref) => ref.watch(categoryServiceProvider).fetchAll(),
);

/// Admin category management. Each action refreshes the lists it affects.
class CategoryActions {
  CategoryActions(this._ref);

  final Ref _ref;

  Future<void> create(String name) async {
    await _ref.read(categoryServiceProvider).create(name.trim());
    _ref.invalidate(categoriesProvider);
  }

  Future<void> rename(int id, String name) async {
    await _ref.read(categoryServiceProvider).rename(id, name.trim());
    _ref.invalidate(categoriesProvider);
    _ref.invalidate(productsPageProvider); // cards show category names
  }

  Future<void> delete(int id) async {
    await _ref.read(categoryServiceProvider).delete(id);
    _ref.invalidate(categoriesProvider);

    // Don't keep filtering by a category that no longer exists.
    final filter = _ref.read(productFilterProvider);
    if (filter.categoryId == id) {
      _ref.read(productFilterProvider.notifier).setCategory(null);
    }
  }
}

final categoryActionsProvider = Provider<CategoryActions>(
  (ref) => CategoryActions(ref),
);
