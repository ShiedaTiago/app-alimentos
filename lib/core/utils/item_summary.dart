import '../../models/food_item.dart';
import 'expiry.dart';

/// Números do resumo da Home (RF21).
class ItemSummary {
  const ItemSummary({
    required this.expired,
    required this.expiringSoon,
    required this.total,
  });

  final int expired;
  final int expiringSoon; // críticos + atenção (até 5 dias)
  final int total;
}

ItemSummary summarizeItems(List<FoodItem> items, {DateTime? today}) {
  var expired = 0;
  var expiringSoon = 0;
  for (final item in items) {
    switch (expiryStatusOf(item, today: today)) {
      case ExpiryStatus.expired:
        expired++;
      case ExpiryStatus.critical || ExpiryStatus.warning:
        expiringSoon++;
      case ExpiryStatus.ok:
        break;
    }
  }
  return ItemSummary(
    expired: expired,
    expiringSoon: expiringSoon,
    total: items.length,
  );
}

/// "Consuma primeiro": os [limit] próximos a vencer que ainda não venceram.
/// Vencidos ficam de fora: o certo é descartar, não consumir.
List<FoodItem> consumeFirst(
  List<FoodItem> items, {
  int limit = 5,
  DateTime? today,
}) {
  final notExpired = [
    for (final item in items)
      if (expiryStatusOf(item, today: today) != ExpiryStatus.expired) item,
  ]..sort((a, b) => a.expiresAt.compareTo(b.expiresAt));
  return notExpired.take(limit).toList();
}
