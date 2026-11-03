import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_alimentos/models/food_item.dart';
import 'package:gestao_alimentos/services/item_service.dart';

import 'support/food_item_fixture.dart';

// Firestore em memória: testa o CRUD de alimentos sem o celular.
void main() {
  const house = 'casaA';
  late FakeFirebaseFirestore db;
  late ItemService service;

  setUp(() {
    db = FakeFirebaseFirestore();
    service = ItemService(firestore: db);
  });

  Future<List<String>> activeNames() async =>
      (await service.watchActiveItems(house).first).map((i) => i.name).toList();

  test('lista só ativos, ordenados por validade', () async {
    await service.create(
      house,
      buildItem(name: 'Iogurte', expiresAt: DateTime(2026, 11, 20)),
    );
    await service.create(
      house,
      buildItem(name: 'Leite', expiresAt: DateTime(2026, 11, 5)),
    );
    await service.create(
      house,
      buildItem(name: 'Queijo', status: ItemStatus.consumed),
    );

    expect(await activeNames(), ['Leite', 'Iogurte']);
  });

  test('editar altera os dados e o updatedAt', () async {
    final id = await service.create(house, buildItem(name: 'Leite'));
    final saved = (await service.watchActiveItems(house).first).single;
    expect(saved.id, id);

    await service.update(house, saved.copyWith(quantity: 3));

    final edited = (await service.watchActiveItems(house).first).single;
    expect(edited.quantity, 3);
    expect(edited.updatedAt.isBefore(saved.updatedAt), isFalse);
  });

  test('consumir tira da lista mas mantém o histórico', () async {
    final id = await service.create(house, buildItem(name: 'Leite'));

    await service.close(house, id, ItemStatus.consumed);

    expect(await activeNames(), isEmpty);
    final doc = await db.doc('households/$house/items/$id').get();
    expect(doc['status'], 'consumed');
    expect(doc['closedAt'], isNotNull);
  });

  test('excluir apaga o documento', () async {
    final id = await service.create(house, buildItem(name: 'Leite'));

    await service.delete(house, id);

    final doc = await db.doc('households/$house/items/$id').get();
    expect(doc.exists, isFalse);
  });

  test('alimentos de outra casa não aparecem', () async {
    await service.create('casaB', buildItem(name: 'Carne'));

    expect(await activeNames(), isEmpty);
  });
}
