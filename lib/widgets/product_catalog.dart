import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../providers/product_providers.dart';
import 'pagination_bar.dart';
import 'product_filters.dart';
import 'state_views.dart';

/// Filters + product grid + pagination, shared by the customer shop and
/// the admin product list. [cardBuilder] decides which buttons a card has.
class ProductCatalog extends ConsumerWidget {
  final Widget Function(BuildContext context, Product product) cardBuilder;

  /// Extra space at the bottom (so a FAB doesn't cover the pagination).
  final double bottomPadding;

  const ProductCatalog({
    super.key,
    required this.cardBuilder,
    this.bottomPadding = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(productsPageProvider);
    final filter = ref.watch(productFilterProvider);
    final page = pageAsync.value;
    final busy = pageAsync.isLoading;

    Future<void> refresh() async {
      ref.invalidate(priceBoundsProvider);
      ref.invalidate(productsPageProvider);
      try {
        await ref.read(productsPageProvider.future);
      } catch (_) {
        // The error is shown by the error view below.
      }
    }

    final Widget body;
    if (pageAsync.hasError && !busy) {
      body = SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorView(error: pageAsync.error!, onRetry: refresh),
      );
    } else if (page == null) {
      body = const SliverFillRemaining(
        hasScrollBody: false,
        child: LoadingView(message: 'Loading products…'),
      );
    } else if (page.totalCount == 0) {
      body = SliverFillRemaining(
        hasScrollBody: false,
        child: MessageView(
          icon: Icons.search_off_rounded,
          message: filter.isFiltered
              ? 'No game credits match your filters.'
              : 'No products yet.',
          actionLabel: filter.isFiltered ? 'Clear filters' : null,
          onAction: () => ref.read(productFilterProvider.notifier).reset(),
        ),
      );
    } else {
      body = SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverOpacity(
          // Dim the current page while the next one loads.
          opacity: busy ? .45 : 1,
          sliver: SliverGrid.builder(
            itemCount: page.items.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: .62,
            ),
            itemBuilder: (context, index) =>
                cardBuilder(context, page.items[index]),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 14),
            sliver: SliverToBoxAdapter(child: ProductFilters()),
          ),
          if (busy && page != null)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: LinearProgressIndicator(color: Colors.white),
              ),
            ),
          body,
          if (page != null && page.totalCount > 0 && !(pageAsync.hasError && !busy))
            SliverToBoxAdapter(
              child: PaginationBar(
                page: page,
                busy: busy,
                onPage: ref.read(productFilterProvider.notifier).goToPage,
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
        ],
      ),
    );
  }
}
