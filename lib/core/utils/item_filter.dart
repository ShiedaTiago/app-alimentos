import '../../models/food_item.dart';
import 'expiry.dart';
import 'text_utils.dart';

/// Aplica os filtros da lista (RF15). Filtro `null` = não filtra.
/// A busca ignora acentos e maiúsculas. Mantém a ordem recebida (por validade).
List<FoodItem> filterItems(
  List<FoodItem> items, {
  String? storageId,
  ExpiryStatus? status,
  String query = '',
  DateTime? today,
}) {
  final search = normalizeText(query);
  return [
    for (final item in items)
      if ((storageId == null || item.storageId == storageId) &&
          (status == null || expiryStatusOf(item, today: today) == status) &&
          (search.isEmpty || normalizeText(item.name).contains(search)))
        item,
  ];
}
