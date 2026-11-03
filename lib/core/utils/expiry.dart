import '../../models/food_item.dart';
import '../../models/storage_place.dart';
import '../constants.dart';
import 'date_utils.dart';

/// Status de validade (RN01) a partir da data de validade.
/// [today] existe só para os testes poderem fixar a data.
ExpiryStatus expiryStatusFor(DateTime expiresAt, {DateTime? today}) {
  final days = daysUntil(expiresAt, today: today);
  if (days < 0) return ExpiryStatus.expired;
  if (days <= criticalMaxDays) return ExpiryStatus.critical;
  if (days <= warningMaxDays) return ExpiryStatus.warning;
  return ExpiryStatus.ok;
}

ExpiryStatus expiryStatusOf(FoodItem item, {DateTime? today}) {
  return expiryStatusFor(item.expiresAt, today: today);
}

/// Validade sugerida em dias (RN05), ou `null` se não há sugestão.
/// São estimativas: o usuário pode alterar no formulário.
int? suggestShelfDays(FoodCategory category, StorageType storage) {
  return switch (category) {
    FoodCategory.meat => switch (storage) {
        StorageType.fridge => 3,
        StorageType.freezer => 120,
        StorageType.pantry => null,
      },
    FoodCategory.poultry || FoodCategory.fish => switch (storage) {
        StorageType.fridge => 2,
        StorageType.freezer => 90,
        StorageType.pantry => null,
      },
    FoodCategory.dairy => storage == StorageType.fridge ? 5 : null,
    FoodCategory.produce => switch (storage) {
        StorageType.fridge => 5,
        StorageType.freezer => 60,
        StorageType.pantry => 5,
      },
    FoodCategory.leftovers => switch (storage) {
        StorageType.fridge => 3,
        StorageType.freezer => 60,
        StorageType.pantry => null,
      },
    _ => null,
  };
}
