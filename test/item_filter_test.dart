import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_alimentos/core/utils/item_filter.dart';
import 'package:gestao_alimentos/models/food_item.dart';

import 'support/food_item_fixture.dart';

void main() {
  final today = DateTime(2026, 11, 10);
  final items = [
    buildItem(name: 'Frango', expiresAt: DateTime(2026, 11, 9)), // vencido
    buildItem(
      name: 'Feijão',
      expiresAt: DateTime(2026, 11, 11),
      storageId: 'pantry1',
    ), // crítico
    buildItem(name: 'Leite', expiresAt: DateTime(2026, 12, 1)), // ok
  ];
  List<String> names(List<FoodItem> list) => list.map((i) => i.name).toList();

  test('sem filtros devolve tudo na mesma ordem', () {
    expect(names(filterItems(items, today: today)), [
      'Frango',
      'Feijão',
      'Leite',
    ]);
  });

  test('filtra por local', () {
    expect(names(filterItems(items, storageId: 'pantry1', today: today)), [
      'Feijão',
    ]);
  });

  test('filtra por status de validade', () {
    expect(
      names(filterItems(items, status: ExpiryStatus.expired, today: today)),
      ['Frango'],
    );
  });

  test('busca ignora acento e maiúsculas', () {
    expect(names(filterItems(items, query: ' FEIJAO', today: today)), [
      'Feijão',
    ]);
  });

  test('combina filtros', () {
    expect(
      filterItems(
        items,
        storageId: 'pantry1',
        status: ExpiryStatus.ok,
        today: today,
      ),
      isEmpty,
    );
  });
}
