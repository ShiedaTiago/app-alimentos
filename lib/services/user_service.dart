import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

class UserService {
  UserService({FirebaseFirestore? firestore})
    : _users = (firestore ?? FirebaseFirestore.instance).collection('users');

  final CollectionReference<Map<String, dynamic>> _users;

  /// Cria `users/{uid}` só se ainda não existir (primeiro acesso).
  Future<void> createIfMissing({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    final doc = _users.doc(uid);
    final snapshot = await doc.get();
    if (snapshot.exists) return;
    final user = AppUser(
      id: uid,
      name: name,
      email: email,
      photoUrl: photoUrl,
      createdAt: DateTime.now(),
    );
    await doc.set(user.toMap());
  }
}
