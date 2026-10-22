import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pokedex_provider.dart';

class TypeFilter extends ConsumerWidget {
  const TypeFilter({super.key});

  String _label(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PokedexState state = ref.watch(pokedexProvider);
    final List<DropdownMenuItem<String>> items = <DropdownMenuItem<String>>[
      const DropdownMenuItem<String>(
        value: 'all',
        child: Text('All types'),
      ),
      ...state.availableTypes.map((String type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(_label(type)),
        );
      }),
    ];

    return DropdownButtonFormField<String>(
      value: state.selectedType ?? 'all',
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Filter by Pokémon type',
        prefixIcon: Icon(Icons.filter_list),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items,
      onChanged: state.pokemon.isEmpty
          ? null
          : (String? value) {
              ref.read(pokedexProvider.notifier).setTypeFilter(value);
            },
    );
  }
}
