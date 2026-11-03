import '../constants.dart';
import 'invite_code.dart';

// Validadores de formulário. Cada função devolve `null` quando o valor é
// válido, ou a mensagem de erro em pt-BR (formato que o TextFormField espera).

final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
final RegExp _letterPattern = RegExp(r'\p{L}', unicode: true);
final RegExp _digitPattern = RegExp(r'\d');

String? validateName(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Informe seu nome.';
  if (text.length < 2) return 'O nome deve ter pelo menos 2 caracteres.';
  return null;
}

String? validateEmail(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Informe seu e-mail.';
  if (!_emailPattern.hasMatch(text)) return 'E-mail inválido.';
  return null;
}

String? validatePassword(String? value) {
  final text = value ?? '';
  if (text.isEmpty) return 'Informe a senha.';
  if (text.length < minPasswordLength) {
    return 'A senha deve ter pelo menos $minPasswordLength caracteres.';
  }
  if (!_letterPattern.hasMatch(text) || !_digitPattern.hasMatch(text)) {
    return 'A senha deve conter letras e números.';
  }
  return null;
}

String? validateHouseholdName(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Informe o nome da casa.';
  if (text.length < 2) return 'O nome deve ter pelo menos 2 caracteres.';
  return null;
}

String? validateInviteCodeInput(String? value) {
  final code = normalizeInviteCode(value ?? '');
  if (code.isEmpty) return 'Informe o código de convite.';
  if (!isValidInviteCode(code)) {
    return 'O código tem $inviteCodeLength letras/números (sem 0, O, 1 e I).';
  }
  return null;
}

String? validateItemName(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Informe o nome do alimento.';
  if (text.length < 2) return 'O nome deve ter pelo menos 2 caracteres.';
  return null;
}

/// Lê "1,5" ou "1.5". Devolve null se não for número.
double? parseQuantity(String? value) =>
    double.tryParse((value ?? '').trim().replaceAll(',', '.'));

String? validateQuantity(String? value) {
  if ((value ?? '').trim().isEmpty) return 'Informe a quantidade.';
  final quantity = parseQuantity(value);
  if (quantity == null) return 'Quantidade inválida.';
  if (quantity <= 0) return 'A quantidade deve ser maior que zero.';
  return null;
}

String? validateExpiryDate(DateTime? value) {
  if (value == null) return 'Informe a data de validade.';
  return null;
}

String? validateConfirmPassword(String? value, String password) {
  if (value == null || value.isEmpty) return 'Confirme a senha.';
  if (value != password) return 'As senhas não são iguais.';
  return null;
}
