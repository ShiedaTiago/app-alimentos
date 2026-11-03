import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleInitialized = false;

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

  /// Abre o seletor de contas do Google. Se o usuário cancelar, não faz nada.
  Future<void> signInWithGoogle() {
    return _guard(() async {
      final GoogleSignInAccount account;
      try {
        await _ensureGoogleInitialized();
        account = await _googleSignIn.authenticate();
      } on GoogleSignInException catch (error) {
        if (error.code == GoogleSignInExceptionCode.canceled) return;
        throw const AppException('Não foi possível entrar com o Google.');
      }

      // O Google devolve um idToken; o Firebase troca por uma sessão própria.
      final credential = GoogleAuthProvider.credential(
        idToken: account.authentication.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      final user = result.user!;
      await _userService.createIfMissing(
        uid: user.uid,
        name: user.displayName ?? account.displayName ?? account.email,
        email: user.email ?? account.email,
      );
    });
  }

  Future<void> sendPasswordReset(String email) {
    return _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));
  }

  // Sai também do Google; senão o próximo login entra direto na mesma conta.
  Future<void> signOut() async {
    if (_googleInitialized) await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Na versão 7 do google_sign_in, initialize() precisa rodar uma única vez.
  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await _googleSignIn.initialize();
    _googleInitialized = true;
  }

  // FirebaseAuthException e erros do Firestore herdam de FirebaseException.
  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseException catch (error) {
      throw AppException(authErrorMessage(error.code));
    }
  }
}
