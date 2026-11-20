import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_exception.dart';
import '../models/category.dart';
import 'supabase_errors.dart';

/// CRUD for `categories`. Writes succeed only for admins (RLS).
class CategoryService {
  CategoryService(this._client);

  final SupabaseClient _client;

  Future<List<ProductCategory>> fetchAll() {
    return guard(() async {
      final rows = await _client
          .from('categories')
          .select('id, name')
          .order('name', ascending: true);
      return rows.map(ProductCategory.fromMap).toList();
    });
  }

  Future<ProductCategory> create(String name) {
    return guard(() async {
      final row = await _client
          .from('categories')
          .insert({'name': name})
          .select('id, name')
          .single();
      return ProductCategory.fromMap(row);
    });
  }

  Future<ProductCategory> rename(int id, String name) {
    return guard(() async {
      final row = await _client
          .from('categories')
          .update({'name': name})
          .eq('id', id)
          .select('id, name')
          .maybeSingle();
      if (row == null) throw _notChanged;
      return ProductCategory.fromMap(row);
    });
  }

  Future<void> delete(int id) {
    return guard(() async {
      final rows =
          await _client.from('categories').delete().eq('id', id).select('id');
      if (rows.isEmpty) throw _notChanged;
    });
  }

  // RLS doesn't raise an error on update/delete — it just matches no
  // rows. Treat "nothing changed" as a failure so it never fails silently.
  static const _notChanged = AppException(
    'Nothing was changed. The category may have been removed, or you '
    "don't have permission.",
    AppErrorKind.permissionDenied,
  );
}
