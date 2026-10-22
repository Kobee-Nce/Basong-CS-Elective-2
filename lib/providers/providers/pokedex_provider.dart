import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../services/pokeapi_service.dart';

final pokeApiServiceProvider = Provider<PokeApiService>((ref) {
  final PokeApiService service = PokeApiService();
  ref.onDispose(service.dispose);
  return service;
});

final pokedexProvider = NotifierProvider<PokedexController, PokedexState>(
  PokedexController.new,
);

enum PokedexStatus {
  initial,
  loading,
  success,
  error,
}

class PokedexState {
  PokedexState({
    this.status = PokedexStatus.initial,
    List<Pokemon> pokemon = const <Pokemon>[],
    this.errorMessage,
    Map<int, String> nicknames = const <int, String>{},
    Set<int> favoriteIds = const <int>{},
    this.selectedType,
    this.selectedPokemonId,
    this.favoritesExpanded = false,
  })  : pokemon = List<Pokemon>.unmodifiable(pokemon),
        nicknames = Map<int, String>.unmodifiable(nicknames),
        favoriteIds = Set<int>.unmodifiable(favoriteIds);

  final PokedexStatus status;
  final List<Pokemon> pokemon;
  final String? errorMessage;
  final Map<int, String> nicknames;
  final Set<int> favoriteIds;
  final String? selectedType;
  final int? selectedPokemonId;
  final bool favoritesExpanded;

  List<Pokemon> get filteredPokemon {
    final String? filter = selectedType;
    if (filter == null) return pokemon;
    return pokemon.where((Pokemon item) => item.types.contains(filter)).toList();
  }

  List<String> get availableTypes {
    final Set<String> types = <String>{};
    for (final Pokemon item in pokemon) {
      types.addAll(item.types);
    }
    final List<String> sorted = types.toList()..sort();
    return sorted;
  }

  List<Pokemon> get favorites =>
      pokemon.where((Pokemon item) => favoriteIds.contains(item.id)).toList();

  Pokemon? get selectedPokemon {
    final int? selectedId = selectedPokemonId;
    if (selectedId == null) return null;
    for (final Pokemon item in pokemon) {
      if (item.id == selectedId) return item;
    }
    return null;
  }

  String? nicknameFor(int pokemonId) => nicknames[pokemonId];

  bool isFavorite(int pokemonId) => favoriteIds.contains(pokemonId);

  PokedexState copyWith({
    PokedexStatus? status,
    List<Pokemon>? pokemon,
    String? errorMessage,
    bool clearErrorMessage = false,
    Map<int, String>? nicknames,
    Set<int>? favoriteIds,
    String? selectedType,
    bool clearSelectedType = false,
    int? selectedPokemonId,
    bool? favoritesExpanded,
  }) {
    return PokedexState(
      status: status ?? this.status,
      pokemon: pokemon ?? this.pokemon,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      nicknames: nicknames ?? this.nicknames,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      selectedType:
          clearSelectedType ? null : selectedType ?? this.selectedType,
      selectedPokemonId: selectedPokemonId ?? this.selectedPokemonId,
      favoritesExpanded: favoritesExpanded ?? this.favoritesExpanded,
    );
  }
}

class PokedexController extends Notifier<PokedexState> {
  PokeApiService get _api => ref.read(pokeApiServiceProvider);

  @override
  PokedexState build() {
    // Start the initial request after the initial state has been created.
    Future<void>.microtask(fetch);
    return PokedexState();
  }

  /// The one list-fetch method. Both refresh controls call this same method.
  Future<void> fetch() async {
    state = state.copyWith(
      status: PokedexStatus.loading,
      clearErrorMessage: true,
    );

    try {
      final List<Pokemon> result = await _api.fetchPokemon();
      final String? currentFilter = state.selectedType;
      final bool filterNoLongerExists = currentFilter != null &&
          !result.any((Pokemon item) => item.types.contains(currentFilter));

      state = state.copyWith(
        pokemon: result,
        status: PokedexStatus.success,
        clearErrorMessage: true,
        clearSelectedType: filterNoLongerExists,
      );
    } catch (error) {
      state = state.copyWith(
        status: PokedexStatus.error,
        errorMessage: _friendlyError(error),
      );
    }
  }

  String _friendlyError(Object error) {
    final String message = error.toString();
    if (message.contains('SocketException') ||
        message.contains('Failed host lookup') ||
        message.contains('Connection failed') ||
        message.contains('Operation not permitted')) {
      return 'Could not connect to PokéAPI. Check your internet connection '
          'and your macOS network permission, then try again.';
    }
    return message.replaceFirst('Exception: ', '');
  }

  void setNickname(int pokemonId, String nickname) {
    final String cleaned = nickname.trim();
    if (cleaned.isEmpty) {
      removeNickname(pokemonId);
      return;
    }

    final Map<int, String> next = Map<int, String>.from(state.nicknames);
    next[pokemonId] = cleaned;
    state = state.copyWith(nicknames: next);
  }

  void removeNickname(int pokemonId) {
    if (!state.nicknames.containsKey(pokemonId)) return;
    final Map<int, String> next = Map<int, String>.from(state.nicknames)
      ..remove(pokemonId);
    state = state.copyWith(nicknames: next);
  }

  void toggleFavorite(int pokemonId) {
    final Set<int> next = Set<int>.from(state.favoriteIds);
    if (!next.add(pokemonId)) {
      next.remove(pokemonId);
    }
    state = state.copyWith(favoriteIds: next);
  }

  void setTypeFilter(String? type) {
    if (type == null || type == 'all') {
      state = state.copyWith(clearSelectedType: true);
      return;
    }
    state = state.copyWith(selectedType: type.toLowerCase());
  }

  void clearTypeFilter() {
    state = state.copyWith(clearSelectedType: true);
  }

  void selectPokemon(int pokemonId) {
    state = state.copyWith(selectedPokemonId: pokemonId);
  }

  void toggleFavoritesPanel() {
    state = state.copyWith(favoritesExpanded: !state.favoritesExpanded);
  }
}
