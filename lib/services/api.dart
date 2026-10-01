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
        'Failed to load Pokémon. '
        'Status code: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    final List<dynamic> results = data['results'];

    return results
        .map((pokemon) => Pokemon.fromJson(pokemon))
        .toList();
  }
}