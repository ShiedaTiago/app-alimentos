import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_utils.dart';
import '../../core/utils/text_utils.dart';
import '../../core/utils/validators.dart';
import '../../models/food_item.dart';
import '../../models/storage_place.dart';
import '../../providers/auth_provider.dart';
import '../../providers/item_provider.dart';
import '../../widgets/error_text.dart';
import '../../widgets/loading_button.dart';

/// Cadastro (sem [itemId]) ou edição (com [itemId]) de alimento (RF13, RF16).
class ItemFormScreen extends StatelessWidget {
  const ItemFormScreen({super.key, this.itemId});

  final String? itemId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemProvider>();
    final isEditing = itemId != null;
    final item = isEditing ? provider.itemById(itemId!) : null;

    Widget body;
    if (provider.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (provider.loadError != null) {
      body = Center(child: ErrorText(provider.loadError));
    } else if (isEditing && item == null) {
      body = const Center(child: Text('Alimento não encontrado.'));
    } else {
      body = _ItemForm(item: item, storages: provider.storages);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar alimento' : 'Novo alimento'),
      ),
      body: body,
    );
  }
}

class _ItemForm extends StatefulWidget {
  const _ItemForm({required this.item, required this.storages});

  final FoodItem? item; // null = cadastro
  final List<StoragePlace> storages;

  @override
  State<_ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<_ItemForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _quantity;
  late final TextEditingController _notes;
  late FoodCategory _category;
  late FoodUnit _unit;
  String? _storageId;
  DateTime? _expiresAt;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _name = TextEditingController(text: item?.name);
    _quantity = TextEditingController(
      text: item == null ? '1' : formatQuantity(item.quantity),
    );
    _notes = TextEditingController(text: item?.notes);
    _category = item?.category ?? FoodCategory.other;
    _unit = item?.unit ?? FoodUnit.unit;
    _expiresAt = item?.expiresAt;
    _storageId =
        item?.storageId ??
        (widget.storages.isEmpty ? null : widget.storages.first.id);
    context.read<ItemProvider>().clearError();
  }

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final notes = _notes.text.trim();
    final original = widget.item;
    // Monta o item inteiro (e não com copyWith) para permitir apagar a observação.
    final item = FoodItem(
      id: original?.id ?? '',
      name: _name.text.trim(),
      category: _category,
      quantity: parseQuantity(_quantity.text)!,
      unit: _unit,
      expiresAt: dateOnly(_expiresAt!),
      storageId: _storageId!,
      notes: notes.isEmpty ? null : notes,
      barcode: original?.barcode,
      source: original?.source ?? ItemSource.manual,
      tagId: original?.tagId,
      lastSeenAt: original?.lastSeenAt,
      addedBy: original?.addedBy ?? context.read<AuthProvider>().user!.uid,
      createdAt: original?.createdAt ?? now,
      updatedAt: now,
    );

    final saved = await context.read<ItemProvider>().save(item);
    if (saved && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemProvider>();
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _name,
            validator: validateItemName,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Nome',
              hintText: 'Ex.: Leite integral',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          _CategoryField(
            value: _category,
            onChanged: (v) => setState(() => _category = v),
          ),
          const SizedBox(height: 16),
          _QuantityRow(
            controller: _quantity,
            unit: _unit,
            onUnitChanged: (v) => setState(() => _unit = v),
          ),
          const SizedBox(height: 16),
          _ExpiryDateField(
            value: _expiresAt,
            onChanged: (v) => setState(() => _expiresAt = v),
          ),
          const SizedBox(height: 16),
          _StorageField(
            storages: widget.storages,
            value: _storageId,
            onChanged: (v) => setState(() => _storageId = v),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notes,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Observação (opcional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          ErrorText(provider.error),
          const SizedBox(height: 8),
          LoadingButton(
            label: 'Salvar',
            isLoading: provider.isBusy,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _CategoryField extends StatelessWidget {
  const _CategoryField({required this.value, required this.onChanged});

  final FoodCategory value;
  final ValueChanged<FoodCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<FoodCategory>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Categoria',
        border: OutlineInputBorder(),
      ),
      items: [
        for (final category in FoodCategory.values)
          DropdownMenuItem(value: category, child: Text(category.label)),
      ],
      onChanged: (v) => onChanged(v!),
    );
  }
}

class _QuantityRow extends StatelessWidget {
  const _QuantityRow({
    required this.controller,
    required this.unit,
    required this.onUnitChanged,
  });

  final TextEditingController controller;
  final FoodUnit unit;
  final ValueChanged<FoodUnit> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: controller,
            validator: validateQuantity,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Quantidade',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<FoodUnit>(
            initialValue: unit,
            decoration: const InputDecoration(
              labelText: 'Unidade',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final u in FoodUnit.values)
                DropdownMenuItem(value: u, child: Text(u.label)),
            ],
            onChanged: (v) => onUnitChanged(v!),
          ),
        ),
      ],
    );
  }
}

/// Campo de validade: abre o calendário (em pt-BR pelo `locale` do app).
/// É um `FormField` para participar do `validate()` do formulário.
class _ExpiryDateField extends StatelessWidget {
  const _ExpiryDateField({required this.value, required this.onChanged});

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  Future<void> _pick(
    BuildContext context,
    FormFieldState<DateTime> field,
  ) async {
    final today = dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? today,
      firstDate: today.subtract(const Duration(days: 365)),
      lastDate: today.add(const Duration(days: 365 * 5)),
      helpText: 'Data de validade',
    );
    if (picked == null) return;
    field.didChange(picked);
    onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: value,
      validator: validateExpiryDate,
      builder: (field) => InkWell(
        onTap: () => _pick(context, field),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Validade',
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
            errorText: field.errorText,
          ),
          isEmpty: field.value == null,
          child: field.value == null ? null : Text(formatDate(field.value!)),
        ),
      ),
    );
  }
}

class _StorageField extends StatelessWidget {
  const _StorageField({
    required this.storages,
    required this.value,
    required this.onChanged,
  });

  final List<StoragePlace> storages;
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    // Se o local salvo não existir mais, deixa o campo vazio para escolher outro.
    final selected = storages.any((s) => s.id == value) ? value : null;
    return DropdownButtonFormField<String>(
      initialValue: selected,
      validator: (v) => v == null ? 'Escolha o local.' : null,
      decoration: const InputDecoration(
        labelText: 'Local',
        border: OutlineInputBorder(),
      ),
      items: [
        for (final storage in storages)
          DropdownMenuItem(value: storage.id, child: Text(storage.name)),
      ],
      onChanged: (v) => onChanged(v!),
    );
  }
}
