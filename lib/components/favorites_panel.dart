import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/pokedex_provider.dart';

class FavoritesPanel extends ConsumerWidget {
  const FavoritesPanel({
    super.key,
    required this.onPokemonSelected,
  });

  final ValueChanged<Pokemon> onPokemonSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PokedexState state = ref.watch(pokedexProvider);
    final List<Pokemon> favorites = state.favorites;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          InkWell(
            onTap: () {
              ref.read(pokedexProvider.notifier).toggleFavoritesPanel();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.favorite,
                    color: Colors.red.shade400,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Favorites (${favorites.length})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    state.favoritesExpanded ? 'Hide' : 'Show',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    state.favoritesExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                  ),
                ],
              ),
            ),
          ),
          if (state.favoritesExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: favorites.isEmpty
                  ? const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No favorite Pokémon yet. Tap a heart on a Pokémon card to add one.',
                        ),
                      ),
                    )
                  : ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 128),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: favorites.map((Pokemon pokemon) {
                            final String? nickname =
                                state.nicknameFor(pokemon.id);
                            final String label = nickname == null
                                ? pokemon.name.toUpperCase()
                                : '${nickname} (${pokemon.name.toUpperCase()})';
                            return ActionChip(
                              avatar: SizedBox(
                                width: 28,
                                height: 28,
                                child: pokemon.image.isEmpty
                                    ? const Icon(Icons.catching_pokemon)
                                    : Image.network(
                                        pokemon.image,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.catching_pokemon,
                                            size: 20,
                                          );
                                        },
                                      ),
                              ),
                              label: Text(label),
                              onPressed: () => onPokemonSelected(pokemon),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
            ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
