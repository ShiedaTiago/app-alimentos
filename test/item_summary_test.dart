import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_alimentos/core/utils/item_summary.dart';

import 'support/food_item_fixture.dart';

void main() {
  final today = DateTime(2026, 11, 10);
  final items = [
    buildItem(name: 'Frango', expiresAt: DateTime(2026, 11, 8)), // vencido
    buildItem(name: 'Arroz', expiresAt: DateTime(2027, 3, 1)), // ok
    buildItem(name: 'Iogurte', expiresAt: DateTime(2026, 11, 14)), // atenção
    buildItem(name: 'Leite', expiresAt: DateTime(2026, 11, 10)), // crítico
  ];

  test('summarizeItems conta vencidos, vencendo e total', () {
    final summary = summarizeItems(items, today: today);
    expect(summary.expired, 1);
    expect(summary.expiringSoon, 2);
    expect(summary.total, 4);
  });

  test('summarizeItems com lista vazia zera tudo', () {
    final summary = summarizeItems(const [], today: today);
    expect([summary.expired, summary.expiringSoon, summary.total], [0, 0, 0]);
  });

  test('consumeFirst ordena por validade e ignora vencidos', () {
    final names = consumeFirst(items, today: today).map((i) => i.name);
    expect(names, ['Leite', 'Iogurte', 'Arroz']);
  });

  test('consumeFirst respeita o limite', () {
    expect(consumeFirst(items, limit: 1, today: today).single.name, 'Leite');
  });
}
