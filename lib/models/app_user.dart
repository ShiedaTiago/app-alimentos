import 'package:cloud_firestore/cloud_firestore.dart';

/// Perfil do usuário salvo em `users/{uid}` (ver docs/MODELO_DADOS.md).
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.photoUrl,
    this.householdId,
  });

  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? householdId;
  final DateTime createdAt;

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      name: map['name'] as String,
      email: map['email'] as String,
      photoUrl: map['photoUrl'] as String?,
      householdId: map['householdId'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // O id não vai no mapa: ele é o nome do documento.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'householdId': householdId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AppUser copyWith({String? name, String? photoUrl, String? householdId}) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt,
    );
  }
}
