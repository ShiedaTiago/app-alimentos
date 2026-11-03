import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/app_exception.dart';
import '../core/firestore_errors.dart';
import '../core/utils/epc.dart';
import '../models/rfid_tag.dart';

/// Etiquetas RFID da casa. No TCC quem cria e atualiza as tags é o ESP32;
/// aqui os métodos `simulate*` fazem esse papel (RF25).
class TagService {
  TagService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _household(String householdId) =>
      _db.collection('households').doc(householdId);

  CollectionReference<Map<String, dynamic>> _tags(String householdId) =>
      _household(householdId).collection('tags');

  /// Todas as etiquetas, das vistas mais recentemente às mais antigas.
  Stream<List<RfidTag>> watchTags(String householdId) {
    return _tags(householdId)
        .orderBy('lastSeenAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              RfidTag.fromMap(doc.id, doc.data()),
          ],
        )
        .handleError((Object error) {
          if (error is FirebaseException) {
            throw AppException(firestoreErrorMessage(error.code));
          }
          throw error;
        });
  }

  /// Simula a antena lendo uma etiqueta que ainda não existe na casa.
  Future<String> simulateNewTag(String householdId, String storageId) {
    return _guard(() async {
      final epc = generateEpc();
      final now = DateTime.now();
      final tag = RfidTag(
        id: epc,
        storageId: storageId,
        firstSeenAt: now,
        lastSeenAt: now,
      );
      await _tags(householdId).doc(epc).set(tag.toMap());
      return epc;
    });
  }

  /// Simula uma nova leitura: atualiza `lastSeenAt` da etiqueta e, se ela
  /// estiver vinculada, também do alimento.
  Future<void> simulateReading(String householdId, RfidTag tag) {
    return _guard(() async {
      final now = Timestamp.now();
      final batch = _db.batch()
        ..update(_tags(householdId).doc(tag.id), {'lastSeenAt': now});
      if (tag.itemId != null) {
        batch.update(
          _household(householdId).collection('items').doc(tag.itemId),
          {'lastSeenAt': now},
        );
      }
      await batch.commit();
    });
  }

  /// Vincula a etiqueta ao alimento. O batch grava os dois lados juntos:
  /// ou os dois documentos mudam, ou nenhum.
  Future<void> linkTag(String householdId, String tagId, String itemId) {
    return _guard(() async {
      final now = Timestamp.now();
      await (_db.batch()
            ..update(_tags(householdId).doc(tagId), {
              'status': TagStatus.linked.name,
              'itemId': itemId,
              'lastSeenAt': now,
            })
            ..update(_household(householdId).collection('items').doc(itemId), {
              'tagId': tagId,
              'lastSeenAt': now,
              'updatedAt': now,
            }))
          .commit();
    });
  }

  Future<void> delete(String householdId, String tagId) {
    return _guard(() => _tags(householdId).doc(tagId).delete());
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseException catch (error) {
      throw AppException(firestoreErrorMessage(error.code));
    }
  }
}
