import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_exception.dart';
import '../models/product.dart';
import '../models/product_filter.dart';
import 'service_providers.dart';

// ------------------------------------------------------------------
// Filters (search, category, price range, sort, page)
// ------------------------------------------------------------------

class ProductFilterNotifier extends Notifier<ProductFilter> {
  @override
  ProductFilter build() => const ProductFilter();

  /// Every filter change goes back to page 1, so the user never lands
  /// on a page that no longer exists (e.g. page 3 of a 1-page result).
  void setSearch(String search) {
    final value = search.trim();
    if (value == state.search) return;
    state = state.copyWith(search: value, page: 0);
  }

  void setCategory(int? categoryId) {
    state = state.copyWith(categoryId: () => categoryId, page: 0);
  }

  void setPriceRange(double? min, double? max) {
    state = state.copyWith(minPrice: () => min, maxPrice: () => max, page: 0);
  }

  void setSort(ProductSort sort) {
    state = state.copyWith(sort: sort, page: 0);
  }

  void goToPage(int page) {
    if (page < 0 || page == state.page) return;
    state = state.copyWith(page: page);
  }

  void reset() => state = ProductFilter(sort: state.sort);
}

final productFilterProvider =
    NotifierProvider<ProductFilterNotifier, ProductFilter>(
  ProductFilterNotifier.new,
);

// ------------------------------------------------------------------
// Queries
// ------------------------------------------------------------------

/// The current page of products for the current filter.
final productsPageProvider = FutureProvider<ProductPage>((ref) async {
  final filter = ref.watch(productFilterProvider);
  final service = ref.watch(productServiceProvider);

  try {
    return await service.fetchPage(filter);
  } on PageOutOfRangeException {
    // The catalog shrank (e.g. a product was deleted) and this page is
    // gone. Show page 1 and move the filter there.
    final firstPage = await service.fetchPage(filter.copyWith(page: 0));
    Future.microtask(() {
      if (ref.mounted) ref.read(productFilterProvider.notifier).goToPage(0);
    });
    return firstPage;
  }
});

/// Slider bounds: cheapest and priciest product in the database.
final priceBoundsProvider = FutureProvider<PriceBounds>(
  (ref) => ref.watch(productServiceProvider).fetchPriceBounds(),
);

/// One product, for the detail and edit screens when opened by URL.
final productByIdProvider =
    FutureProvider.autoDispose.family<Product, int>((ref, id) {
  return ref.watch(productServiceProvider).fetchById(id);
});

// ------------------------------------------------------------------
// Admin actions
// ------------------------------------------------------------------

class ProductActions {
  ProductActions(this._ref);

  final Ref _ref;

  /// Creates ([existing] == null) or updates a product.
  /// A newly picked image is uploaded first; if saving the row then
  /// fails, the uploaded file is removed again.
  Future<Product> save({
    Product? existing,
    required String name,
    required String? description,
    required double price,
    required int stock,
    required int categoryId,
    PickedImage? newImage,
    bool removeImage = false,
  }) async {
    final storage = _ref.read(storageServiceProvider);
    final products = _ref.read(productServiceProvider);

    String? imageUrl = removeImage ? null : existing?.imageUrl;
    String? uploadedUrl;
    if (newImage != null) {
      uploadedUrl = await storage.uploadProductImage(newImage);
      imageUrl = uploadedUrl;
    }

    final draft = ProductDraft(
      name: name.trim(),
      description: _blankToNull(description),
      price: price,
      stock: stock,
      categoryId: categoryId,
      imageUrl: imageUrl,
    );

    try {
      final saved = existing == null
          ? await products.create(draft)
          : await products.update(existing.id, draft);

      // The old uploaded image is no longer used.
      if (existing != null && existing.imageUrl != saved.imageUrl) {
        await storage.deleteByPublicUrl(existing.imageUrl);
      }

      _refresh(saved.id);
      return saved;
    } catch (_) {
      await storage.deleteByPublicUrl(uploadedUrl);
      rethrow;
    }
  }

  Future<void> delete(Product product) async {
    await _ref.read(productServiceProvider).delete(product.id);
    await _ref.read(storageServiceProvider).deleteByPublicUrl(product.imageUrl);
    _refresh(product.id);
  }

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  void _refresh(int productId) {
    _ref.invalidate(productsPageProvider);
    _ref.invalidate(priceBoundsProvider);
    _ref.invalidate(productByIdProvider(productId));
  }
}

final productActionsProvider = Provider<ProductActions>(
  (ref) => ProductActions(ref),
);
