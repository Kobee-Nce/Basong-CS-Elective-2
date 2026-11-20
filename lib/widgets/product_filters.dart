import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/formatters.dart';
import '../models/product_filter.dart';
import '../providers/category_providers.dart';
import '../providers/product_providers.dart';

/// Search box + sort menu + category chips + price range slider.
class ProductFilters extends ConsumerStatefulWidget {
  const ProductFilters({super.key});

  @override
  ConsumerState<ProductFilters> createState() => _ProductFiltersState();
}

class _ProductFiltersState extends ConsumerState<ProductFilters> {
  late final TextEditingController _search;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Keep the text when coming back to this screen.
    _search = TextEditingController(text: ref.read(productFilterProvider).search);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  /// Waits until typing pauses before querying the database.
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(productFilterProvider.notifier).setSearch(value);
    });
    setState(() {}); // show/hide the clear button
  }

  void _clearSearch() {
    _debounce?.cancel();
    _search.clear();
    ref.read(productFilterProvider.notifier).setSearch('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(productFilterProvider);
    final notifier = ref.read(productFilterProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _search,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search game credits…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  isDense: true,
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<ProductSort>(
              tooltip: 'Sort',
              initialValue: filter.sort,
              onSelected: notifier.setSort,
              itemBuilder: (context) => [
                for (final sort in ProductSort.values)
                  PopupMenuItem(value: sort, child: Text(sort.label)),
              ],
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.sort_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const _CategoryChips(),
        const SizedBox(height: 10),
        const PriceFilterPanel(),
      ],
    );
  }
}

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final selected = ref.watch(productFilterProvider.select((f) => f.categoryId));
    final notifier = ref.read(productFilterProvider.notifier);

    return SizedBox(
      height: 40,
      child: categories.when(
        loading: () => const Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
        ),
        error: (error, _) => Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                "Couldn't load categories.",
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () => ref.invalidate(categoriesProvider),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
        data: (list) => ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _chip('All', selected == null, () => notifier.setCategory(null)),
            for (final c in list)
              _chip(c.name, selected == c.id, () => notifier.setCategory(c.id)),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: selected ? Colors.black87 : Colors.white,
        ),
        selectedColor: Colors.white,
        backgroundColor: Colors.white.withValues(alpha: .15),
        side: const BorderSide(color: Colors.white54),
        showCheckmark: false,
      ),
    );
  }
}

/// Price range slider (from the backend-filter-pagination activity).
/// Dragging only updates the labels; the query runs when the thumb is
/// released.
class PriceFilterPanel extends ConsumerStatefulWidget {
  const PriceFilterPanel({super.key});

  @override
  ConsumerState<PriceFilterPanel> createState() => _PriceFilterPanelState();
}

class _PriceFilterPanelState extends ConsumerState<PriceFilterPanel> {
  RangeValues? _dragging;

  @override
  Widget build(BuildContext context) {
    final bounds = ref.watch(priceBoundsProvider);
    final filter = ref.watch(productFilterProvider);

    final b = bounds.value;
    if (b == null || !b.isUsable) {
      // Loading, failed, or every product has the same price: no slider.
      return const SizedBox.shrink();
    }

    final current = _dragging ??
        RangeValues(
          (filter.minPrice ?? b.min).clamp(b.min, b.max).toDouble(),
          (filter.maxPrice ?? b.max).clamp(b.min, b.max).toDouble(),
        );

    RangeValues snap(RangeValues v) {
      double s(double x) => ((x / PriceBounds.step).round() * PriceBounds.step)
          .clamp(b.min, b.max)
          .toDouble();
      return RangeValues(s(v.start), s(v.end));
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Price',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${peso(current.start)} – ${peso(current.end)}',
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                ),
              ),
              if (filter.hasPriceFilter)
                TextButton(
                  onPressed: () => ref
                      .read(productFilterProvider.notifier)
                      .setPriceRange(null, null),
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('Reset'),
                ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              overlayColor: Colors.white24,
              valueIndicatorColor: Colors.black87,
              activeTickMarkColor: Colors.transparent,
              inactiveTickMarkColor: Colors.transparent,
            ),
            child: RangeSlider(
              min: b.min,
              max: b.max,
              divisions: b.divisions,
              values: current,
              labels: RangeLabels(peso(current.start), peso(current.end)),
              onChanged: (v) => setState(() => _dragging = snap(v)),
              onChangeEnd: (v) {
                final r = snap(v);
                setState(() => _dragging = null);
                final full = r.start <= b.min && r.end >= b.max;
                ref.read(productFilterProvider.notifier).setPriceRange(
                      full ? null : r.start,
                      full ? null : r.end,
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}
