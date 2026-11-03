import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_alimentos/core/utils/expiry_alert.dart';

import 'support/food_item_fixture.dart';

void main() {
  final day = DateTime(2026, 11, 10, 9);

  test('sem itens vencendo em até 2 dias retorna null', () {
    final items = [
      buildItem(name: 'Arroz', expiresAt: DateTime(2026, 11, 13)),
      buildItem(name: 'Iogurte', expiresAt: DateTime(2026, 11, 9)), // vencido
    ];
    expect(expiryAlertText(items, day), isNull);
  });

  test('um item usa singular', () {
    final items = [buildItem(name: 'Leite', expiresAt: DateTime(2026, 11, 10))];
    expect(expiryAlertText(items, day), 'Leite vence em até 2 dias.');
  });

  test('ordena por validade e inclui o limite de 2 dias', () {
    final items = [
      buildItem(name: 'Queijo', expiresAt: DateTime(2026, 11, 12)),
      buildItem(name: 'Leite', expiresAt: DateTime(2026, 11, 10)),
    ];
    expect(expiryAlertText(items, day), 'Leite, Queijo vencem em até 2 dias.');
  });

  test('mostra no máximo 3 nomes e resume o resto', () {
    final items = [
      for (final name in ['A', 'B', 'C', 'D', 'E'])
        buildItem(name: name, expiresAt: DateTime(2026, 11, 11)),
    ];
    expect(
      expiryAlertText(items, day),
      'A, B, C e mais 2 vencem em até 2 dias.',
    );
  });
}
