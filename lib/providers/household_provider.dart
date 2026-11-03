import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/app_exception.dart';
import '../models/app_user.dart';
import '../models/household.dart';
import '../services/household_service.dart';
import 'auth_provider.dart';

/// Casa do usuário logado. Escuta `users/{uid}` para saber o `householdId` e,
/// quando existe, escuta a própria casa em tempo real.
class HouseholdProvider extends ChangeNotifier {
  HouseholdProvider(this._service, this._auth) {
    _auth.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  final HouseholdService _service;
  final AuthProvider _auth;

  StreamSubscription<AppUser?>? _userSubscription;
  StreamSubscription<Household?>? _householdSubscription;
  String? _uid;

  AppUser? _profile;
  Household? _household;
  bool _isReady = false; // false até o perfil do usuário ser lido
  bool _isBusy = false;
  String? _error;

  AppUser? get profile => _profile;
  Household? get household => _household;
  String? get householdId => _profile?.householdId;
  bool get hasHousehold => householdId != null;
  bool get isReady => _isReady;
  bool get isBusy => _isBusy;
  String? get error => _error;

  void clearError() => _error = null;

  Future<bool> create(String name) =>
      _run(() => _service.create(uid: _uid!, name: name));

  Future<bool> join(String code) =>
      _run(() => _service.join(uid: _uid!, code: code));

  Future<List<AppUser>> fetchMembers() =>
      _service.fetchMembers(_household?.memberIds ?? const []);

  // Troca de usuário (login/logout): refaz as assinaturas do Firestore.
  void _onAuthChanged() {
    final uid = _auth.user?.uid;
    if (uid == _uid) return;
    _uid = uid;
    _cancelSubscriptions();
    _profile = null;
    _household = null;
    _isReady = false;
    if (uid != null) {
      // onError evita travar no splash se o Firestore recusar a leitura.
      _userSubscription = _service
          .watchUser(uid)
          .listen(_onProfile, onError: (_) => _onProfile(null));
    }
    notifyListeners();
  }

  void _onProfile(AppUser? profile) {
    final previousId = _profile?.householdId;
    _profile = profile;
    _isReady = true;
    final newId = profile?.householdId;
    if (newId != previousId) {
      _householdSubscription?.cancel();
      _household = null;
      if (newId != null) {
        _householdSubscription = _service.watchHousehold(newId).listen((h) {
          _household = h;
          notifyListeners();
        }, onError: (_) {});
      }
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
    _userSubscription?.cancel();
    _householdSubscription?.cancel();
    _userSubscription = null;
    _householdSubscription = null;
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _cancelSubscriptions();
    super.dispose();
  }
}
