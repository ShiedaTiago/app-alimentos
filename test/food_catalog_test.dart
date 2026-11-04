import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_alimentos/core/utils/food_catalog.dart';

void main() {
  test('corrige erro de digitação preservando o resto do nome', () {
    expect(suggestCorrection('Liete integral')?.suggested, 'Leite integral');
    expect(suggestCorrection('feijao')?.suggested, isNull);
    expect(suggestCorrection('Macarao')?.suggested, 'Macarrão');
    expect(suggestCorrection('Tomte')?.suggested, 'Tomate');
  });

  test('não mexe em palavra desconhecida e distante', () {
    expect(suggestCorrection('Tofu defumado'), isNull);
  });

  test('usa palavras extras (histórico)', () {
    expect(
      suggestCorrection('Quinua', extraWords: ['quinoa'])?.suggested,
      'Quinoa',
    );
  });
}
