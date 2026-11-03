import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_utils.dart';
import '../../core/utils/item_summary.dart';
import '../../models/food_item.dart';
import '../../providers/household_provider.dart';
import '../../providers/item_provider.dart';
import '../../widgets/error_text.dart';
import '../../widgets/expiry_badge.dart';

/// Início: resumo da validade e "consuma primeiro" (RF21).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemProvider>();
    final householdName = context.watch<HouseholdProvider>().household?.name;

    final Widget body;
    if (provider.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (provider.loadError != null) {
      body = Center(child: ErrorText(provider.loadError));
    } else {
      body = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SummaryRow(summary: summarizeItems(provider.items)),
          const SizedBox(height: 24),
          Text(
            'Consuma primeiro',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _ConsumeFirstList(items: consumeFirst(provider.items)),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(householdName ?? 'Início'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Minha casa',
            onPressed: () => context.push('/household'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Adicionar alimento',
        onPressed: () => context.push('/items/new'),
        child: const Icon(Icons.add),
      ),
      body: body,
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary});

  final ItemSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        _SummaryCard(
          label: 'Vencidos',
          value: summary.expired,
          color: ExpiryBadge.colorOf(ExpiryStatus.expired),
        ),
        _SummaryCard(
          label: 'Vencendo',
          value: summary.expiringSoon,
          color: ExpiryBadge.colorOf(ExpiryStatus.critical),
        ),
        _SummaryCard(
          label: 'Total',
          value: summary.total,
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: InkWell(
          // Atalho para a aba Alimentos.
          onTap: () => context.go('/items'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Text(
                  '$value',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(color: color, fontWeight: FontWeight.bold),
                ),
                Text(label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConsumeFirstList extends StatelessWidget {
  const _ConsumeFirstList({required this.items});

  final List<FoodItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Nada para consumir com urgência.\nCadastre alimentos no botão +.',
          textAlign: TextAlign.center,
        ),
      );
    }
    return Card(
      child: Column(
        children: [
          for (final item in items)
            ListTile(
              title: Text(item.name),
              subtitle: Text(formatDate(item.expiresAt)),
              trailing: ExpiryBadge(expiresAt: item.expiresAt),
              onTap: () => context.push('/items/${item.id}/edit'),
            ),
        ],
      ),
    );
  }
}
