import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_utils.dart';
import '../../core/utils/epc.dart';
import '../../models/food_item.dart';
import '../../models/rfid_tag.dart';
import '../../providers/item_provider.dart';
import '../../providers/tag_provider.dart';
import '../../widgets/error_text.dart';

/// Tela de debug (RF25): faz o papel da antena RFID + ESP32 do TCC,
/// escrevendo etiquetas na coleção `tags` da casa.
class RfidSimulatorScreen extends StatelessWidget {
  const RfidSimulatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tags = context.watch<TagProvider>();

    final Widget body;
    if (tags.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (tags.loadError != null) {
      body = Center(child: ErrorText(tags.loadError));
    } else if (tags.tags.isEmpty) {
      body = const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Nenhuma etiqueta lida ainda.\n'
            'Toque em "Simular etiqueta nova".',
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      body = ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [for (final tag in tags.tags) _TagTile(tag: tag)],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Simulador RFID')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.sensors),
        label: const Text('Simular etiqueta nova'),
        onPressed: tags.isBusy ? null : () => _simulateNewTag(context),
      ),
      body: body,
    );
  }

  Future<void> _simulateNewTag(BuildContext context) async {
    final storages = context.read<ItemProvider>().storages;
    if (storages.isEmpty) {
      _showMessage(context, 'Cadastre um local antes de simular.');
      return;
    }
    final tags = context.read<TagProvider>();
    // Simplificação: a "antena" fica no primeiro local da casa.
    final ok = await tags.simulateNewTag(storages.first.id);
    if (!ok && context.mounted) _showMessage(context, tags.error!);
  }
}

class _TagTile extends StatelessWidget {
  const _TagTile({required this.tag});

  final RfidTag tag;

  @override
  Widget build(BuildContext context) {
    final itemName = tag.itemId == null
        ? null
        : context.watch<ItemProvider>().itemById(tag.itemId!)?.name;
    final isPending = tag.status == TagStatus.pending;

    return ListTile(
      leading: Icon(
        isPending ? Icons.new_releases : Icons.link,
        color: isPending ? Theme.of(context).colorScheme.tertiary : null,
      ),
      title: Text(shortEpc(tag.id)),
      subtitle: Text(
        '${isPending ? 'Nova etiqueta' : itemName ?? 'Alimento fechado'}'
        ' · lida em ${formatDateTime(tag.lastSeenAt)}',
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (action) => _onAction(context, action),
        itemBuilder: (_) => [
          if (isPending)
            const PopupMenuItem(value: 'link', child: Text('Vincular')),
          const PopupMenuItem(value: 'read', child: Text('Simular leitura')),
          const PopupMenuItem(value: 'delete', child: Text('Excluir')),
        ],
      ),
      onTap: isPending ? () => _onAction(context, 'link') : null,
    );
  }

  Future<void> _onAction(BuildContext context, String action) async {
    final tags = context.read<TagProvider>();
    final bool ok;
    switch (action) {
      case 'link':
        final item = await showLinkTagDialog(context);
        if (item == null) return;
        ok = await tags.linkTag(tag.id, item.id);
        if (ok && context.mounted) {
          _showMessage(context, 'Etiqueta vinculada a ${item.name}.');
        }
      case 'read':
        ok = await tags.simulateReading(tag);
      default:
        ok = await tags.delete(tag.id);
    }
    if (!ok && context.mounted) _showMessage(context, tags.error!);
  }
}

/// Pergunta a qual alimento ativo (ainda sem etiqueta) a tag pertence.
Future<FoodItem?> showLinkTagDialog(BuildContext context) {
  final items = context
      .read<ItemProvider>()
      .items
      .where((item) => item.tagId == null)
      .toList();
  return showDialog<FoodItem>(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text('Nova etiqueta detectada'),
      children: [
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Nenhum alimento sem etiqueta. Cadastre um antes.'),
          ),
        for (final item in items)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, item),
            child: Text('${item.name} · vence ${formatDate(item.expiresAt)}'),
          ),
      ],
    ),
  );
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
