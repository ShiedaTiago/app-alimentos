import 'package:firebase_auth/firebase_auth.dart';

import '../core/app_exception.dart';
import '../core/auth_errors.dart';
import 'user_service.dart';

/// Única camada que fala com o FirebaseAuth. Converte erros técnicos em
/// [AppException] com mensagem em pt-BR.
class AuthService {
  AuthService(this._userService, {FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final UserService _userService;
  final FirebaseAuth _auth;

  Stream<User?> get authChanges => _auth.authStateChanges();

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _guard(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _userService.createIfMissing(
        uid: credential.user!.uid,
        name: name.trim(),
        email: email.trim(),
      );
    });
  }

  Future<void> signIn({required String email, required String password}) {
    return _guard(() async {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      // Garante o documento mesmo se o cadastro foi interrompido no meio.
      await _userService.createIfMissing(
        uid: user.uid,
        name: user.displayName ?? email.trim().split('@').first,
        email: user.email ?? email.trim(),
      );
    });
  }

  Future<void> sendPasswordReset(String email) {
    return _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));
  }

  Future<void> signOut() => _auth.signOut();

  // FirebaseAuthException e erros do Firestore herdam de FirebaseException.
  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseException catch (error) {
      throw AppException(authErrorMessage(error.code));
    }
  }
}
