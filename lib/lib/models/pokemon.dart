class Pokemon {
  Pokemon({
    required this.id,
    required this.name,
    required this.image,
    required List<String> types,
  }) : types = List.unmodifiable(types);

  final int id;
  final String name;
  final String image;
  final List<String> types;

  factory Pokemon.fromDetailJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final int id = rawId is int ? rawId : int.tryParse('$rawId') ?? 0;
    final String name = json['name'] as String? ?? 'unknown';

    final Map<String, dynamic> sprites =
        json['sprites'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> otherSprites =
        sprites['other'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> officialArtwork =
        otherSprites['official-artwork'] as Map<String, dynamic>? ??
            <String, dynamic>{};

    final String image =
        (officialArtwork['front_default'] as String?) ??
        (sprites['front_default'] as String?) ??
        '';

    final List<dynamic> typeEntries =
        json['types'] as List<dynamic>? ?? <dynamic>[];
    final List<String> types = typeEntries.map((entry) {
      final Map<String, dynamic> entryMap = entry as Map<String, dynamic>;
      final Map<String, dynamic> typeMap =
          entryMap['type'] as Map<String, dynamic>;
      return (typeMap['name'] as String).toLowerCase();
    }).toList();

    return Pokemon(
      id: id,
      name: name,
      image: image,
      types: types,
    );
  }
}
