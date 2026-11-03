import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/app_exception.dart';
import '../core/firestore_errors.dart';
import '../models/food_item.dart';
import '../models/storage_place.dart';

/// Única camada que fala com o Firestore sobre os alimentos de uma casa.
class ItemService {
  ItemService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _items(String householdId) =>
      _db.collection('households').doc(householdId).collection('items');

  /// Alimentos ativos em tempo real, do que vence primeiro ao último.
  /// Pode exigir índice composto (status + expiresAt) no Firestore.
  Stream<List<FoodItem>> watchActiveItems(String householdId) {
    return _items(householdId)
        .where('status', isEqualTo: ItemStatus.active.name)
        .orderBy('expiresAt')
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              FoodItem.fromMap(doc.id, doc.data()),
          ],
        )
        .handleError((Object error) {
          if (error is FirebaseException) {
            throw AppException(firestoreErrorMessage(error.code));
          }
          throw error;
        });
  }

  /// Últimos alimentos cadastrados (ativos, consumidos ou descartados),
  /// usados para autocompletar o formulário (RF20).
  Future<List<FoodItem>> fetchRecentItems(
    String householdId, {
    int limit = 100,
  }) {
    return _guard(() async {
      final snapshot = await _items(householdId)
          .orderBy('updatedAt', descending: true)
          .limit(limit)
          .get();
      return [
        for (final doc in snapshot.docs) FoodItem.fromMap(doc.id, doc.data()),
      ];
    });
  }

  /// Locais da casa (geladeira, freezer, despensa) em ordem alfabética.
  Stream<List<StoragePlace>> watchStorages(String householdId) {
    return _db
        .collection('households')
        .doc(householdId)
        .collection('storages')
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              StoragePlace.fromMap(doc.id, doc.data()),
          ],
        );
  }

  /// Salva um alimento novo e devolve o id gerado. O `id` de [item] é ignorado.
  Future<String> create(String householdId, FoodItem item) {
    return _guard(() async {
      final ref = _items(householdId).doc();
      final now = DateTime.now();
      final data = item.copyWith(updatedAt: now).toMap()
        ..['createdAt'] = Timestamp.fromDate(now);
      await ref.set(data);
      return ref.id;
    });
  }

  Future<void> update(String householdId, FoodItem item) {
    return _guard(() async {
      final data = item.copyWith(updatedAt: DateTime.now()).toMap();
      await _items(householdId).doc(item.id).update(data);
    });
  }

  Future<void> delete(String householdId, String itemId) {
    return _guard(() => _items(householdId).doc(itemId).delete());
  }

  /// Tira o alimento da lista de ativos marcando como consumido ou descartado.
  /// O documento fica salvo (histórico).
  Future<void> close(String householdId, String itemId, ItemStatus status) {
    assert(status != ItemStatus.active, 'use update para reativar');
    return _guard(() async {
      final now = Timestamp.now();
      await _items(householdId)
          .doc(itemId)
          .update({'status': status.name, 'closedAt': now, 'updatedAt': now});
    });
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseException catch (error) {
      throw AppException(firestoreErrorMessage(error.code));
    }
  }
}
