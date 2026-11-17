import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/game_credit.dart';

/// Holds the shop's product list, price filter and pagination state.
///
/// Same pattern as CartController: a single ChangeNotifier instance that
/// screens listen to. Every page is fetched from Supabase with the price
/// filter (.gte / .lte), sorting (.order) and pagination (.range) done in
/// the database query, so only the rows for the current page are downloaded.
class ProductsController extends ChangeNotifier {
  static final ProductsController instance = ProductsController._();

  ProductsController._();

  /// Products shown per page (activity requirement: 6–8 max).
  static const int pageSize = 6;

  /// The price slider moves in ₱50 steps.
  static const double priceStep = 50;

  SupabaseClient get _db => Supabase.instance.client;

  // ---------------- State ----------------

  List<GameCredit> products = [];

  /// Zero-based page index (page 0 is shown to the user as "Page 1").
  int currentPage = 0;

  /// Number of rows that match the current price filter (all pages).
  int totalCount = 0;

  bool isLoading = false;
  String? error;

  /// Slider bounds, read from the cheapest and priciest product in the DB.
  double minPrice = 0;
  double maxPrice = 0;

  /// The price range the user picked.
  RangeValues selectedRange = const RangeValues(0, 0);

  bool _initialized = false;

  /// Increases with every request so a slow, outdated response can't
  /// overwrite a newer one (e.g. when the slider is moved quickly).
  int _requestId = 0;

  // ---------------- Derived values ----------------

  int get totalPages => math.max(1, (totalCount / pageSize).ceil());

  bool get hasPrevious => currentPage > 0;

  bool get hasNext => currentPage < totalPages - 1;

  bool get isFiltered =>
      selectedRange.start > minPrice || selectedRange.end < maxPrice;

  /// "Showing 7–12 of 13" helpers.
  int get firstShown => totalCount == 0 ? 0 : currentPage * pageSize + 1;

  int get lastShown => currentPage * pageSize + products.length;

  int? get sliderDivisions {
    final steps = ((maxPrice - minPrice) / priceStep).round();
    return steps > 0 ? steps : null;
  }

  // ---------------- Public actions ----------------

  /// Loads the price bounds and the first page. Safe to call more than once.
  Future<void> init() async {
    if (_initialized) return;

    if (!SupabaseConfig.isConfigured) {
      error = 'Supabase is not configured yet. Add your project URL and '
          'anon key in lib/config/supabase_config.dart.';
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _loadPriceBounds();
      _initialized = true;
    } catch (e) {
      isLoading = false;
      error = _describe(e);
      notifyListeners();
      return;
    }

    await _fetchPage(0);
  }

  /// Called while the slider is being dragged: updates the labels only,
  /// without hitting the database on every tiny movement.
  void previewRange(RangeValues values) {
    selectedRange = _snap(values);
    notifyListeners();
  }

  /// Called when the user lets go of the slider: re-query from page 1.
  /// Resetting to page 1 avoids landing on a page that no longer exists
  /// (e.g. being on page 3 and narrowing the range to 4 results).
  Future<void> applyRange(RangeValues values) {
    selectedRange = _snap(values);
    return _fetchPage(0);
  }

  Future<void> resetFilter() =>
      applyRange(RangeValues(minPrice, maxPrice));

  Future<void> goToPage(int page) {
    if (page < 0 || page >= totalPages || page == currentPage) {
      return Future.value();
    }
    return _fetchPage(page);
  }

  Future<void> nextPage() => goToPage(currentPage + 1);

  Future<void> previousPage() => goToPage(currentPage - 1);

  Future<void> retry() => _initialized ? _fetchPage(currentPage) : init();

  /// Fetches one product, used when the detail page is opened directly
  /// by URL (e.g. refreshing /detail/5 on Flutter web).
  Future<GameCredit?> fetchById(int id) async {
    final row =
        await _db.from('products').select().eq('id', id).maybeSingle();
    return row == null ? null : GameCredit.fromMap(row);
  }

  // ---------------- Supabase queries ----------------

  Future<void> _loadPriceBounds() async {
    final cheapest = await _db
        .from('products')
        .select('price')
        .order('price', ascending: true)
        .limit(1)
        .maybeSingle();

    final priciest = await _db
        .from('products')
        .select('price')
        .order('price', ascending: false)
        .limit(1)
        .maybeSingle();

    final low = cheapest == null ? 0.0 : (cheapest['price'] as num).toDouble();
    final high =
        priciest == null ? 0.0 : (priciest['price'] as num).toDouble();

    // Round outward to whole ₱50 steps so the slider snaps cleanly
    // and still includes the cheapest and priciest products.
    minPrice = (low / priceStep).floorToDouble() * priceStep;
    maxPrice = (high / priceStep).ceilToDouble() * priceStep;
    selectedRange = RangeValues(minPrice, maxPrice);
  }

  Future<void> _fetchPage(int page) async {
    final requestId = ++_requestId;

    isLoading = true;
    error = null;
    notifyListeners();

    // .range() is zero-based and inclusive on both ends:
    // page 0 → rows 0–5, page 1 → rows 6–11, ...
    final from = page * pageSize;
    final to = from + pageSize - 1;

    try {
      final response = await _db
          .from('products')
          .select()
          .gte('price', selectedRange.start) // 1. Filter
          .lte('price', selectedRange.end)
          .order('price', ascending: true) // 2. Order
          .order('id', ascending: true) //    (tie-breaker = stable pages)
          .range(from, to) // 3. Paginate
          .count(CountOption.exact); // + total rows for the page buttons

      if (requestId != _requestId) return; // a newer request took over

      final count = response.count;
      final lastPage = math.max(0, (count / pageSize).ceil() - 1);

      // Catalog shrank since the last load and this page is now empty.
      if (page > lastPage) {
        await _fetchPage(lastPage);
        return;
      }

      products = response.data.map(GameCredit.fromMap).toList();
      totalCount = count;
      currentPage = page;
    } on PostgrestException catch (e) {
      if (requestId != _requestId) return;

      // PGRST103 = requested range is past the last row.
      if (e.code == 'PGRST103' && page > 0) {
        await _fetchPage(0);
        return;
      }
      error = e.message;
    } catch (e) {
      if (requestId != _requestId) return;
      error = _describe(e);
    } finally {
      if (requestId == _requestId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  // ---------------- Helpers ----------------

  RangeValues _snap(RangeValues values) {
    double snap(double v) => ((v / priceStep).round() * priceStep)
        .clamp(minPrice, maxPrice)
        .toDouble();

    return RangeValues(snap(values.start), snap(values.end));
  }

  String _describe(Object e) {
    if (e is PostgrestException) return e.message;
    return 'Could not load products. Check your internet connection '
        'and Supabase settings.\n($e)';
  }
}
