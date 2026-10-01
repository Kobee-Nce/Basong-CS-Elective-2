class Pokemon {
  final String name;
  final int id;
  final String imageUrl;

  Pokemon({
    required this.name,
    required this.id,
    required this.imageUrl,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final String url = json['url'];

    final String idString = url
        .replaceAll(RegExp(r'/$'), '')
        .split('/')
        .last;

    final int id = int.parse(idString);

    return Pokemon(
      name: json['name'],
      id: id,
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
    );
  }
}