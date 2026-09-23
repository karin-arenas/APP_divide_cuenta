import 'package:flutter/material.dart';

import '../models/event_draft.dart';
import '../models/split_result.dart';
import '../theme/app_theme.dart';
import '../widgets/money_text.dart';
import '../widgets/person_chip_selector.dart';
import 'event_extra_items_screen.dart';

/// Para cada ítem confirmado, el usuario elige qué personas lo comparten.
/// El precio se reparte en partes iguales entre las seleccionadas. Muestra
/// un total corriente por persona a medida que se van asignando ítems.
class EventItemAssignmentScreen extends StatefulWidget {
  final EventDraft draft;
  const EventItemAssignmentScreen({super.key, required this.draft});

  @override
  State<EventItemAssignmentScreen> createState() =>
      _EventItemAssignmentScreenState();
}

class _EventItemAssignmentScreenState extends State<EventItemAssignmentScreen> {
  void _toggle(int itemIndex, String personId) {
    setState(() {
      final item = widget.draft.items[itemIndex];
      final list = List<String>.of(item.sharedByPersonIds);
      if (list.contains(personId)) {
        list.remove(personId);
      } else {
        list.add(personId);
      }
      widget.draft.items[itemIndex] = item.copyWith(sharedByPersonIds: list);
    });
  }

  void _assignAll(int itemIndex) {
    setState(() {
      final item = widget.draft.items[itemIndex];
      widget.draft.items[itemIndex] = item.copyWith(
        sharedByPersonIds: widget.draft.participants.map((p) => p.id).toList(),
      );
    });
  }

  Map<String, int> get _runningTotals {
    final totals = <String, int>{for (final p in widget.draft.participants) p.id: 0};
    for (final item in widget.draft.items) {
      final ids = item.sharedByPersonIds
          .where((id) => totals.containsKey(id))
          .toList();
      final shares = RoundedSplit.distribute(item.totalPrice, ids);
      for (final e in shares.entries) {
        totals[e.key] = (totals[e.key] ?? 0) + e.value;
      }
    }
    return totals;
  }

  bool get _allAssigned =>
      widget.draft.items.every((i) => i.sharedByPersonIds.isNotEmpty);

  void _continue() {
    if (!_allAssigned) {
      final proceed = showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ítems sin asignar'),
          content: const Text(
              'Hay ítems sin ninguna persona asignada; su costo no se repartirá. ¿Continuar de todas formas?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Volver')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Continuar')),
          ],
        ),
      );
      proceed.then((v) {
        if (v == true) _goNext();
      });
      return;
    }
    _goNext();
  }

  void _goNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => EventExtraItemsScreen(draft: widget.draft)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totals = _runningTotals;
    return Scaffold(
      appBar: AppBar(title: const Text('¿Quién comió qué?')),
      body: SafeArea(
        child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: widget.draft.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final item = widget.draft.items[i];
                final selected = item.sharedByPersonIds.toSet();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(item.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            MoneyText(item.totalPrice,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        PersonChipSelector(
                          people: widget.draft.participants,
                          selectedIds: selected,
                          onToggle: (id) => _toggle(i, id),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => _assignAll(i),
                            child: const Text('Todos'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              border: Border(top: BorderSide(color: AppTheme.outlineVariant)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total corriente por persona',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: widget.draft.participants.map((p) {
                    return Chip(
                      label: Text('${p.name}: ${formatMoney(totals[p.id] ?? 0)}'),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _continue,
                    child: const Text('Continuar'),
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
}
