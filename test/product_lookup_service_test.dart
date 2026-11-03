import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_alimentos/core/app_exception.dart';
import 'package:gestao_alimentos/models/food_item.dart';
import 'package:gestao_alimentos/services/product_lookup_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('categoryFromTags', () {
    test('mapeia tags conhecidas', () {
      expect(categoryFromTags(['en:dairies', 'en:milks']), FoodCategory.dairy);
      expect(categoryFromTags(['en:pastas']), FoodCategory.grains);
    });

    test('aves tem prioridade sobre carnes', () {
      expect(
        categoryFromTags(['en:meats', 'en:poultry']),
        FoodCategory.poultry,
      );
    });

    test('sem tag conhecida vira Outros', () {
      expect(categoryFromTags(['en:snacks']), FoodCategory.other);
      expect(categoryFromTags([]), FoodCategory.other);
    });
  });

  group('parseProduct', () {
    test('prefere o nome em português', () {
      final info = parseProduct({
        'status': 1,
        'product': {
          'product_name': 'Whole milk',
          'product_name_pt': 'Leite integral',
          'categories_tags': ['en:milks'],
        },
      });
      expect(info!.name, 'Leite integral');
      expect(info.category, FoodCategory.dairy);
    });

    test('produto não encontrado ou sem nome retorna null', () {
      expect(parseProduct({'status': 0}), isNull);
      expect(
        parseProduct({
          'status': 1,
          'product': {'product_name': ' '},
        }),
        isNull,
      );
    });
  });

  group('lookup', () {
    test('retorna o produto quando a API responde 200', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/api/v2/product/789.json');
        return http.Response(
          jsonEncode({
            'status': 1,
            'product': {
              'product_name': 'Arroz',
              'categories_tags': ['en:rices'],
            },
          }),
          200,
        );
      });
      final info = await ProductLookupService(client: client).lookup('789');
      expect(info!.name, 'Arroz');
      expect(info.category, FoodCategory.grains);
    });

    test('404 significa não encontrado', () async {
      final client = MockClient((_) async => http.Response('{}', 404));
      expect(await ProductLookupService(client: client).lookup('1'), isNull);
    });

    test('falha de rede vira AppException', () async {
      final client = MockClient((_) async => throw http.ClientException('x'));
      expect(
        ProductLookupService(client: client).lookup('1'),
        throwsA(isA<AppException>()),
      );
    });
  });
}
