import 'package:flutter/material.dart';

import '../state/products_controller.dart';

/// "Showing 1–6 of 13" + Previous / page numbers / Next.
class PaginationBar extends StatelessWidget {
  final ProductsController controller;

  const PaginationBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final busy = c.isLoading;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Showing ${c.firstShown}–${c.lastShown} of ${c.totalCount} '
            '• Page ${c.currentPage + 1} of ${c.totalPages}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Row(
            children: [
              IconButton(
                tooltip: 'Previous page',
                color: Colors.white,
                disabledColor: Colors.white30,
                onPressed: c.hasPrevious && !busy ? c.previousPage : null,
                icon: const Icon(Icons.chevron_left_rounded, size: 30),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final page in _visiblePages(
                          c.currentPage,
                          c.totalPages,
                        ))
                          page == null
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    '…',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                )
                              : _PageButton(
                                  label: '${page + 1}',
                                  selected: page == c.currentPage,
                                  onTap: busy ? null : () => c.goToPage(page),
                                ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Next page',
                color: Colors.white,
                disabledColor: Colors.white30,
                onPressed: c.hasNext && !busy ? c.nextPage : null,
                icon: const Icon(Icons.chevron_right_rounded, size: 30),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Zero-based page indexes to show; null marks a "…" gap.
  /// e.g. current 5 of 10 → 0 … 4 5 6 … 9
  static List<int?> _visiblePages(int current, int total) {
    if (total <= 7) return List.generate(total, (i) => i);

    final pages = <int?>[0];
    final start = (current - 1).clamp(1, total - 2).toInt();
    final end = (current + 1).clamp(1, total - 2).toInt();

    if (start > 1) pages.add(null);
    for (var i = start; i <= end; i++) {
      pages.add(i);
    }
    if (end < total - 2) pages.add(null);

    pages.add(total - 1);
    return pages;
  }
}

class _PageButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _PageButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: selected ? Colors.white : Colors.transparent,
        shape: const CircleBorder(
          side: BorderSide(color: Colors.white54),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: selected ? null : onTap,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.black87 : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
