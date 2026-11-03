import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/app_exception.dart';
import '../core/firestore_errors.dart';
import '../core/utils/invite_code.dart';
import '../models/app_user.dart';
import '../models/household.dart';
import '../models/storage_place.dart';

const _defaultStorages = [
  (name: 'Geladeira', type: StorageType.fridge),
  (name: 'Freezer', type: StorageType.freezer),
  (name: 'Despensa', type: StorageType.pantry),
];

/// Única camada que fala com o Firestore sobre casas, convites e membros.
class HouseholdService {
  HouseholdService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _households =>
      _db.collection('households');
  CollectionReference<Map<String, dynamic>> get _inviteCodes =>
      _db.collection('inviteCodes');

  /// Perfil do usuário em tempo real (null enquanto o documento não existe).
  Stream<AppUser?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map(
          (doc) => doc.exists ? AppUser.fromMap(doc.id, doc.data()!) : null,
        );
  }

  Stream<Household?> watchHousehold(String id) {
    return _households.doc(id).snapshots().map(
          (doc) => doc.exists ? Household.fromMap(doc.id, doc.data()!) : null,
        );
  }

  /// Cria a casa, o código de convite e os 3 locais padrão (RF07, RF11).
  Future<void> create({required String uid, required String name}) {
    return _guard(() async {
      final code = await _uniqueInviteCode();
      final householdRef = _households.doc();
      final household = Household(
        id: householdRef.id,
        name: name.trim(),
        ownerId: uid,
        memberIds: [uid],
        inviteCode: code,
        createdAt: DateTime.now(),
      );

      final batch = _db.batch()
        ..set(householdRef, household.toMap())
        ..set(_inviteCodes.doc(code), {'householdId': householdRef.id})
        ..update(_users.doc(uid), {'householdId': householdRef.id});
      await batch.commit();

      // Os locais vão num segundo lote: a regra de `storages` consulta a casa
      // já salva para conferir se o usuário é membro.
      final storages = _db.batch();
      for (final storage in _defaultStorages) {
        final ref = householdRef.collection('storages').doc();
        storages.set(
          ref,
          StoragePlace(id: ref.id, name: storage.name, type: storage.type).toMap(),
        );
      }
      await storages.commit();
    });
  }

  /// Entra numa casa existente pelo código de convite (RF07).
  Future<void> join({required String uid, required String code}) {
    return _guard(() async {
      final invite = await _inviteCodes.doc(normalizeInviteCode(code)).get();
      final householdId = invite.data()?['householdId'] as String?;
      if (householdId == null) {
        throw const AppException('Código de convite não encontrado.');
      }
      final batch = _db.batch()
        ..update(_households.doc(householdId), {
          'memberIds': FieldValue.arrayUnion([uid]),
        })
        ..update(_users.doc(uid), {'householdId': householdId});
      await batch.commit();
    });
  }

  /// Busca o perfil de cada membro (um `get` por documento, que as regras permitem).
  Future<List<AppUser>> fetchMembers(List<String> memberIds) {
    return _guard(() async {
      final docs = await Future.wait(memberIds.map((id) => _users.doc(id).get()));
      return [
        for (final doc in docs)
          if (doc.exists) AppUser.fromMap(doc.id, doc.data()!),
      ];
    });
  }

  // Sorteia códigos até achar um que ainda não está em uso.
  Future<String> _uniqueInviteCode() async {
    while (true) {
      final code = generateInviteCode();
      final existing = await _inviteCodes.doc(code).get();
      if (!existing.exists) return code;
    }
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseException catch (error) {
      throw AppException(firestoreErrorMessage(error.code));
    }
  }
}
