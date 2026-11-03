import 'package:cloud_firestore/cloud_firestore.dart';

/// Casa compartilhada salva em `households/{id}` (ver docs/MODELO_DADOS.md).
class Household {
  const Household({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.memberIds,
    required this.inviteCode,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String ownerId;
  final List<String> memberIds;
  final String inviteCode;
  final DateTime createdAt;

  factory Household.fromMap(String id, Map<String, dynamic> map) {
    return Household(
      id: id,
      name: map['name'] as String,
      ownerId: map['ownerId'] as String,
      memberIds: List<String>.from(map['memberIds'] as List? ?? const []),
      inviteCode: map['inviteCode'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ownerId': ownerId,
      'memberIds': memberIds,
      'inviteCode': inviteCode,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Household copyWith({String? name, List<String>? memberIds}) {
    return Household(
      id: id,
      name: name ?? this.name,
      ownerId: ownerId,
      memberIds: memberIds ?? this.memberIds,
      inviteCode: inviteCode,
      createdAt: createdAt,
    );
  }
}
