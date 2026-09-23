import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../db/events_repository.dart';
import '../models/event_draft.dart';
import '../models/split_result.dart';
import '../services/excel_export_service.dart';
import '../theme/app_theme.dart';
import '../widgets/money_text.dart';
import 'event_item_assignment_screen.dart';
import 'home_inicio_screen.dart';

/// Pantalla final: muestra la tabla de resultados (Detalle / Total / una
/// columna por persona), permite guardar el evento, exportarlo a Excel y
/// compartirlo.
///
/// Se puede llegar aquí de dos formas:
/// - [draft] no nulo: viniendo del flujo de creación/edición (aún no
///   guardado, o editado en memoria).
/// - [eventId] no nulo: abriendo un evento ya guardado desde el historial.
class EventSummaryResultScreen extends StatefulWidget {
  final EventDraft? draft;
  final String? eventId;

  const EventSummaryResultScreen({super.key, this.draft, this.eventId})
      : assert(draft != null || eventId != null);

  @override
  State<EventSummaryResultScreen> createState() => _EventSummaryResultScreenState();
}

class _EventSummaryResultScreenState extends State<EventSummaryResultScreen> {
  final _eventsRepo = EventsRepository();
  final _excelService = ExcelExportService();

  EventDraft? _draft;
  bool _loading = true;
  bool _saving = false;
  bool _exporting = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.draft != null) {
      setState(() {
        _draft = widget.draft;
        _loading = false;
        _dirty = true; // recién armado, aún no guardado en su forma actual
      });
      return;
    }
    final full = await _eventsRepo.getFullEvent(widget.eventId!);
    if (full == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _draft = EventDraft.fromEvento(
          full.evento, full.participants, full.items, full.tipOverrides);
      _loading = false;
      _dirty = false;
    });
  }

  EventBreakdown _computeBreakdown() {
    final draft = _draft!;
    return EventBreakdown.calculate(
      items: draft.items,
      participants: draft.participants,
      evento: draft.toEvento(),
      tipOverrides: draft.tipOverrides,
    );
  }

  Future<void> _save({bool silent = false}) async {
    setState(() => _saving = true);
    try {
      final draft = _draft!;
      await _eventsRepo.saveFullEvent(EventFullData(
        evento: draft.toEvento(),
        participants: draft.participants,
        items: draft.items,
        tipOverrides: draft.tipOverrides,
      ));
      setState(() => _dirty = false);
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento guardado.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _goHome() async {
    if (_dirty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Hay cambios sin guardar'),
          content: const Text(
              'Si vuelves al inicio ahora vas a perder los cambios que no has guardado. ¿Continuar de todas formas?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Volver sin guardar'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeInicioScreen()),
      (route) => false,
    );
  }

  Future<void> _editNameAndDate() async {
    if (_draft == null) return;
    final nameController = TextEditingController(text: _draft!.name);
    DateTime selectedDate = _draft!.date;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Editar evento'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del evento',
                      hintText: 'Ej: Bar',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Fecha'),
                    subtitle:
                        Text(DateFormat('dd/MM/yyyy', 'es_CL').format(selectedDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      setState(() {
        _draft!.name = nameController.text.trim();
        _draft!.date = selectedDate;
        _dirty = true;
      });
      await _save(silent: true);
    }
  }

  Future<void> _editEvent() async {
    if (_draft == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventItemAssignmentScreen(draft: _draft!),
      ),
    );
    setState(() => _dirty = true);
  }

  Future<String?> _ensureSavedAndExport() async {
    // Guarda automáticamente antes de exportar, para que el archivo
    // siempre refleje el estado guardado más reciente.
    await _save(silent: true);
    setState(() => _exporting = true);
    try {
      final breakdown = _computeBreakdown();
      final file = await _excelService.export(
        evento: _draft!.toEvento(),
        participants: _draft!.participants,
        breakdown: breakdown,
      );
      return file.path;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar Excel: $e')),
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _download() async {
    final path = await _ensureSavedAndExport();
    if (path == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Excel guardado en: $path')),
    );
  }

  Future<void> _share() async {
    final path = await _ensureSavedAndExport();
    if (path == null) return;
    await Share.shareXFiles(
      [XFile(path)],
      text: 'Divide Cuenta - ${_draft!.name}',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resumen')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_draft == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resumen')),
        body: const Center(child: Text('No se encontró el evento.')),
      );
    }

    final draft = _draft!;
    final breakdown = _computeBreakdown();

    return Scaffold(
      appBar: AppBar(
        title: Text(draft.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_calendar_outlined),
            tooltip: 'Editar nombre y fecha',
            onPressed: _editNameAndDate,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar ítems y personas',
            onPressed: _editEvent,
          ),
          IconButton(
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_outlined),
            tooltip: 'Guardar',
            onPressed: _saving ? null : () => _save(),
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Volver al inicio',
            onPressed: _goHome,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
        children: [
          if (_dirty)
            Container(
              width: double.infinity,
              color: AppTheme.warning.withOpacity(0.16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text('Hay cambios sin guardar.',
                  style: TextStyle(fontSize: 12, color: AppTheme.warning)),
            ),
          Expanded(child: _buildTable(draft, breakdown)),
          _buildActionsBar(),
        ],
      ),
      ),
    );
  }

  Widget _buildTable(EventDraft draft, EventBreakdown breakdown) {
    final columns = <DataColumn>[
      const DataColumn(label: Text('DETALLE')),
      const DataColumn(label: Text('TOTAL'), numeric: true),
      ...draft.participants.map((p) => DataColumn(label: Text(p.name), numeric: true)),
    ];

    final rows = <DataRow>[
      for (final row in breakdown.rows)
        DataRow(cells: [
          DataCell(Text(row.item.name)),
          DataCell(MoneyText(row.item.totalPrice)),
          ...draft.participants.map((p) {
            final amount = row.shares[p.id];
            return DataCell(Text(amount != null ? _fmt(amount) : ''));
          }),
        ]),
      DataRow(
        color: WidgetStateProperty.all(AppTheme.surfaceContainerHigh),
        cells: [
          const DataCell(Text('Consumo', style: TextStyle(fontWeight: FontWeight.bold))),
          DataCell(MoneyText(breakdown.consumoTotal,
              style: const TextStyle(fontWeight: FontWeight.bold))),
          ...draft.participants.map((p) => DataCell(Text(
              _fmt(breakdown.consumoPorPersona[p.id] ?? 0),
              style: const TextStyle(fontWeight: FontWeight.bold)))),
        ],
      ),
      if (draft.tipEnabled)
        DataRow(cells: [
          const DataCell(Text('Propina')),
          DataCell(MoneyText(breakdown.propinaTotal)),
          ...draft.participants
              .map((p) => DataCell(Text(_fmt(breakdown.propinaPorPersona[p.id] ?? 0)))),
        ]),
      DataRow(
        color: WidgetStateProperty.all(AppTheme.success.withOpacity(0.18)),
        cells: [
          const DataCell(
              Text('Total más propina', style: TextStyle(fontWeight: FontWeight.bold))),
          DataCell(MoneyText(breakdown.totalFinal,
              style: const TextStyle(fontWeight: FontWeight.bold))),
          ...draft.participants.map((p) => DataCell(Text(
              _fmt(breakdown.totalPorPersona[p.id] ?? 0),
              style: const TextStyle(fontWeight: FontWeight.bold)))),
        ],
      ),
    ];

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(12),
        child: DataTable(columns: columns, rows: rows),
      ),
    );
  }

  Widget _buildActionsBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _exporting ? null : _download,
              icon: const Icon(Icons.download),
              label: const Text('Descargar Excel'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton.icon(
              onPressed: _exporting ? null : _share,
              icon: _exporting
                  ? const SizedBox(
                      width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.share),
              label: const Text('Compartir'),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int v) {
    final s = v.abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return (v < 0 ? '-' : '') + buf.toString();
  }
}
