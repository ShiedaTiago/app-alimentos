import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_alimentos/core/app_exception.dart';
import 'package:gestao_alimentos/services/household_service.dart';

// Firestore em memória: testa o fluxo da casa sem precisar do celular.
// Não testa as regras de segurança (isso é no Rules Playground).
void main() {
  late FakeFirebaseFirestore db;
  late HouseholdService service;

  Future<void> addUser(String uid, String name) {
    return db.collection('users').doc(uid).set({
      'name': name,
      'email': '$uid@teste.com',
      'householdId': null,
      'createdAt': Timestamp.now(),
    });
  }

  Future<String?> householdIdOf(String uid) async {
    final doc = await db.collection('users').doc(uid).get();
    return doc.data()!['householdId'] as String?;
  }

  setUp(() async {
    db = FakeFirebaseFirestore();
    service = HouseholdService(firestore: db);
    await addUser('ana', 'Ana');
    await addUser('bia', 'Bia');
  });

  test('criar casa gera convite, 3 locais e vincula o usuário', () async {
    await service.create(uid: 'ana', name: '  Casa da Ana ');

    final householdId = await householdIdOf('ana');
    expect(householdId, isNotNull);

    final household = await service.watchHousehold(householdId!).first;
    expect(household!.name, 'Casa da Ana');
    expect(household.memberIds, ['ana']);

    final invite = await db
        .collection('inviteCodes')
        .doc(household.inviteCode)
        .get();
    expect(invite.data()!['householdId'], householdId);

    final storages = await db
        .collection('households/$householdId/storages')
        .get();
    expect(
      storages.docs.map((d) => d['name']),
      unorderedEquals(['Geladeira', 'Freezer', 'Despensa']),
    );
  });

  test('segunda conta entra com o código e os dois viram membros', () async {
    await service.create(uid: 'ana', name: 'Casa da Ana');
    final householdId = (await householdIdOf('ana'))!;
    final code = (await service.watchHousehold(householdId).first)!.inviteCode;

    // Digitado em minúsculas e com espaço, como um usuário faria.
    await service.join(uid: 'bia', code: ' ${code.toLowerCase()} ');

    expect(await householdIdOf('bia'), householdId);
    final household = await service.watchHousehold(householdId).first;
    expect(household!.memberIds, ['ana', 'bia']);

    final members = await service.fetchMembers(household.memberIds);
    expect(members.map((m) => m.name), ['Ana', 'Bia']);
  });

  test('entrar de novo na mesma casa não duplica o membro', () async {
    await service.create(uid: 'ana', name: 'Casa da Ana');
    final householdId = (await householdIdOf('ana'))!;
    final code = (await service.watchHousehold(householdId).first)!.inviteCode;

    await service.join(uid: 'bia', code: code);
    await service.join(uid: 'bia', code: code);

    final household = await service.watchHousehold(householdId).first;
    expect(household!.memberIds, ['ana', 'bia']);
  });

  test('código inexistente dá erro amigável', () async {
    expect(
      () => service.join(uid: 'bia', code: 'ZZZZ22'),
      throwsA(
        isA<AppException>().having(
          (e) => e.message,
          'message',
          'Código de convite não encontrado.',
        ),
      ),
    );
  });
}
