import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/utils/enum_utils.dart';

enum TagStatus { pending, linked }

/// Etiqueta RFID vista pela antena: `households/{id}/tags/{tagId}`.
/// O id do documento é o EPC da etiqueta (ver MODELO_DADOS.md).
class RfidTag {
  const RfidTag({
    required this.id,
    required this.storageId,
    required this.firstSeenAt,
    required this.lastSeenAt,
    this.status = TagStatus.pending,
    this.itemId,
  });

  final String id;
  final TagStatus status;
  final String? itemId;
  final String storageId;
  final DateTime firstSeenAt;
  final DateTime lastSeenAt;

  factory RfidTag.fromMap(String id, Map<String, dynamic> map) {
    return RfidTag(
      id: id,
      status: enumByName(
        TagStatus.values,
        map['status'] as String?,
        TagStatus.pending,
      ),
      itemId: map['itemId'] as String?,
      storageId: map['storageId'] as String,
      firstSeenAt: (map['firstSeenAt'] as Timestamp).toDate(),
      lastSeenAt: (map['lastSeenAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'itemId': itemId,
      'storageId': storageId,
      'firstSeenAt': Timestamp.fromDate(firstSeenAt),
      'lastSeenAt': Timestamp.fromDate(lastSeenAt),
    };
  }

  RfidTag copyWith({TagStatus? status, String? itemId, DateTime? lastSeenAt}) {
    return RfidTag(
      id: id,
      status: status ?? this.status,
      itemId: itemId ?? this.itemId,
      storageId: storageId,
      firstSeenAt: firstSeenAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }
}
