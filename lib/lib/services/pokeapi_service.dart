import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

class PokeApiService {
  PokeApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://pokeapi.co/api/v2/pokemon';
  static const Duration _requestTimeout = Duration(seconds: 20);

  final http.Client _client;

  /// Fetches the first 30 Pokémon and retrieves each one's detail record so
  /// the type filter uses actual PokéAPI type data.
  Future<List<Pokemon>> fetchPokemon() async {
    final http.Response response = await _client
        .get(Uri.parse('$_baseUrl?limit=30'))
        .timeout(_requestTimeout);

    if (response.statusCode != 200) {
      throw Exception(
        'PokéAPI list request failed (HTTP ${response.statusCode}).',
      );
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('PokéAPI returned an unexpected response.');
    }

    final dynamic rawResults = decoded['results'];
    if (rawResults is! List<dynamic>) {
      throw const FormatException('PokéAPI did not return a Pokémon list.');
    }

    final List<Pokemon> pokemon = await Future.wait(
      rawResults.map((dynamic entry) async {
        if (entry is! Map<String, dynamic>) {
          throw const FormatException('A Pokémon list entry was invalid.');
        }

        final String? url = entry['url'] as String?;
        if (url == null || url.isEmpty) {
          throw const FormatException('A Pokémon detail URL was missing.');
        }

        return _fetchPokemonDetails(url);
      }),
    );

    return pokemon;
  }

  Future<Pokemon> _fetchPokemonDetails(String url) async {
    final http.Response response = await _client
        .get(Uri.parse(url))
        .timeout(_requestTimeout);

    if (response.statusCode != 200) {
      throw Exception(
        'A Pokémon detail request failed (HTTP ${response.statusCode}).',
      );
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'PokéAPI returned invalid Pokémon detail data.',
      );
    }

    return Pokemon.fromDetailJson(decoded);
  }

  void dispose() {
    _client.close();
  }
}
