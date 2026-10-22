import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/favorites_panel.dart';
import '../components/pokemon_card.dart';
import '../components/type_filter.dart';
import '../models/pokemon.dart';
import '../providers/pokedex_provider.dart';
import 'pokemon_detail_page.dart';

class PokedexPage extends ConsumerWidget {
  const PokedexPage({super.key});

  void _openPokemon(BuildContext context, WidgetRef ref, Pokemon pokemon) {
    ref.read(pokedexProvider.notifier).selectPokemon(pokemon.id);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const PokemonDetailPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PokedexState state = ref.watch(pokedexProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Fetch Pokémon again',
            onPressed: () => ref.read(pokedexProvider.notifier).fetch(),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: state.favoritesExpanded
                ? 'Collapse favorites'
                : 'Expand favorites',
            onPressed: () =>
                ref.read(pokedexProvider.notifier).toggleFavoritesPanel(),
            icon: Icon(
              state.favoritesExpanded
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          FavoritesPanel(
            onPokemonSelected: (Pokemon pokemon) {
              _openPokemon(context, ref, pokemon);
            },
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TypeFilter(),
          ),
          if (state.status == PokedexStatus.error && state.pokemon.isNotEmpty)
            MaterialBanner(
              content: Text(
                'Refresh failed: ${state.errorMessage ?? 'Unknown error'}',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => ref.read(pokedexProvider.notifier).fetch(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          Expanded(
            child: _buildPokemonContent(context, ref, state),
          ),
        ],
      ),
    );
  }

  Widget _buildPokemonContent(
    BuildContext context,
    WidgetRef ref,
    PokedexState state,
  ) {
    if (state.pokemon.isEmpty) {
      if (state.status == PokedexStatus.error) {
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.cloud_off_outlined, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Unable to load Pokémon',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage ?? 'An unexpected error occurred.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () =>
                      ref.read(pokedexProvider.notifier).fetch(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        );
      }

      if (state.status == PokedexStatus.success) {
        return RefreshIndicator(
          onRefresh: () => ref.read(pokedexProvider.notifier).fetch(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const <Widget>[
              SizedBox(
                height: 240,
                child: Center(child: Text('The API returned no Pokémon.')),
              ),
            ],
          ),
        );
      }

      return const Center(child: CircularProgressIndicator());
    }

    final List<Pokemon> visiblePokemon = state.filteredPokemon;
    if (visiblePokemon.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.read(pokedexProvider.notifier).fetch(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            const SizedBox(height: 150),
            const Center(child: Text('No Pokémon match this type filter.')),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: ref.read(pokedexProvider.notifier).clearTypeFilter,
                icon: const Icon(Icons.clear),
                label: const Text('Clear filter'),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      // Important: this calls the existing fetch() method, not a new refresh method.
      onRefresh: () => ref.read(pokedexProvider.notifier).fetch(),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 230,
          mainAxisExtent: 240,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: visiblePokemon.length,
        itemBuilder: (BuildContext context, int index) {
          final Pokemon pokemon = visiblePokemon[index];
          return PokemonCard(
            pokemon: pokemon,
            onTap: () => _openPokemon(context, ref, pokemon),
          );
        },
      ),
    );
  }
}
