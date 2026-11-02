import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_layout.dart';
import '../../widgets/error_text.dart';
import '../../widgets/loading_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthProvider>().clearError();
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().sendPasswordReset(_email.text);
    if (ok && mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AuthLayout(
      title: 'Recuperar senha',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Informe seu e-mail e enviaremos um link para criar uma nova senha.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              validator: validateEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ErrorText(auth.error),
            if (_sent)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Pronto! Se o e-mail estiver cadastrado, você receberá o link em instantes.',
                  textAlign: TextAlign.center,
                ),
              ),
            LoadingButton(
              label: 'Enviar link',
              isLoading: auth.isBusy,
              onPressed: _submit,
            ),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Voltar para o login'),
            ),
          ],
        ),
      ),
    );
  }
}
