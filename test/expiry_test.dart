import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_alimentos/core/utils/date_utils.dart';
import 'package:gestao_alimentos/core/utils/expiry.dart';
import 'package:gestao_alimentos/models/food_item.dart';
import 'package:gestao_alimentos/models/storage_place.dart';

import 'support/food_item_fixture.dart';

void main() {
  // "Hoje" fixo, com hora no meio do dia, para provar que a hora é ignorada.
  final today = DateTime(2026, 11, 10, 15, 30);
  DateTime inDays(int days) => DateTime(2026, 11, 10 + days);

  group('daysUntil', () {
    test('conta por data, sem horas', () {
      expect(daysUntil(inDays(0), today: today), 0);
      expect(daysUntil(inDays(1), today: today), 1);
      expect(daysUntil(inDays(-1), today: today), -1);
      expect(daysUntil(DateTime(2026, 11, 10, 23, 59), today: today), 0);
    });
  });

  group('expiryStatusFor (RN01)', () {
    test('vencido quando dias < 0', () {
      expect(expiryStatusFor(inDays(-1), today: today), ExpiryStatus.expired);
      expect(expiryStatusFor(inDays(-30), today: today), ExpiryStatus.expired);
    });
    test('crítico de 0 a 2 dias', () {
      expect(expiryStatusFor(inDays(0), today: today), ExpiryStatus.critical);
      expect(expiryStatusFor(inDays(2), today: today), ExpiryStatus.critical);
    });
    test('atenção de 3 a 5 dias', () {
      expect(expiryStatusFor(inDays(3), today: today), ExpiryStatus.warning);
      expect(expiryStatusFor(inDays(5), today: today), ExpiryStatus.warning);
    });
    test('ok acima de 5 dias', () {
      expect(expiryStatusFor(inDays(6), today: today), ExpiryStatus.ok);
      expect(expiryStatusFor(inDays(100), today: today), ExpiryStatus.ok);
    });
  });

  test('expiryStatusOf usa a validade do item', () {
    final item = buildItem(expiresAt: inDays(1));
    expect(expiryStatusOf(item, today: today), ExpiryStatus.critical);
  });

  group('suggestShelfDays (RN05)', () {
    test('carnes, aves e peixes', () {
      expect(suggestShelfDays(FoodCategory.meat, StorageType.fridge), 3);
      expect(suggestShelfDays(FoodCategory.meat, StorageType.freezer), 120);
      expect(suggestShelfDays(FoodCategory.poultry, StorageType.fridge), 2);
      expect(suggestShelfDays(FoodCategory.fish, StorageType.freezer), 90);
    });
    test('laticínios, frutas/verduras e sobras', () {
      expect(suggestShelfDays(FoodCategory.dairy, StorageType.fridge), 5);
      expect(suggestShelfDays(FoodCategory.dairy, StorageType.freezer), isNull);
      expect(suggestShelfDays(FoodCategory.produce, StorageType.pantry), 5);
      expect(suggestShelfDays(FoodCategory.produce, StorageType.freezer), 60);
      expect(suggestShelfDays(FoodCategory.leftovers, StorageType.fridge), 3);
    });
    test('sem sugestão para os demais', () {
      expect(suggestShelfDays(FoodCategory.other, StorageType.fridge), isNull);
      expect(suggestShelfDays(FoodCategory.grains, StorageType.pantry), isNull);
      expect(suggestShelfDays(FoodCategory.meat, StorageType.pantry), isNull);
    });
  });
}
