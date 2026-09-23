import 'package:flutter/material.dart';

import '../models/event_draft.dart';
import '../models/receipt_item.dart';
import '../theme/app_theme.dart';
import '../widgets/money_text.dart';
import '../widgets/person_chip_selector.dart';
import 'event_tip_screen.dart';

/// Permite agregar "consumos adicionales" que no estaban en la boleta
/// original (ej: un cover, una ronda extra), con la misma mecánica de
/// reparto por persona.
class EventExtraItemsScreen extends StatefulWidget {
  final EventDraft draft;
  const EventExtraItemsScreen({super.key, required this.draft});

  @override
  State<EventExtraItemsScreen> createState() => _EventExtraItemsScreenState();
}

class _EventExtraItemsScreenState extends State<EventExtraItemsScreen> {
  List<ReceiptItem> get _extras =>
      widget.draft.items.where((i) => i.isExtra).toList();

  Future<void> _addExtra() async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final selected = <String>{};

    final added = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          title: const Text('Agregar consumo adicional'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Precio total (\$)'),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('¿Quién comparte este gasto?',
                      style: Theme.of(ctx).textTheme.bodySmall),
                ),
                const SizedBox(height: 4),
                PersonChipSelector(
                  people: widget.draft.participants,
                  selectedIds: selected,
                  onToggle: (id) {
                    setLocalState(() {
                      if (selected.contains(id)) {
                        selected.remove(id);
                      } else {
                        selected.add(id);
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );

    if (added != true) return;
    final name = nameController.text.trim().isEmpty
        ? 'Consumo adicional'
        : nameController.text.trim();
    final price =
        int.tryParse(priceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    setState(() {
      widget.draft.items.add(ReceiptItem(
        id: widget.draft.newItemId(),
        eventId: widget.draft.id,
        name: name,
        quantity: 1,
        unitPrice: price,
        totalPrice: price,
        isExtra: true,
        sharedByPersonIds: selected.toList(),
      ));
    });
  }

  void _deleteExtra(ReceiptItem item) {
    setState(() => widget.draft.items.removeWhere((i) => i.id == item.id));
  }

  void _continue() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventTipScreen(draft: widget.draft)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final extras = _extras;
    return Scaffold(
      appBar: AppBar(title: const Text('Consumos adicionales')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExtra,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
        children: [
          Expanded(
            child: extras.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Sin consumos adicionales. Si no hay nada más que agregar (propinas de más, cover, otra ronda), continúa directamente.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.onSurfaceVariant),
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: extras.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final item = extras[i];
                      final names = widget.draft.participants
                          .where((p) => item.sharedByPersonIds.contains(p.id))
                          .map((p) => p.name)
                          .join(', ');
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text(names.isEmpty ? 'Sin asignar' : names),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MoneyText(item.totalPrice,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteExtra(item),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _continue,
                child: const Text('Continuar a propina'),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
