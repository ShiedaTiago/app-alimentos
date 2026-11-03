import 'dart:math';

/// Gera um EPC falso de 96 bits (24 dígitos hexadecimais), como o que uma
/// etiqueta UHF real devolve. Usado só pelo simulador RFID (RF25).
String generateEpc([Random? random]) {
  final rng = random ?? Random.secure();
  return List.generate(
    24,
    (_) => rng.nextInt(16).toRadixString(16),
  ).join().toUpperCase();
}

/// EPC encurtado para caber na tela: `E2003412…9F01`.
String shortEpc(String epc) {
  if (epc.length <= 12) return epc;
  return '${epc.substring(0, 8)}…${epc.substring(epc.length - 4)}';
}
