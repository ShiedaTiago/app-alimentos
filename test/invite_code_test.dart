import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_alimentos/core/constants.dart';
import 'package:gestao_alimentos/core/utils/invite_code.dart';

void main() {
  test('gera código com 6 caracteres do alfabeto permitido', () {
    final rng = Random(1);
    for (var i = 0; i < 200; i++) {
      final code = generateInviteCode(random: rng);
      expect(code.length, inviteCodeLength);
      expect(isValidInviteCode(code), isTrue);
    }
  });

  test('nunca usa caracteres ambíguos (0, O, 1, I)', () {
    final rng = Random(2);
    for (var i = 0; i < 200; i++) {
      expect(generateInviteCode(random: rng), isNot(matches(RegExp('[01OI]'))));
    }
  });

  test('isValidInviteCode rejeita tamanho errado, minúsculas e ambíguos', () {
    expect(isValidInviteCode('ABC23'), isFalse);
    expect(isValidInviteCode('ABC2345'), isFalse);
    expect(isValidInviteCode('abc234'), isFalse);
    expect(isValidInviteCode('ABC0EF'), isFalse);
    expect(isValidInviteCode('ABC234'), isTrue);
  });

  test('normalizeInviteCode tira espaços e põe em maiúsculas', () {
    expect(normalizeInviteCode('  abc234 '), 'ABC234');
  });
}
