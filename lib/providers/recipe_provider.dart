import 'package:flutter/foundation.dart';

import '../models/recipe.dart';
import '../services/recipe_service.dart';
import 'item_provider.dart';

/// Sugestões de receitas, recalculadas sempre que os alimentos mudam.
class RecipeProvider extends ChangeNotifier {
  RecipeProvider(this._items, {Future<RecipeService>? serviceLoader}) {
    _items.addListener(_recompute);
    _load(serviceLoader ?? RecipeService.load());
  }

  final ItemProvider _items;
  RecipeService? _service;

  List<RecipeSuggestion> _suggestions = const [];
  bool _isLoading = true;
  String? _loadError;

  List<RecipeSuggestion> get suggestions => _suggestions;
  // Carregando enquanto a base de receitas OU os alimentos não chegaram.
  bool get isLoading => _isLoading || _items.isLoading;
  String? get loadError => _loadError ?? _items.loadError;

  RecipeSuggestion? suggestionById(String id) {
    for (final suggestion in _suggestions) {
      if (suggestion.recipe.id == id) return suggestion;
    }
    return null;
  }

  Future<void> _load(Future<RecipeService> loader) async {
    try {
      _service = await loader;
    } catch (_) {
      _loadError = 'Não foi possível carregar as receitas.';
    }
    _isLoading = false;
    _recompute();
  }

  void _recompute() {
    final service = _service;
    if (service != null) _suggestions = service.suggest(_items.items);
    notifyListeners();
  }

  @override
  void dispose() {
    _items.removeListener(_recompute);
    super.dispose();
  }
}
