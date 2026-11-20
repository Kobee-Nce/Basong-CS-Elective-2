import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_exception.dart';
import '../models/product.dart';
import '../models/product_filter.dart';
import 'supabase_errors.dart';

/// Reads and writes `products`. Writes succeed only for admins (RLS).
class ProductService {
  ProductService(this._client);

  final SupabaseClient _client;

  static const _columns = '*, categories(name)';

  /// One page of products. Search, category, price range, sorting and
  /// pagination are all done in the database query, so only the rows
  /// for the current page are downloaded (same approach as the
  /// backend-filter-pagination activity).
  Future<ProductPage> fetchPage(ProductFilter filter) {
    return guard(() async {
      var query = _client.from('products').select(_columns);

      final search = filter.search.trim().replaceAll(RegExp(r'[%_*,()]'), '');
      if (search.isNotEmpty) {
        query = query.ilike('name', '%$search%');
      }
      if (filter.categoryId != null) {
        query = query.eq('category_id', filter.categoryId!);
      }
      if (filter.minPrice != null) {
        query = query.gte('price', filter.minPrice!);
      }
      if (filter.maxPrice != null) {
        query = query.lte('price', filter.maxPrice!);
      }

      // .range() is zero-based and inclusive: page 0 → rows 0–5.
      final from = filter.page * ProductFilter.pageSize;
      final to = from + ProductFilter.pageSize - 1;

      final response = await query
          .order(filter.sort.column, ascending: filter.sort.ascending)
          .order('id', ascending: true) // tie-breaker → stable pages
          .range(from, to)
          .count(CountOption.exact);

      return ProductPage(
        items: response.data.map(Product.fromMap).toList(),
        totalCount: response.count,
        page: filter.page,
      );
    });
  }

  /// Cheapest and priciest product, rounded out to whole ₱50 steps.
  Future<PriceBounds> fetchPriceBounds() {
    return guard(() async {
      final cheapest = await _client
          .from('products')
          .select('price')
          .order('price', ascending: true)
          .limit(1)
          .maybeSingle();
      final priciest = await _client
          .from('products')
          .select('price')
          .order('price', ascending: false)
          .limit(1)
          .maybeSingle();

      final low = (cheapest?['price'] as num?)?.toDouble() ?? 0;
      final high = (priciest?['price'] as num?)?.toDouble() ?? 0;
      const step = PriceBounds.step;
      return PriceBounds(
        (low / step).floorToDouble() * step,
        (high / step).ceilToDouble() * step,
      );
    });
  }

  Future<Product> fetchById(int id) {
    return guard(() async {
      final row = await _client
          .from('products')
          .select(_columns)
          .eq('id', id)
          .maybeSingle();
      if (row == null) {
        throw const AppException(
          'This product no longer exists.',
          AppErrorKind.notFound,
        );
      }
      return Product.fromMap(row);
    });
  }

  Future<Product> create(ProductDraft draft) {
    return guard(() async {
      final row = await _client
          .from('products')
          .insert(draft.toMap())
          .select(_columns)
          .single();
      return Product.fromMap(row);
    });
  }

  Future<Product> update(int id, ProductDraft draft) {
    return guard(() async {
      final row = await _client
          .from('products')
          .update(draft.toMap())
          .eq('id', id)
          .select(_columns)
          .maybeSingle();
      if (row == null) throw _notChanged;
      return Product.fromMap(row);
    });
  }

  Future<void> delete(int id) {
    return guard(() async {
      final rows =
          await _client.from('products').delete().eq('id', id).select('id');
      if (rows.isEmpty) throw _notChanged;
    });
  }

  // RLS filters rows silently on update/delete; report it instead.
  static const _notChanged = AppException(
    'Nothing was changed. The product may have been removed, or you '
    "don't have permission.",
    AppErrorKind.permissionDenied,
  );
}
