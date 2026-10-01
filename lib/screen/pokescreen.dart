import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../services/api.dart';
import '../widgets/pokecard.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  final PokeApiService _pokeApiService = PokeApiService();

  late Future<List<Pokemon>> _pokemonFuture;

  @override
  void initState() {
    super.initState();

    _pokemonFuture = _pokeApiService.fetchPokemon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
      ),
      body: FutureBuilder<List<Pokemon>>(
        future: _pokemonFuture,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Something went wrong.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final List<Pokemon> pokemon = snapshot.data ?? [];

          // Empty state
          if (pokemon.isEmpty) {
            return const Center(
              child: Text(
                'No Pokémon found.',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            );
          }

          // Success state
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: pokemon.length,
            itemBuilder: (context, index) {
              return PokemonCard(
                pokemon: pokemon[index],
              );
            },
          );
        },
      ),
    );
  }
}