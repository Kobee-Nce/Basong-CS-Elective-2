import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/pokemon_card.dart';
import '../providers/pokemon_provider.dart';
import 'pokemon_detail_page.dart';

class PokedexPage extends StatelessWidget {
  const PokedexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<PokemonProvider>().refreshPokemon();
            },
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<PokemonProvider>(
        builder: (context, pokemonProvider, child) {
          if (pokemonProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (pokemonProvider.hasError) {
            return _buildErrorState(
              context,
              pokemonProvider.errorMessage,
            );
          }

          if (pokemonProvider.hasData) {
            if (pokemonProvider.pokemon.isEmpty) {
              return const Center(
                child: Text('No Pokémon found.'),
              );
            }

            return RefreshIndicator(
              onRefresh: pokemonProvider.refreshPokemon,
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: pokemonProvider.pokemon.length,
                itemBuilder: (context, index) {
                  final pokemon = pokemonProvider.pokemon[index];

                  return PokemonCard(
                    pokemon: pokemon,
                    onTap: () {
                      pokemonProvider.selectPokemon(pokemon);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const PokemonDetailPage(),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }

          return const Center(
            child: Text('Loading Pokémon...'),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String? errorMessage,
  ) {
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
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Unable to load Pokémon.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<PokemonProvider>().fetchPokemon();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}