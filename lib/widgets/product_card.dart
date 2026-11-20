import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import 'product_image.dart';

/// Product tile used by both product lists.
///
/// The footer is the only difference between roles:
///   * customer → "Add to cart" ([onAddToCart])
///   * admin    → Edit + Delete ([onEdit], [onDelete])
/// Whatever is null is simply not built, so customers never get the
/// management buttons. (The database enforces this too, via RLS.)
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  // Customer
  final VoidCallback? onAddToCart;
  final int inCart;

  // Admin
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.inCart = 0,
    this.onEdit,
    this.onDelete,
  });

  bool get _isAdminCard => onEdit != null || onDelete != null;

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.accentFor(product.categoryName);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: 'product-${product.id}',
                      child: Container(
                        color: Colors.black12,
                        padding: const EdgeInsets.all(8),
                        child: ProductImage(product: product),
                      ),
                    ),
                  ),
                  if (product.categoryName != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _Badge(text: product.categoryName!, color: accent),
                    ),
                  if (!product.inStock)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: _Badge(text: 'Out of stock', color: Colors.black87),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
              child: Row(
                children: [
                  Text(
                    peso(product.price),
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    product.inStock ? '${product.stock} left' : 'Sold out',
                    style: TextStyle(
                      fontSize: 13,
                      color: product.inStock
                          ? Theme.of(context).hintColor
                          : AppTheme.valorantRed,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: _isAdminCard ? _adminActions() : _customerAction(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customerAction() {
    if (onAddToCart == null) return const SizedBox.shrink();

    final maxed = inCart >= product.stock;
    final label = !product.inStock
        ? 'Out of stock'
        : maxed
            ? 'Max in cart'
            : inCart > 0
                ? 'Add ($inCart in cart)'
                : 'Add to cart';

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        ),
        onPressed: product.inStock && !maxed ? onAddToCart : null,
        icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
        label: FittedBox(child: Text(label)),
      ),
    );
  }

  Widget _adminActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('Edit'),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onPressed: onDelete,
            icon: const Icon(Icons.delete_rounded, size: 18),
            label: const Text('Delete'),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
