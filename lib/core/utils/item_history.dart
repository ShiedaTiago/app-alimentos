import '../../models/food_item.dart';
import 'text_utils.dart';

/// Itens já cadastrados cujo nome combina com [query] (RF20).
/// Um por nome (o mais recente), primeiro os que começam com o texto digitado.
List<FoodItem> historyMatches(
  List<FoodItem> history,
  String query, {
  int limit = 5,
}) {
  final term = normalizeText(query);
  if (term.isEmpty) return const [];

  final recentFirst = [...history]
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  final seen = <String>{};
  final starts = <FoodItem>[];
  final contains = <FoodItem>[];
  for (final item in recentFirst) {
    final name = normalizeText(item.name);
    if (!seen.add(name)) continue;
    if (name.startsWith(term)) {
      starts.add(item);
    } else if (name.contains(term)) {
      contains.add(item);
    }
  }
  return [...starts, ...contains].take(limit).toList();
}
