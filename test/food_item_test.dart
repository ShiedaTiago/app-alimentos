import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_alimentos/models/food_item.dart';

import 'support/food_item_fixture.dart';

void main() {
  test('toMap e fromMap preservam os dados e salvam enums como texto', () {
    final item = buildItem(name: 'Frango', category: FoodCategory.poultry);
    final map = item.toMap();

    expect(map['category'], 'poultry');
    expect(map['status'], 'active');
    expect(map['unit'], 'unit');
    expect(map['expiresAt'], isA<Timestamp>());

    final restored = FoodItem.fromMap('x1', map);
    expect(restored.id, 'x1');
    expect(restored.name, 'Frango');
    expect(restored.category, FoodCategory.poultry);
    expect(restored.expiresAt, item.expiresAt);
    expect(restored.closedAt, isNull);
  });

  test('enum desconhecido cai no valor padrão', () {
    final map = buildItem().toMap()..['category'] = 'inexistente';
    expect(FoodItem.fromMap('x', map).category, FoodCategory.other);
  });

  test('copyWith marca como consumido sem alterar o original', () {
    final item = buildItem();
    final closed = item.copyWith(
      status: ItemStatus.consumed,
      closedAt: DateTime(2026, 11, 2),
    );
    expect(closed.status, ItemStatus.consumed);
    expect(closed.closedAt, DateTime(2026, 11, 2));
    expect(item.status, ItemStatus.active);
  });
}
