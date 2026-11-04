import 'text_utils.dart';

/// Palavras de alimentos comuns, usadas para detectar erros de digitação.
/// Não limita o que o usuário pode cadastrar: só alimenta a sugestão
/// "Você quis dizer...?".
const foodCatalogWords = [
  'abacate',
  'abacaxi',
  'abobrinha',
  'abóbora',
  'açúcar',
  'alface',
  'alho',
  'amendoim',
  'arroz',
  'atum',
  'aveia',
  'azeite',
  'azeitona',
  'bacon',
  'banana',
  'batata',
  'beterraba',
  'biscoito',
  'bolacha',
  'bolo',
  'brócolis',
  'café',
  'carne',
  'cebola',
  'cenoura',
  'cereal',
  'cerveja',
  'chocolate',
  'chuchu',
  'coco',
  'condensado',
  'couve',
  'creme',
  'desnatado',
  'espaguete',
  'espinafre',
  'ervilha',
  'farinha',
  'feijão',
  'fermento',
  'frango',
  'fubá',
  'goiaba',
  'granola',
  'guacamole',
  'hambúrguer',
  'integral',
  'iogurte',
  'jiló',
  'laranja',
  'leite',
  'lentilha',
  'limão',
  'linguiça',
  'maçã',
  'macarrão',
  'mamão',
  'mandioca',
  'manga',
  'manteiga',
  'margarina',
  'melancia',
  'melão',
  'milho',
  'molho',
  'mortadela',
  'morango',
  'mostarda',
  'ovo',
  'ovos',
  'pão',
  'patinho',
  'peixe',
  'pepino',
  'pera',
  'pescada',
  'pimentão',
  'presunto',
  'queijo',
  'quiabo',
  'refrigerante',
  'repolho',
  'requeijão',
  'ricota',
  'salada',
  'salmão',
  'salsicha',
  'sorvete',
  'sal',
  'suco',
  'tilápia',
  'tomate',
  'tapioca',
  'uva',
  'vagem',
  'vinagre',
];

/// Nome com a palavra corrigida, quando há erro de digitação provável.
class NameCorrection {
  const NameCorrection(this.suggested);
  final String suggested;
}

/// Distância de edição entre duas strings (Levenshtein com troca de letras
/// vizinhas contando como 1 erro: "liete" -> "leite").
int levenshtein(String a, String b) {
  if (a == b) return 0;
  final d = List.generate(
    a.length + 1,
    (i) =>
        List<int>.generate(b.length + 1, (j) => i == 0 ? j : (j == 0 ? i : 0)),
  );
  for (var i = 1; i <= a.length; i++) {
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      var best = [
        d[i - 1][j] + 1,
        d[i][j - 1] + 1,
        d[i - 1][j - 1] + cost,
      ].reduce((x, y) => x < y ? x : y);
      if (i > 1 && j > 1 && a[i - 1] == b[j - 2] && a[i - 2] == b[j - 1]) {
        final swap = d[i - 2][j - 2] + 1;
        if (swap < best) best = swap;
      }
      d[i][j] = best;
    }
  }
  return d[a.length][b.length];
}

/// Sugere uma correção para [name] comparando cada palavra com o catálogo
/// (mais [extraWords], ex.: nomes que a casa já cadastrou).
/// Retorna `null` se todas as palavras são conhecidas ou nenhuma está perto.
/// "liete integral" -> "leite integral".
NameCorrection? suggestCorrection(
  String name, {
  Iterable<String> extraWords = const [],
}) {
  final known = <String, String>{}; // normalizada -> forma de exibição
  for (final w in [...foodCatalogWords, ...extraWords]) {
    known.putIfAbsent(normalizeText(w), () => w);
  }

  var changed = false;
  final words = name.trim().split(RegExp(r'\s+'));
  final result = <String>[];
  for (final word in words) {
    final norm = normalizeText(word);
    // Palavras curtas e conhecidas passam; evita "corrigir" ao acaso.
    if (norm.length < 4 || known.containsKey(norm)) {
      result.add(word);
      continue;
    }
    final maxDistance = norm.length >= 7 ? 2 : 1;
    String? best;
    var bestDistance = maxDistance + 1;
    for (final entry in known.entries) {
      if ((entry.key.length - norm.length).abs() > maxDistance) continue;
      final d = levenshtein(norm, entry.key);
      if (d < bestDistance) {
        bestDistance = d;
        best = entry.value;
      }
    }
    if (best == null) {
      result.add(word);
      continue;
    }
    changed = true;
    final capitalized =
        word[0] == word[0].toUpperCase() && word[0] != word[0].toLowerCase();
    result.add(capitalized ? best[0].toUpperCase() + best.substring(1) : best);
  }
  return changed ? NameCorrection(result.join(' ')) : null;
}
