import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_alimentos/core/auth_errors.dart';

void main() {
  test('traduz os códigos conhecidos do Firebase', () {
    expect(authErrorMessage('invalid-email'), 'E-mail inválido.');
    expect(authErrorMessage('invalid-credential'), 'E-mail ou senha incorretos.');
    expect(authErrorMessage('wrong-password'), 'E-mail ou senha incorretos.');
    expect(authErrorMessage('user-not-found'), 'E-mail ou senha incorretos.');
    expect(authErrorMessage('email-already-in-use'), 'Este e-mail já está cadastrado.');
    expect(authErrorMessage('too-many-requests'), contains('Muitas tentativas'));
    expect(authErrorMessage('network-request-failed'), 'Sem conexão com a internet.');
  });

  test('códigos desconhecidos viram mensagem genérica', () {
    expect(authErrorMessage('qualquer-coisa'), 'Algo deu errado. Tente novamente.');
  });
}
