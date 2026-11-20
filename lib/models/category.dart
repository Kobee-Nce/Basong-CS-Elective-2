/// A row of `categories`.
class ProductCategory {
  final int id;
  final String name;

  const ProductCategory({required this.id, required this.name});

  factory ProductCategory.fromMap(Map<String, dynamic> map) => ProductCategory(
        id: (map['id'] as num).toInt(),
        name: map['name'] as String,
      );

  @override
  bool operator ==(Object other) => other is ProductCategory && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
