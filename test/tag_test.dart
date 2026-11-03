import 'dart:math';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_alimentos/core/utils/epc.dart';
import 'package:gestao_alimentos/models/rfid_tag.dart';
import 'package:gestao_alimentos/services/tag_service.dart';

import 'support/food_item_fixture.dart';

void main() {
  group('generateEpc', () {
    test('gera 24 dígitos hexadecimais maiúsculos', () {
      final epc = generateEpc(Random(1));
      expect(epc, matches(RegExp(r'^[0-9A-F]{24}$')));
    });

    test('shortEpc encurta mantendo começo e fim', () {
      expect(shortEpc('E20034120000000000009F01'), 'E2003412…9F01');
      expect(shortEpc('ABC'), 'ABC');
    });
  });

  test('RfidTag: toMap e fromMap preservam os dados', () {
    final now = DateTime(2026, 11, 3, 10);
    final tag = RfidTag(
      id: 'E200',
      storageId: 'fridge',
      firstSeenAt: now,
      lastSeenAt: now,
    );
    final map = tag.toMap();
    expect(map['status'], 'pending');

    final restored = RfidTag.fromMap('E200', map);
    expect(restored.status, TagStatus.pending);
    expect(restored.storageId, 'fridge');
    expect(restored.lastSeenAt, now);
  });

  group('TagService', () {
    late FakeFirebaseFirestore db;
    late TagService service;

    setUp(() {
      db = FakeFirebaseFirestore();
      service = TagService(firestore: db);
    });

    test('simulateNewTag cria etiqueta pendente', () async {
      final epc = await service.simulateNewTag('h1', 'fridge');
      final tags = await service.watchTags('h1').first;
      expect(tags.single.id, epc);
      expect(tags.single.status, TagStatus.pending);
    });

    test('linkTag vincula os dois lados (tag e alimento)', () async {
      final itemRef = db.collection('households/h1/items').doc('i1');
      await itemRef.set(buildItem(name: 'Leite').toMap());
      final epc = await service.simulateNewTag('h1', 'fridge');

      await service.linkTag('h1', epc, 'i1');

      final tag = (await service.watchTags('h1').first).single;
      expect(tag.status, TagStatus.linked);
      expect(tag.itemId, 'i1');
      expect((await itemRef.get()).data()!['tagId'], epc);
    });
  });
}
