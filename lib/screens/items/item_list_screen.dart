import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_utils.dart';
import '../../core/utils/item_filter.dart';
import '../../core/utils/text_utils.dart';
import '../../models/food_item.dart';
import '../../models/storage_place.dart';
import '../../providers/item_provider.dart';
import '../../widgets/error_text.dart';
import '../../widgets/expiry_badge.dart';

/// Lista de alimentos ativos por validade, com busca e filtros (RF14, RF15).
class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  String _query = '';
  String? _storageId;
  ExpiryStatus? _status;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemProvider>();
    final filtered = filterItems(
      provider.items,
      storageId: _storageId,
      status: _status,
      query: _query,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Alimentos')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Adicionar alimento',
        onPressed: () => context.push('/items/new'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Buscar por nome',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          _FilterBar(
            storages: provider.storages,
            storageId: _storageId,
            status: _status,
            onStorageChanged: (v) => setState(() => _storageId = v),
            onStatusChanged: (v) => setState(() => _status = v),
          ),
          Expanded(child: _buildBody(provider, filtered)),
        ],
      ),
    );
  }

  Widget _buildBody(ItemProvider provider, List<FoodItem> filtered) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.loadError != null) {
      return Center(child: ErrorText(provider.loadError));
    }
    if (provider.items.isEmpty) {
      return const _EmptyMessage(
        'Nenhum alimento cadastrado.\nToque em + para adicionar.',
      );
    }
    if (filtered.isEmpty) {
      return const _EmptyMessage('Nenhum alimento com esses filtros.');
    }
    final storageNames = {for (final s in provider.storages) s.id: s.name};
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 88), // espaço para o botão +
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) => _ItemTile(
        item: filtered[i],
        storageName: storageNames[filtered[i].storageId] ?? '',
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.storages,
    required this.storageId,
    required this.status,
    required this.onStorageChanged,
    required this.onStatusChanged,
  });

  final List<StoragePlace> storages;
  final String? storageId;
  final ExpiryStatus? status;
  final ValueChanged<String?> onStorageChanged;
  final ValueChanged<ExpiryStatus?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    // Tocar no chip já selecionado desmarca (volta a mostrar todos).
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        spacing: 8,
        children: [
          for (final storage in storages)
            FilterChip(
              label: Text(storage.name),
              selected: storageId == storage.id,
              onSelected: (on) => onStorageChanged(on ? storage.id : null),
            ),
          const SizedBox(height: 24, child: VerticalDivider()),
          for (final s in ExpiryStatus.values)
            FilterChip(
              label: Text(ExpiryBadge.labelOf(s)),
              selected: status == s,
              onSelected: (on) => onStatusChanged(on ? s : null),
            ),
        ],
      ),
    );
  }
}

enum _ItemAction { consumed, discarded, delete }

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item, required this.storageName});

  final FoodItem item;
  final String storageName;

  Future<void> _onAction(BuildContext context, _ItemAction action) async {
    final provider = context.read<ItemProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final bool ok;
    switch (action) {
      case _ItemAction.consumed:
        ok = await provider.close(item.id, ItemStatus.consumed);
      case _ItemAction.discarded:
        ok = await provider.close(item.id, ItemStatus.discarded);
      case _ItemAction.delete:
        if (!await _confirmDelete(context)) return;
        ok = await provider.delete(item.id);
    }
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text(provider.error ?? '')));
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir alimento?'),
        content: Text(
          '"${item.name}" será apagado de vez, sem ir para o histórico.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.name),
      subtitle: Text(
        '${formatQuantity(item.quantity)} ${item.unit.label} · $storageName · ${formatDate(item.expiresAt)}',
      ),
      leading: ExpiryBadge(expiresAt: item.expiresAt),
      onTap: () => context.push('/items/${item.id}/edit'),
      trailing: PopupMenuButton<_ItemAction>(
        tooltip: 'Ações',
        onSelected: (action) => _onAction(context, action),
        itemBuilder: (_) => const [
          PopupMenuItem(value: _ItemAction.consumed, child: Text('Consumido')),
          PopupMenuItem(
            value: _ItemAction.discarded,
            child: Text('Descartado'),
          ),
          PopupMenuItem(value: _ItemAction.delete, child: Text('Excluir')),
        ],
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}
