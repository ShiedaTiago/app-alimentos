import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/household_provider.dart';
import '../../widgets/auth_layout.dart';
import '../../widgets/error_text.dart';
import '../../widgets/loading_button.dart';

/// Primeiro acesso: criar uma casa ou entrar numa existente com o código.
/// Quando dá certo, o redirect do router leva para a Home sozinho.
class HouseholdSetupScreen extends StatefulWidget {
  const HouseholdSetupScreen({super.key});

  @override
  State<HouseholdSetupScreen> createState() => _HouseholdSetupScreenState();
}

class _HouseholdSetupScreenState extends State<HouseholdSetupScreen> {
  bool _joining = false;

  @override
  void initState() {
    super.initState();
    context.read<HouseholdProvider>().clearError();
  }

  void _setJoining(bool value) {
    context.read<HouseholdProvider>().clearError();
    setState(() => _joining = value);
  }

  @override
  Widget build(BuildContext context) {
    final household = context.watch<HouseholdProvider>();
    return AuthLayout(
      title: 'Sua casa',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Criar casa')),
              ButtonSegment(value: true, label: Text('Entrar com código')),
            ],
            selected: {_joining},
            onSelectionChanged: (s) => _setJoining(s.first),
          ),
          const SizedBox(height: 24),
          if (_joining) const _JoinForm() else const _CreateForm(),
          const SizedBox(height: 8),
          ErrorText(household.error),
          TextButton(
            onPressed: () => context.read<AuthProvider>().signOut(),
            child: const Text('Sair da conta'),
          ),
        ],
      ),
    );
  }
}

class _CreateForm extends StatefulWidget {
  const _CreateForm();

  @override
  State<_CreateForm> createState() => _CreateFormState();
}

class _CreateFormState extends State<_CreateForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<HouseholdProvider>().create(_name.text);
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = context.watch<HouseholdProvider>().isBusy;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _name,
            validator: validateHouseholdName,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Nome da casa',
              hintText: 'Ex.: Casa do Tiago',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          LoadingButton(
            label: 'Criar casa',
            isLoading: isBusy,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _JoinForm extends StatefulWidget {
  const _JoinForm();

  @override
  State<_JoinForm> createState() => _JoinFormState();
}

class _JoinFormState extends State<_JoinForm> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<HouseholdProvider>().join(_code.text);
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = context.watch<HouseholdProvider>().isBusy;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _code,
            validator: validateInviteCodeInput,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Código de convite',
              hintText: 'Peça a um membro da casa',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          LoadingButton(label: 'Entrar', isLoading: isBusy, onPressed: _submit),
        ],
      ),
    );
  }
}
