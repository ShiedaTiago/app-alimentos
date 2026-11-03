/// Converte o texto salvo no Firestore de volta para o enum.
/// Se o texto for desconhecido, devolve [fallback].
T enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}
