import 'package:gestao_alimentos/models/food_item.dart';

/// Cria um FoodItem de teste só informando o que importa em cada caso.
FoodItem buildItem({
  String name = 'Leite',
  FoodCategory category = FoodCategory.dairy,
  DateTime? expiresAt,
  ItemStatus status = ItemStatus.active,
}) {
  final now = DateTime(2026, 11, 1);
  return FoodItem(
    id: name,
    name: name,
    category: category,
    quantity: 1,
    unit: FoodUnit.unit,
    expiresAt: expiresAt ?? DateTime(2026, 12, 31),
    storageId: 'fridge1',
    addedBy: 'u1',
    createdAt: now,
    updatedAt: now,
    status: status,
  );
}
