import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_layout.dart';
import '../../widgets/error_text.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/password_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AuthProvider>().clearError();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // Se o login der certo, o redirect do router leva para a Home sozinho.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthProvider>().signIn(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AuthLayout(
      title: 'Gestão de Alimentos',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _email,
              validator: validateEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _password,
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Informe a senha.' : null,
              textInputAction: TextInputAction.done,
              onSubmitted: _submit,
            ),
            const SizedBox(height: 16),
            ErrorText(auth.error),
            LoadingButton(
              label: 'Entrar',
              isLoading: auth.isBusy,
              onPressed: _submit,
            ),
            TextButton(
              onPressed: () => context.push('/forgot-password'),
              child: const Text('Esqueci minha senha'),
            ),
            TextButton(
              onPressed: () => context.push('/register'),
              child: const Text('Criar conta'),
            ),
          ],
        ),
      ),
    );
  }
}
