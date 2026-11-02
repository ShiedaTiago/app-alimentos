import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/app_exception.dart';
import '../services/auth_service.dart';

/// Estado de autenticação: quem está logado, se está carregando e o último erro.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service) {
    _subscription = _service.authChanges.listen((user) {
      _user = user;
      _isReady = true;
      notifyListeners();
    });
  }

  final AuthService _service;
  late final StreamSubscription<User?> _subscription;

  User? _user;
  bool _isReady = false; // false até o Firebase dizer se há sessão salva
  bool _isBusy = false;
  String? _error;

  User? get user => _user;
  bool get isReady => _isReady;
  bool get isLoggedIn => _user != null;
  bool get isBusy => _isBusy;
  String? get error => _error;

  /// Limpa o erro sem notificar (usado ao abrir uma tela, antes do build).
  void clearError() => _error = null;

  Future<bool> signIn(String email, String password) {
    return _run(() => _service.signIn(email: email, password: password));
  }

  Future<bool> register(String name, String email, String password) {
    return _run(
      () => _service.register(name: name, email: email, password: password),
    );
  }

  Future<bool> sendPasswordReset(String email) {
    return _run(() => _service.sendPasswordReset(email));
  }

  Future<void> signOut() => _service.signOut();

  // Liga o "carregando", executa a ação e guarda a mensagem se der erro.
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
    _subscription.cancel();
    super.dispose();
  }
}
