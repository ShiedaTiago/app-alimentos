import 'dart:math';

import '../constants.dart';

/// Gera o código de convite da casa (RN03): 6 caracteres sem 0/O/1/I.
String generateInviteCode({Random? random}) {
  final rng = random ?? Random.secure();
  return List.generate(
    inviteCodeLength,
    (_) => inviteCodeAlphabet[rng.nextInt(inviteCodeAlphabet.length)],
  ).join();
}

/// Deixa o que o usuário digitou no formato do código (sem espaços, maiúsculo).
String normalizeInviteCode(String input) => input.trim().toUpperCase();

bool isValidInviteCode(String code) {
  return code.length == inviteCodeLength &&
      code.split('').every(inviteCodeAlphabet.contains);
}
