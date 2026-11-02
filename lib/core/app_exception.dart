/// Erro com mensagem amigável em pt-BR, pronta para mostrar ao usuário.
/// Os services convertem erros técnicos (Firebase, rede) em AppException.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}
