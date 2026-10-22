import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/favorites_panel.dart';
import '../models/pokemon.dart';
import '../providers/pokedex_provider.dart';

class PokemonDetailPage extends ConsumerWidget {
  const PokemonDetailPage({super.key});

  void _showNicknameEditor(
    BuildContext context,
    WidgetRef ref,
    Pokemon pokemon,
    String? currentNickname,
  ) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return _NicknameEditorDialog(
          initialNickname: currentNickname,
          onSave: (String value) {
            ref.read(pokedexProvider.notifier).setNickname(pokemon.id, value);
            Navigator.of(dialogContext).pop();
          },
          onRemove: () {
            ref.read(pokedexProvider.notifier).removeNickname(pokemon.id);
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PokedexState state = ref.watch(pokedexProvider);
    final Pokemon? pokemon = state.selectedPokemon;

    return Scaffold(
      appBar: AppBar(
        title: Text(pokemon?.name.toUpperCase() ?? 'Pokémon Details'),
        actions: <Widget>[
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
            onPokemonSelected: (Pokemon selected) {
              ref.read(pokedexProvider.notifier).selectPokemon(selected.id);
            },
          ),
          Expanded(
            child: pokemon == null
                ? const Center(child: Text('No Pokémon selected. Return to the list and choose one.'))
                : _buildDetails(context, ref, state, pokemon),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(
    BuildContext context,
    WidgetRef ref,
    PokedexState state,
    Pokemon pokemon,
  ) {
    final String? nickname = state.nicknameFor(pokemon.id);
    final bool isFavorite = state.isFavorite(pokemon.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            children: <Widget>[
              SizedBox(
                width: 260,
                height: 260,
                child: pokemon.image.isEmpty
                    ? const Icon(Icons.catching_pokemon, size: 120)
                    : Image.network(
                        pokemon.image,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported_outlined,
                            size: 120,
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                pokemon.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (nickname != null) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  'Nickname: $nickname',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Pokémon ID: #${pokemon.id.toString().padLeft(3, '0')}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 18),
              Text('Type${pokemon.types.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: pokemon.types
                    .map((String type) => Chip(label: Text(_capitalize(type))))
                    .toList(),
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  FilledButton.icon(
                    onPressed: () {
                      ref
                          .read(pokedexProvider.notifier)
                          .toggleFavorite(pokemon.id);
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                    ),
                    label: Text(
                      isFavorite ? 'Remove favorite' : 'Add to favorites',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showNicknameEditor(
                      context,
                      ref,
                      pokemon,
                      nickname,
                    ),
                    icon: const Icon(Icons.edit),
                    label: Text(
                      nickname == null ? 'Add nickname' : 'Edit nickname',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}

class _NicknameEditorDialog extends StatefulWidget {
  const _NicknameEditorDialog({
    required this.initialNickname,
    required this.onSave,
    required this.onRemove,
  });

  final String? initialNickname;
  final ValueChanged<String> onSave;
  final VoidCallback onRemove;

  @override
  State<_NicknameEditorDialog> createState() => _NicknameEditorDialogState();
}

class _NicknameEditorDialogState extends State<_NicknameEditorDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNickname ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialNickname == null ? 'Add Pokémon nickname' : 'Edit Pokémon nickname',
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Nickname',
          hintText: 'Enter a custom nickname',
        ),
        onSubmitted: widget.onSave,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (widget.initialNickname != null)
          TextButton(
            onPressed: widget.onRemove,
            child: const Text('Remove nickname'),
          ),
        FilledButton(
          onPressed: () => widget.onSave(_controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
