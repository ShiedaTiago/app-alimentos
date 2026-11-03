import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/utils/enum_utils.dart';

enum FoodCategory {
  meat('Carnes'),
  poultry('Aves'),
  fish('Peixes'),
  dairy('Laticínios'),
  eggs('Ovos'),
  produce('Frutas e verduras'),
  grains('Grãos e massas'),
  bakery('Pães'),
  canned('Enlatados'),
  beverages('Bebidas'),
  leftovers('Sobras'),
  other('Outros');

  const FoodCategory(this.label);
  final String label;
}

enum FoodUnit {
  unit('un'),
  kg('kg'),
  g('g'),
  l('L'),
  ml('ml'),
  pack('pct');

  const FoodUnit(this.label);
  final String label;
}

enum ItemStatus { active, consumed, discarded }

enum ItemSource { manual, barcode, rfid }

enum ExpiryStatus { expired, critical, warning, ok }

/// Alimento da casa: `households/{id}/items/{itemId}` (ver MODELO_DADOS.md).
class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.expiresAt,
    required this.storageId,
    required this.addedBy,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.barcode,
    this.status = ItemStatus.active,
    this.source = ItemSource.manual,
    this.tagId,
    this.lastSeenAt,
    this.closedAt,
  });

  final String id;
  final String name;
  final FoodCategory category;
  final double quantity;
  final FoodUnit unit;
  final DateTime expiresAt;
  final String storageId;
  final String? notes;
  final String? barcode;
  final ItemStatus status;
  final ItemSource source;
  final String? tagId; // [F] etiqueta RFID
  final DateTime? lastSeenAt; // [F]
  final String addedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? closedAt;

  factory FoodItem.fromMap(String id, Map<String, dynamic> map) {
    DateTime? optionalDate(String key) => (map[key] as Timestamp?)?.toDate();

    return FoodItem(
      id: id,
      name: map['name'] as String,
      category: enumByName(
        FoodCategory.values,
        map['category'] as String?,
        FoodCategory.other,
      ),
      quantity: (map['quantity'] as num).toDouble(),
      unit: enumByName(FoodUnit.values, map['unit'] as String?, FoodUnit.unit),
      expiresAt: (map['expiresAt'] as Timestamp).toDate(),
      storageId: map['storageId'] as String,
      notes: map['notes'] as String?,
      barcode: map['barcode'] as String?,
      status: enumByName(
        ItemStatus.values,
        map['status'] as String?,
        ItemStatus.active,
      ),
      source: enumByName(
        ItemSource.values,
        map['source'] as String?,
        ItemSource.manual,
      ),
      tagId: map['tagId'] as String?,
      lastSeenAt: optionalDate('lastSeenAt'),
      addedBy: map['addedBy'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      closedAt: optionalDate('closedAt'),
    );
  }

  Map<String, dynamic> toMap() {
    Timestamp? optionalStamp(DateTime? date) =>
        date == null ? null : Timestamp.fromDate(date);

    return {
      'name': name,
      'category': category.name,
      'quantity': quantity,
      'unit': unit.name,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'storageId': storageId,
      'notes': notes,
      'barcode': barcode,
      'status': status.name,
      'source': source.name,
      'tagId': tagId,
      'lastSeenAt': optionalStamp(lastSeenAt),
      'addedBy': addedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'closedAt': optionalStamp(closedAt),
    };
  }

  // Campos nulos mantêm o valor atual (não dá para "limpar" um campo opcional).
  FoodItem copyWith({
    String? name,
    FoodCategory? category,
    double? quantity,
    FoodUnit? unit,
    DateTime? expiresAt,
    String? storageId,
    String? notes,
    ItemStatus? status,
    DateTime? updatedAt,
    DateTime? closedAt,
  }) {
    return FoodItem(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expiresAt: expiresAt ?? this.expiresAt,
      storageId: storageId ?? this.storageId,
      notes: notes ?? this.notes,
      barcode: barcode,
      status: status ?? this.status,
      source: source,
      tagId: tagId,
      lastSeenAt: lastSeenAt,
      addedBy: addedBy,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      closedAt: closedAt ?? this.closedAt,
    );
  }
}
