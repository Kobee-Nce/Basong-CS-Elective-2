import 'product.dart';

enum ProductSort {
  priceLowHigh('Price: low to high', 'price', true),
  priceHighLow('Price: high to low', 'price', false),
  nameAZ('Name: A to Z', 'name', true),
  newest('Newest first', 'created_at', false);

  final String label;
  final String column;
  final bool ascending;

  const ProductSort(this.label, this.column, this.ascending);
}

/// Search, category, price range, sort and page — everything the product
/// list query depends on. Carried over from the backend-filter-pagination
/// activity (price range + pagination), plus search and category.
class ProductFilter {
  /// Products per page (same as the previous activity).
  static const int pageSize = 6;

  final String search;
  final int? categoryId;

  /// null = no price filter (full range).
  final double? minPrice;
  final double? maxPrice;
  final ProductSort sort;

  /// Zero-based (page 0 is shown as "Page 1").
  final int page;

  const ProductFilter({
    this.search = '',
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.sort = ProductSort.priceLowHigh,
    this.page = 0,
  });

  bool get hasPriceFilter => minPrice != null || maxPrice != null;

  bool get isFiltered =>
      search.isNotEmpty || categoryId != null || hasPriceFilter;

  ProductFilter copyWith({
    String? search,
    int? Function()? categoryId,
    double? Function()? minPrice,
    double? Function()? maxPrice,
    ProductSort? sort,
    int? page,
  }) {
    return ProductFilter(
      search: search ?? this.search,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      minPrice: minPrice != null ? minPrice() : this.minPrice,
      maxPrice: maxPrice != null ? maxPrice() : this.maxPrice,
      sort: sort ?? this.sort,
      page: page ?? this.page,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ProductFilter &&
      other.search == search &&
      other.categoryId == categoryId &&
      other.minPrice == minPrice &&
      other.maxPrice == maxPrice &&
      other.sort == sort &&
      other.page == page;

  @override
  int get hashCode =>
      Object.hash(search, categoryId, minPrice, maxPrice, sort, page);
}

/// One page of products plus the total number of matching rows.
class ProductPage {
  final List<Product> items;
  final int totalCount;
  final int page;

  const ProductPage({
    required this.items,
    required this.totalCount,
    required this.page,
  });

  int get totalPages {
    final pages = (totalCount / ProductFilter.pageSize).ceil();
    return pages < 1 ? 1 : pages;
  }

  bool get hasPrevious => page > 0;
  bool get hasNext => page < totalPages - 1;

  int get firstShown => totalCount == 0 ? 0 : page * ProductFilter.pageSize + 1;
  int get lastShown => page * ProductFilter.pageSize + items.length;
}

/// Cheapest and priciest product, rounded out to ₱50 steps for the slider.
class PriceBounds {
  static const double step = 50;

  final double min;
  final double max;

  const PriceBounds(this.min, this.max);

  bool get isUsable => max > min;

  int? get divisions {
    final steps = ((max - min) / step).round();
    return steps > 0 ? steps : null;
  }
}
