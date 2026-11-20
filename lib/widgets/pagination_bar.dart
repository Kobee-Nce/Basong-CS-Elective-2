import 'package:flutter/material.dart';

import '../models/product_filter.dart';

/// "Showing 1–6 of 13 • Page 1 of 3" + Previous / page numbers / Next.
/// (From the backend-filter-pagination activity.)
class PaginationBar extends StatelessWidget {
  final ProductPage page;
  final bool busy;
  final ValueChanged<int> onPage;

  const PaginationBar({
    super.key,
    required this.page,
    required this.busy,
    required this.onPage,
  });

  @override
  Widget build(BuildContext context) {
    final p = page;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Showing ${p.firstShown}–${p.lastShown} of ${p.totalCount} '
            '• Page ${p.page + 1} of ${p.totalPages}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Row(
            children: [
              IconButton(
                tooltip: 'Previous page',
                color: Colors.white,
                disabledColor: Colors.white30,
                onPressed: p.hasPrevious && !busy ? () => onPage(p.page - 1) : null,
                icon: const Icon(Icons.chevron_left_rounded, size: 30),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final index in _visiblePages(p.page, p.totalPages))
                          index == null
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Text('…', style: TextStyle(color: Colors.white70)),
                                )
                              : _PageButton(
                                  label: '${index + 1}',
                                  selected: index == p.page,
                                  onTap: busy ? null : () => onPage(index),
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
                onPressed: p.hasNext && !busy ? () => onPage(p.page + 1) : null,
                icon: const Icon(Icons.chevron_right_rounded, size: 30),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Zero-based page indexes to show; null marks a "…" gap.
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

  const _PageButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: selected ? Colors.white : Colors.transparent,
        shape: const CircleBorder(side: BorderSide(color: Colors.white54)),
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
