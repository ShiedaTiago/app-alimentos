import '../constants.dart';

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

String? validateConfirmPassword(String? value, String password) {
  if (value == null || value.isEmpty) return 'Confirme a senha.';
  if (value != password) return 'As senhas não são iguais.';
  return null;
}
