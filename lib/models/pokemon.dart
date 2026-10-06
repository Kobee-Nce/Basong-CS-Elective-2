class Pokemon {
  final String name;
  final String image;
  final int id;

  const Pokemon({
    required this.name,
    required this.image,
    required this.id,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final String url = json['url'];

    final String idString =
        url.split('/').where((part) => part.isNotEmpty).last;

    final int id = int.parse(idString);

    return Pokemon(
      name: json['name'],
      id: id,
      image:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
    );
  }
}