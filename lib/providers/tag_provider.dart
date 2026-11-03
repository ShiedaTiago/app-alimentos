import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/app_exception.dart';
import '../models/rfid_tag.dart';
import '../services/tag_service.dart';
import 'household_provider.dart';

/// Etiquetas RFID da casa atual, em tempo real (RF25).
/// Assim como o [ItemProvider], troca a assinatura quando a casa muda.
class TagProvider extends ChangeNotifier {
  TagProvider(this._service, this._household) {
    _household.addListener(_onHouseholdChanged);
    _onHouseholdChanged();
  }

  final TagService _service;
  final HouseholdProvider _household;

  StreamSubscription<List<RfidTag>>? _subscription;
  String? _householdId;

  List<RfidTag> _tags = const [];
  bool _isLoading = true;
  bool _isBusy = false;
  String? _loadError;
  String? _error;

  List<RfidTag> get tags => _tags;
  List<RfidTag> get pendingTags =>
      _tags.where((tag) => tag.status == TagStatus.pending).toList();
  bool get isLoading => _isLoading;
  bool get isBusy => _isBusy;
  String? get loadError => _loadError;
  String? get error => _error;

  Future<bool> simulateNewTag(String storageId) =>
      _run(() => _service.simulateNewTag(_householdId!, storageId));

  Future<bool> simulateReading(RfidTag tag) =>
      _run(() => _service.simulateReading(_householdId!, tag));

  Future<bool> linkTag(String tagId, String itemId) =>
      _run(() => _service.linkTag(_householdId!, tagId, itemId));

  Future<bool> delete(String tagId) =>
      _run(() => _service.delete(_householdId!, tagId));

  void _onHouseholdChanged() {
    final id = _household.householdId;
    if (id == _householdId) return;
    _householdId = id;
    _subscription?.cancel();
    _subscription = null;
    _tags = const [];
    _loadError = null;
    _isLoading = id != null;
    if (id != null) {
      _subscription = _service
          .watchTags(id)
          .listen(
            (tags) {
              _tags = tags;
              _isLoading = false;
              _loadError = null;
              notifyListeners();
            },
            onError: (Object e) {
              _isLoading = false;
              _loadError = e is AppException
                  ? e.message
                  : 'Não foi possível carregar as etiquetas.';
              notifyListeners();
            },
          );
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

  @override
  void dispose() {
    _household.removeListener(_onHouseholdChanged);
    _subscription?.cancel();
    super.dispose();
  }
}
