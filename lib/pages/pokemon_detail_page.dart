import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pokemon_provider.dart';

class PokemonDetailPage extends StatelessWidget {
  const PokemonDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PokemonProvider>(
      builder: (context, pokemonProvider, child) {
        final pokemon = pokemonProvider.selectedPokemon;

        if (pokemon == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Pokémon Details'),
            ),
            body: const Center(
              child: Text('No Pokémon selected.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              pokemon.name.toUpperCase(),
            ),
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    pokemon.image,
                    height: 220,
                    width: 220,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported,
                        size: 120,
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  Text(
                    pokemon.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Pokémon ID: ${pokemon.id}',
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}