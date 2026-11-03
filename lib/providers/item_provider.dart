import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/app_exception.dart';
import '../models/food_item.dart';
import '../models/storage_place.dart';
import '../services/item_service.dart';
import '../services/product_lookup_service.dart';
import 'household_provider.dart';

/// Alimentos ativos e locais da casa atual, em tempo real.
/// Troca as assinaturas sozinho quando o usuário muda de casa ou sai.
class ItemProvider extends ChangeNotifier {
  ItemProvider(
    this._service,
    this._household, {
    ProductLookupService? productLookup,
  }) : _productLookup = productLookup ?? ProductLookupService() {
    _household.addListener(_onHouseholdChanged);
    _onHouseholdChanged();
  }

  final ItemService _service;
  final ProductLookupService _productLookup;
  final HouseholdProvider _household;

  StreamSubscription<List<FoodItem>>? _itemsSubscription;
  StreamSubscription<List<StoragePlace>>? _storagesSubscription;
  String? _householdId;

  List<FoodItem> _items = const [];
  List<StoragePlace> _storages = const [];
  bool _isLoading = true;
  bool _isBusy = false;
  String? _loadError; // erro ao carregar a lista
  String? _error; // erro da última ação (salvar, excluir...)

  List<FoodItem> get items => _items;
  List<StoragePlace> get storages => _storages;
  bool get isLoading => _isLoading;
  bool get isBusy => _isBusy;
  String? get loadError => _loadError;
  String? get error => _error;

  void clearError() => _error = null;

  FoodItem? itemById(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// Histórico para autocompletar. Se falhar, o formulário só fica sem sugestões.
  Future<List<FoodItem>> loadHistory() async {
    final id = _householdId;
    if (id == null) return const [];
    try {
      return await _service.fetchRecentItems(id);
    } on AppException {
      return const [];
    }
  }

  /// Busca o produto do código lido. Em caso de falha, guarda a mensagem em
  /// [error] e retorna `null` (o usuário preenche à mão).
  Future<ProductInfo?> lookupBarcode(String barcode) async {
    _isBusy = true;
    _error = null;
    notifyListeners();
    try {
      return await _productLookup.lookup(barcode);
    } on AppException catch (e) {
      _error = e.message;
      return null;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  /// Cria quando o `id` está vazio; senão, edita.
  Future<bool> save(FoodItem item) => _run(() async {
    if (item.id.isEmpty) {
      await _service.create(_householdId!, item);
    } else {
      await _service.update(_householdId!, item);
    }
  });

  Future<bool> delete(String itemId) =>
      _run(() => _service.delete(_householdId!, itemId));

  Future<bool> close(String itemId, ItemStatus status) =>
      _run(() => _service.close(_householdId!, itemId, status));

  void _onHouseholdChanged() {
    final id = _household.householdId;
    if (id == _householdId) return;
    _householdId = id;
    _cancelSubscriptions();
    _items = const [];
    _storages = const [];
    _loadError = null;
    _isLoading = id != null;
    if (id != null) {
      _itemsSubscription = _service
          .watchActiveItems(id)
          .listen(
            (items) {
              _items = items;
              _isLoading = false;
              _loadError = null;
              notifyListeners();
            },
            onError: (Object e) {
              _isLoading = false;
              _loadError = e is AppException
                  ? e.message
                  : 'Não foi possível carregar os alimentos.';
              notifyListeners();
            },
          );
      _storagesSubscription = _service.watchStorages(id).listen((storages) {
        _storages = storages;
        notifyListeners();
      }, onError: (_) {});
    }
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    _isBusy = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  void _cancelSubscriptions() {
    _itemsSubscription?.cancel();
    _storagesSubscription?.cancel();
    _itemsSubscription = null;
    _storagesSubscription = null;
  }

  @override
  void dispose() {
    _household.removeListener(_onHouseholdChanged);
    _cancelSubscriptions();
    super.dispose();
  }
}
