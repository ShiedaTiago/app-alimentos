import '../../models/food_item.dart';
import 'date_utils.dart';

/// Itens vencem "em breve" para o alerta diário (RF22): de hoje até 2 dias.
const alertMaxDays = 2;

/// Texto do alerta para o dia [day], ou `null` se nada vence em até 2 dias.
/// Vencidos ficam de fora: já aparecem na Home e repetiriam todo dia.
String? expiryAlertText(List<FoodItem> items, DateTime day) {
  final expiring = items.where((item) {
    final days = daysUntil(item.expiresAt, today: day);
    return days >= 0 && days <= alertMaxDays;
  }).toList()..sort((a, b) => a.expiresAt.compareTo(b.expiresAt));
  if (expiring.isEmpty) return null;

  const maxNames = 3;
  final names = expiring.take(maxNames).map((item) => item.name).join(', ');
  final others = expiring.length - maxNames;
  final suffix = others > 0 ? ' e mais $others' : '';
  final verb = expiring.length == 1 ? 'vence' : 'vencem';
  return '$names$suffix $verb em até $alertMaxDays dias.';
}
