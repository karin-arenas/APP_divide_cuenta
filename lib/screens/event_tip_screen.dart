import 'package:flutter/material.dart';

import '../models/event_draft.dart';
import '../models/evento.dart';
import 'event_summary_result_screen.dart';

/// Configuración de propina: porcentaje global (editable, por defecto 10%),
/// posibilidad de desactivarla del todo, y anulaciones por persona (monto
/// plano, otro porcentaje, o sin propina para esa persona).
class EventTipScreen extends StatefulWidget {
  final EventDraft draft;
  const EventTipScreen({super.key, required this.draft});

  @override
  State<EventTipScreen> createState() => _EventTipScreenState();
}

class _EventTipScreenState extends State<EventTipScreen> {
  late TextEditingController _percentController;

  @override
  void initState() {
    super.initState();
    _percentController =
        TextEditingController(text: widget.draft.tipPercent.toStringAsFixed(0));
  }

  TipOverride? _overrideFor(String personId) {
    for (final o in widget.draft.tipOverrides) {
      if (o.personId == personId) return o;
    }
    return null;
  }

  void _setOverride(String personId, String type, double value) {
    setState(() {
      widget.draft.tipOverrides.removeWhere((o) => o.personId == personId);
      if (type != 'default') {
        widget.draft.tipOverrides.add(TipOverride(
          eventId: widget.draft.id,
          personId: personId,
          type: type,
          value: value,
        ));
      }
    });
  }

  Future<void> _editOverride(String personId, String personName) async {
    final current = _overrideFor(personId);
    String type = current?.type ?? 'default';
    final valueController =
        TextEditingController(text: (current?.value ?? 0).toStringAsFixed(0));

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          title: Text('Propina para $personName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                value: 'default',
                groupValue: type,
                title: Text('Usar % general (${widget.draft.tipPercent.toStringAsFixed(0)}%)'),
                onChanged: (v) => setLocalState(() => type = v!),
              ),
              RadioListTile<String>(
                value: 'percent',
                groupValue: type,
                title: const Text('Otro porcentaje'),
                onChanged: (v) => setLocalState(() => type = v!),
              ),
              RadioListTile<String>(
                value: 'flat',
                groupValue: type,
                title: const Text('Monto fijo'),
                onChanged: (v) => setLocalState(() => type = v!),
              ),
              RadioListTile<String>(
                value: 'none',
                groupValue: type,
                title: const Text('Sin propina'),
                onChanged: (v) => setLocalState(() => type = v!),
              ),
              if (type == 'percent' || type == 'flat')
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextField(
                    controller: valueController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: type == 'percent' ? 'Porcentaje (%)' : 'Monto (\$)',
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, {
                'type': type,
                'value': double.tryParse(valueController.text.replaceAll(',', '.')) ?? 0,
              }),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;
    _setOverride(personId, result['type'] as String, result['value'] as double);
  }

  void _continue() {
    widget.draft.tipPercent =
        double.tryParse(_percentController.text.replaceAll(',', '.')) ?? 10;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventSummaryResultScreen(draft: widget.draft),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Propina')),
      body: SafeArea(
        child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Aplicar propina'),
            value: widget.draft.tipEnabled,
            onChanged: (v) => setState(() => widget.draft.tipEnabled = v),
          ),
          if (widget.draft.tipEnabled) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _percentController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Porcentaje de propina general',
                suffixText: '%',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text('Personalizar por persona (opcional)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...widget.draft.participants.map((p) {
              final override = _overrideFor(p.id);
              String subtitle;
              if (override == null) {
                subtitle = 'Usa el % general';
              } else if (override.type == 'none') {
                subtitle = 'Sin propina';
              } else if (override.type == 'flat') {
                subtitle = 'Monto fijo: \$${override.value.toStringAsFixed(0)}';
              } else {
                subtitle = '${override.value.toStringAsFixed(0)}% personalizado';
              }
              return ListTile(
                title: Text(p.name),
                subtitle: Text(subtitle),
                trailing: const Icon(Icons.edit),
                onTap: () => _editOverride(p.id, p.name),
              );
            }),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _continue,
            child: const Text('Ver resumen final'),
          ),
        ],
      ),
      ),
    );
  }
}
