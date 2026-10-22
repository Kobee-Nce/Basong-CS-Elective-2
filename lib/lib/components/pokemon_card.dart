import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/pokedex_provider.dart';

class PokemonCard extends ConsumerWidget {
  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.onTap,
  });

  final Pokemon pokemon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PokedexState state = ref.watch(pokedexProvider);
    final bool isFavorite = state.isFavorite(pokemon.id);
    final String? nickname = state.nicknameFor(pokemon.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: pokemon.image.isEmpty
                        ? const Icon(Icons.catching_pokemon, size: 76)
                        : Image.network(
                            pokemon.image,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image_not_supported_outlined,
                                size: 60,
                              );
                            },
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    pokemon.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (nickname != null) ...<Widget>[
                    const SizedBox(height: 3),
                    Text(
                      'Nickname: $nickname',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '#${pokemon.id.toString().padLeft(3, '0')}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  ref.read(pokedexProvider.notifier).toggleFavorite(pokemon.id);
                },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? Colors.red
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
