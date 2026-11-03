/// Traduz o código de erro do Firebase (ex.: `invalid-credential`) para uma
/// mensagem amigável em pt-BR. Tabela definida em docs/ARQUITETURA.md.
String authErrorMessage(String code) {
  return switch (code) {
    'invalid-email' => 'E-mail inválido.',
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' => 'E-mail ou senha incorretos.',
    'email-already-in-use' => 'Este e-mail já está cadastrado.',
    'weak-password' =>
      'Senha fraca. Use pelo menos 8 caracteres com letras e números.',
    'too-many-requests' =>
      'Muitas tentativas. Tente novamente em alguns minutos.',
    'network-request-failed' => 'Sem conexão com a internet.',
    _ => 'Algo deu errado. Tente novamente.',
  };
}
