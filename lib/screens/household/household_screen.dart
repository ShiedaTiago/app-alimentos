import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/app_exception.dart';
import '../../models/app_user.dart';
import '../../models/household.dart';
import '../../providers/household_provider.dart';

/// Dados da casa (RF09): nome, código de convite com copiar e membros.
class HouseholdScreen extends StatelessWidget {
  const HouseholdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final household = context.watch<HouseholdProvider>().household;
    return Scaffold(
      appBar: AppBar(title: const Text('Minha casa')),
      body: household == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  household.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _InviteCodeCard(code: household.inviteCode),
                const SizedBox(height: 24),
                Text('Membros', style: Theme.of(context).textTheme.titleMedium),
                // A key faz a lista recarregar quando alguém entra na casa.
                _MemberList(
                  key: ValueKey(household.memberIds.join(',')),
                  household: household,
                ),
              ],
            ),
    );
  }
}

class _InviteCodeCard extends StatelessWidget {
  const _InviteCodeCard({required this.code});

  final String code;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Código copiado.')));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.vpn_key),
        title: const Text('Código de convite'),
        subtitle: Text(
          code,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(letterSpacing: 4),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          tooltip: 'Copiar código',
          onPressed: () => _copy(context),
        ),
      ),
    );
  }
}

class _MemberList extends StatefulWidget {
  const _MemberList({super.key, required this.household});

  final Household household;

  @override
  State<_MemberList> createState() => _MemberListState();
}

class _MemberListState extends State<_MemberList> {
  late Future<List<AppUser>> _members;

  @override
  void initState() {
    super.initState();
    _members = context.read<HouseholdProvider>().fetchMembers();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AppUser>>(
      future: _members,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          final error = snapshot.error;
          return ListTile(
            leading: Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              error is AppException
                  ? error.message
                  : 'Não foi possível carregar os membros.',
            ),
          );
        }
        final members = snapshot.data!;
        if (members.isEmpty) {
          return const ListTile(title: Text('Nenhum membro encontrado.'));
        }
        return Column(
          children: [
            for (final member in members)
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(member.name),
                subtitle: Text(member.email),
                trailing: member.id == widget.household.ownerId
                    ? const Chip(label: Text('Criador'))
                    : null,
              ),
          ],
        );
      },
    );
  }
}
