import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_alimentos/models/app_user.dart';

void main() {
  final createdAt = DateTime(2026, 11, 2, 10, 30);

  test('toMap e fromMap preservam os dados', () {
    final user = AppUser(
      id: 'u1',
      name: 'Tiago',
      email: 'tiago@mail.com',
      createdAt: createdAt,
    );

    final map = user.toMap();
    expect(map['createdAt'], isA<Timestamp>());
    expect(map.containsKey('id'), isFalse); // o id é o nome do documento

    final restored = AppUser.fromMap('u1', map);
    expect(restored.id, 'u1');
    expect(restored.name, 'Tiago');
    expect(restored.email, 'tiago@mail.com');
    expect(restored.photoUrl, isNull);
    expect(restored.householdId, isNull);
    expect(restored.createdAt, createdAt);
  });

  test('copyWith troca só o que foi informado', () {
    final user = AppUser(
      id: 'u1',
      name: 'Tiago',
      email: 'tiago@mail.com',
      createdAt: createdAt,
    );

    final updated = user.copyWith(householdId: 'casa1');
    expect(updated.householdId, 'casa1');
    expect(updated.name, 'Tiago');
    expect(updated.email, 'tiago@mail.com');
    expect(user.householdId, isNull); // o original não muda (imutável)
  });
}
