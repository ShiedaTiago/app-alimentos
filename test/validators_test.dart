import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_alimentos/core/utils/validators.dart';

void main() {
  group('validateName', () {
    test('rejeita vazio e muito curto', () {
      expect(validateName(null), isNotNull);
      expect(validateName('   '), isNotNull);
      expect(validateName('A'), isNotNull);
    });
    test('aceita nome válido', () {
      expect(validateName('Tiago'), isNull);
    });
  });

  group('validateHouseholdName', () {
    test('rejeita vazio e muito curto', () {
      expect(validateHouseholdName(''), isNotNull);
      expect(validateHouseholdName(' A '), isNotNull);
    });
    test('aceita nome válido', () {
      expect(validateHouseholdName('Casa do Tiago'), isNull);
    });
  });

  group('validateItemName', () {
    test('rejeita vazio e muito curto', () {
      expect(validateItemName(''), isNotNull);
      expect(validateItemName(' L '), isNotNull);
    });
    test('aceita nome válido', () {
      expect(validateItemName('Leite'), isNull);
    });
  });

  group('validateQuantity', () {
    test('rejeita vazio, texto, zero e negativo', () {
      expect(validateQuantity(''), isNotNull);
      expect(validateQuantity('abc'), isNotNull);
      expect(validateQuantity('0'), isNotNull);
      expect(validateQuantity('-2'), isNotNull);
    });
    test('aceita inteiro e decimal com vírgula ou ponto', () {
      expect(validateQuantity('2'), isNull);
      expect(validateQuantity('1,5'), isNull);
      expect(validateQuantity(' 0.5 '), isNull);
      expect(parseQuantity('1,5'), 1.5);
    });
  });

  group('validateExpiryDate', () {
    test('exige a data', () {
      expect(validateExpiryDate(null), isNotNull);
      expect(validateExpiryDate(DateTime(2026, 11, 30)), isNull);
    });
  });

  group('validateInviteCodeInput', () {
    test('rejeita vazio, tamanho errado e caracteres ambíguos', () {
      expect(validateInviteCodeInput(null), isNotNull);
      expect(validateInviteCodeInput('ABC'), isNotNull);
      expect(validateInviteCodeInput('ABCD10'), isNotNull);
    });
    test('aceita código válido, mesmo minúsculo e com espaços', () {
      expect(validateInviteCodeInput(' abcd23 '), isNull);
    });
  });

  group('validateEmail', () {
    test('rejeita vazio e formatos inválidos', () {
      expect(validateEmail(''), isNotNull);
      expect(validateEmail('tiago'), isNotNull);
      expect(validateEmail('tiago@'), isNotNull);
      expect(validateEmail('tiago@gmail'), isNotNull);
      expect(validateEmail('ti ago@gmail.com'), isNotNull);
    });
    test('aceita e-mail válido (ignora espaços nas pontas)', () {
      expect(validateEmail('tiago@gmail.com'), isNull);
      expect(validateEmail('  tiago.t@mail.com.br '), isNull);
    });
  });

  group('validatePassword', () {
    test('rejeita vazia, curta, sem número ou sem letra', () {
      expect(validatePassword(''), isNotNull);
      expect(validatePassword('abc123'), isNotNull); // 6 caracteres
      expect(validatePassword('abcdefgh'), isNotNull); // sem número
      expect(validatePassword('12345678'), isNotNull); // sem letra
    });
    test('aceita 8+ caracteres com letra e número', () {
      expect(validatePassword('abcd1234'), isNull);
      expect(validatePassword('Senha2026'), isNull);
    });
  });

  group('validateConfirmPassword', () {
    test('rejeita vazia e diferente', () {
      expect(validateConfirmPassword('', 'abcd1234'), isNotNull);
      expect(validateConfirmPassword('abcd1235', 'abcd1234'), isNotNull);
    });
    test('aceita igual', () {
      expect(validateConfirmPassword('abcd1234', 'abcd1234'), isNull);
    });
  });
}
