const _accents = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ç': 'c',
};

/// Minúsculas e sem acento: "Feijão" vira "feijao". Usado para comparar nomes.
String normalizeText(String text) {
  final buffer = StringBuffer();
  for (final char in text.toLowerCase().split('')) {
    buffer.write(_accents[char] ?? char);
  }
  return buffer.toString().trim();
}

/// Quantidade para exibir: 2.0 vira "2"; 1.5 vira "1,5".
String formatQuantity(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toString().replaceAll('.', ',');
