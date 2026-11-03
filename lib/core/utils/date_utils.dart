import 'package:intl/intl.dart';

/// Descarta a hora: só a data importa para validade.
DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// Dias entre [today] (padrão: hoje) e [date], por data e sem horas.
/// Negativo = já passou. Usa UTC no cálculo para o horário de verão
/// não "comer" um dia.
int daysUntil(DateTime date, {DateTime? today}) {
  final from = today ?? DateTime.now();
  final fromUtc = DateTime.utc(from.year, from.month, from.day);
  final toUtc = DateTime.utc(date.year, date.month, date.day);
  return toUtc.difference(fromUtc).inDays;
}

/// Formata como dd/MM/aaaa.
String formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

/// Formata como dd/MM/aaaa HH:mm:ss (leituras do simulador RFID).
String formatDateTime(DateTime date) =>
    DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
