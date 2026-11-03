/// Traduz o código de erro do Firestore para uma mensagem em pt-BR.
String firestoreErrorMessage(String code) {
  return switch (code) {
    'permission-denied' => 'Você não tem permissão para fazer isso.',
    'unavailable' => 'Sem conexão com a internet.',
    'not-found' => 'Registro não encontrado.',
    _ => 'Algo deu errado. Tente novamente.',
  };
}
