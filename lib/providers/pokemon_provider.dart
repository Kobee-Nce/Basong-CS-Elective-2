import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../services/pokeapi_service.dart';

enum PokemonStatus {
  initial,
  loading,
  success,
  error,
}

class PokemonProvider extends ChangeNotifier {
  final PokeApiService _apiService = PokeApiService();

  List<Pokemon> _pokemon = [];

  Pokemon? _selectedPokemon;

  PokemonStatus _status = PokemonStatus.initial;

  String? _errorMessage;

  List<Pokemon> get pokemon => List.unmodifiable(_pokemon);

  Pokemon? get selectedPokemon => _selectedPokemon;

  PokemonStatus get status => _status;

  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == PokemonStatus.loading;

  bool get hasError => _status == PokemonStatus.error;

  bool get hasData => _status == PokemonStatus.success;

  Future<void> fetchPokemon() async {
    _status = PokemonStatus.loading;
    _errorMessage = null;

    notifyListeners();

    try {
      _pokemon = await _apiService.fetchPokemon();

      if (_pokemon.isEmpty) {
        _status = PokemonStatus.error;
        _errorMessage = 'No Pokémon were found.';
      } else {
        _status = PokemonStatus.success;
      }
    } catch (error) {
      _status = PokemonStatus.error;
      _errorMessage = error.toString();
    }

    notifyListeners();
  }

  Future<void> refreshPokemon() async {
    await fetchPokemon();
  }

  void selectPokemon(Pokemon pokemon) {
    _selectedPokemon = pokemon;

    notifyListeners();
  }

  void clearSelectedPokemon() {
    _selectedPokemon = null;

    notifyListeners();
  }
}