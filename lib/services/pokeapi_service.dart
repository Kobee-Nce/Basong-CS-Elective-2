import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

class PokeApiService {
  static const String _baseUrl =
      'https://pokeapi.co/api/v2/pokemon';

  Future<List<Pokemon>> fetchPokemon() async {
    final response = await http.get(
      Uri.parse('$_baseUrl?limit=30'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load Pokémon. Status code: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final results = data['results'] as List<dynamic>;

    return results
        .map(
          (pokemon) => Pokemon.fromJson(
            pokemon as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}