class GameCredit {
  final int id;
  final String title;
  final double price;

  /// Local asset path. Null for products added in Supabase without an image;
  /// those render a generated platform card instead (see CreditImage).
  final String? image;
  final String description;
  final String platform;

  const GameCredit({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.description,
    required this.platform,
  });

  /// Builds a GameCredit from a row of the Supabase `products` table.
  factory GameCredit.fromMap(Map<String, dynamic> map) {
    return GameCredit(
      id: (map['id'] as num).toInt(),
      title: map['title'] as String,
      // Postgres `numeric` arrives as int or double depending on the value.
      price: (map['price'] as num).toDouble(),
      image: map['image'] as String?,
      description: (map['description'] as String?) ?? '',
      platform: map['platform'] as String,
    );
  }
}
