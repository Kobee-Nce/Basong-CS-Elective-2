import 'dart:typed_data';

/// A row of `products` (with its category name from `categories`).
class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int stock;

  /// Either a Supabase Storage URL (uploaded by an admin) or a bundled
  /// asset path like `assets/images/steam250.png` (the original items).
  final String? imageUrl;
  final int categoryId;
  final String? categoryName;
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.categoryId,
    required this.categoryName,
    required this.createdAt,
  });

  bool get inStock => stock > 0;

  /// Expects `select('*, categories(name)')`.
  factory Product.fromMap(Map<String, dynamic> map) {
    final category = map['categories'];
    return Product(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String,
      description: map['description'] as String?,
      // float4 can arrive as int or double.
      price: (map['price'] as num?)?.toDouble() ?? 0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      imageUrl: map['image_url'] as String?,
      categoryId: (map['category_id'] as num).toInt(),
      categoryName: category is Map ? category['name'] as String? : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

/// Values from the admin product form, sent to ProductService.
class ProductDraft {
  final String name;
  final String? description;
  final double price;
  final int stock;
  final int categoryId;
  final String? imageUrl;

  const ProductDraft({
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'category_id': categoryId,
        'image_url': imageUrl,
      };
}

/// An image picked in the admin form, not uploaded yet.
class PickedImage {
  final Uint8List bytes;
  final String fileName;
  final String? mimeType;

  const PickedImage({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
  });
}
