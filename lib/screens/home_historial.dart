import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/events_repository.dart';
import '../models/evento.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_header_bar.dart';
import 'event_new_screen.dart';
import 'event_summary_result_screen.dart';
import 'people_manager_screen.dart';
import 'settings_screen.dart';

/// Pantalla principal: historial de eventos pasados. Permite crear un
/// evento nuevo, reabrir uno existente (para verlo o editarlo) o
/// eliminarlo (con confirmación).
class HomeHistorialScreen extends StatefulWidget {
  const HomeHistorialScreen({super.key});

  @override
  State<HomeHistorialScreen> createState() => _HomeHistorialScreenState();
}

class _HomeHistorialScreenState extends State<HomeHistorialScreen> {
  final _repo = EventsRepository();
  List<Evento> _eventos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final eventos = await _repo.getAll();
    setState(() {
      _eventos = eventos;
      _loading = false;
    });
  }

  Future<void> _createNew() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EventNewScreen()),
    );
    _load();
  }

  Future<void> _openEvent(Evento evento) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventSummaryResultScreen(eventId: evento.id),
      ),
    );
    _load();
  }

  Future<void> _deleteEvent(Evento evento) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar evento'),
        content: Text(
            '¿Eliminar "${evento.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await _repo.deleteEvent(evento.id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeaderBar(
        subtitle: 'Historial',
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            tooltip: 'Personas',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PeopleManagerScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Ajustes',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNew,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo evento'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _eventos.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 64, color: AppTheme.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text(
                          'Historial vacío',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Crea tu primer evento para dividir una cuenta con tus amigos.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    itemCount: _eventos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final evento = _eventos[i];
                      final date = DateTime.tryParse(evento.date);
                      final dateStr = date != null
                          ? DateFormat('dd/MM/yyyy', 'es_CL').format(date)
                          : '';
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.surfaceContainerHigh,
                            child: const Icon(Icons.receipt_outlined,
                                color: AppTheme.secondary),
                          ),
                          title: Text(evento.name),
                          subtitle: Text(dateStr),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _deleteEvent(evento),
                          ),
                          onTap: () => _openEvent(evento),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
