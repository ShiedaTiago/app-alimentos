import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_alimentos/models/household.dart';

void main() {
  final household = Household(
    id: 'h1',
    name: 'Casa do Tiago',
    ownerId: 'u1',
    memberIds: const ['u1', 'u2'],
    inviteCode: 'ABCD23',
    createdAt: DateTime(2026, 11, 8),
  );

  test('toMap/fromMap preservam os dados', () {
    final copy = Household.fromMap('h1', household.toMap());
    expect(copy.name, household.name);
    expect(copy.ownerId, 'u1');
    expect(copy.memberIds, ['u1', 'u2']);
    expect(copy.inviteCode, 'ABCD23');
    expect(copy.createdAt, household.createdAt);
    expect(household.toMap()['createdAt'], isA<Timestamp>());
  });

  test('copyWith troca só o que foi pedido', () {
    final renamed = household.copyWith(name: 'Casa Nova');
    expect(renamed.name, 'Casa Nova');
    expect(renamed.memberIds, household.memberIds);
  });
}
