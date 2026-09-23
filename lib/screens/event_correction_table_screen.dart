import 'package:flutter/material.dart';

import '../models/event_draft.dart';
import '../models/receipt_item.dart';
import '../theme/app_theme.dart';
import '../widgets/money_text.dart';
import 'event_item_assignment_screen.dart';

/// Paso obligatorio antes de asignar personas: el usuario revisa y corrige
/// los ítems detectados por OCR (o los ingresa desde cero si viene del
/// flujo manual). Se puede editar nombre/cantidad/precio, borrar filas y
/// agregar filas faltantes.
class EventCorrectionTableScreen extends StatefulWidget {
  final EventDraft draft;
  final List<ReceiptItem> initialItems;

  const EventCorrectionTableScreen({
    super.key,
    required this.draft,
    required this.initialItems,
  });

  @override
  State<EventCorrectionTableScreen> createState() =>
      _EventCorrectionTableScreenState();
}

class _EventCorrectionTableScreenState extends State<EventCorrectionTableScreen> {
  late List<ReceiptItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.initialItems);
  }

  Future<void> _editItem({ReceiptItem? existing}) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final qtyController =
        TextEditingController(text: (existing?.quantity ?? 1).toString());
    final priceController =
        TextEditingController(text: (existing?.totalPrice ?? 0).toString());

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Agregar ítem' : 'Editar ítem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nombre del ítem'),
            ),
            TextField(
              controller: qtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Cantidad'),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Precio total (\$, sólo el ítem completo)'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, {
              'name': nameController.text,
              'qty': qtyController.text,
              'price': priceController.text,
            }),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result == null) return;
    final name = result['name']!.trim().isEmpty ? 'Ítem' : result['name']!.trim();
    final qty = double.tryParse(result['qty']!.replaceAll(',', '.')) ?? 1;
    final total = int.tryParse(result['price']!.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final unit = qty > 0 ? (total / qty).round() : total;

    setState(() {
      if (existing != null) {
        final idx = _items.indexWhere((i) => i.id == existing.id);
        _items[idx] = existing.copyWith(
          name: name,
          quantity: qty,
          unitPrice: unit,
          totalPrice: total,
        );
      } else {
        _items.add(ReceiptItem(
          id: widget.draft.newItemId(),
          eventId: widget.draft.id,
          name: name,
          quantity: qty,
          unitPrice: unit,
          totalPrice: total,
        ));
      }
    });
  }

  void _deleteItem(ReceiptItem item) {
    setState(() => _items.removeWhere((i) => i.id == item.id));
  }

  void _continue() {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos un ítem antes de continuar.')),
      );
      return;
    }
    widget.draft.items = _items;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => EventItemAssignmentScreen(draft: widget.draft)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _items.fold<int>(0, (a, b) => a + b.totalPrice);
    return Scaffold(
      appBar: AppBar(title: const Text('Revisar ítems')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editItem(),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
        children: [
          Expanded(
            child: _items.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No hay ítems todavía. Usa el botón + para agregarlos.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final item = _items[i];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text(
                            'Cant: ${_fmtQty(item.quantity)} · Unit: ${formatMoney(item.unitPrice)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MoneyText(item.totalPrice,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _editItem(existing: item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                              onPressed: () => _deleteItem(item),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              border: Border(top: BorderSide(color: AppTheme.outlineVariant)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal', style: TextStyle(fontWeight: FontWeight.bold)),
                    MoneyText(total, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _continue,
                    child: const Text('Confirmar y asignar personas'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  String _fmtQty(double q) {
    if (q == q.roundToDouble()) return q.toInt().toString();
    return q.toString();
  }
}
