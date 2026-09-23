import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/events_repository.dart';
import '../models/evento.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_header_bar.dart';
import 'event_new_screen.dart';
import 'event_summary_result_screen.dart';
import 'home_historial.dart';
import 'people_manager_screen.dart';
import 'settings_screen.dart';

/// Pantalla de Inicio: dashboard con acceso rápido a "Nuevo Ticket" y a
/// los últimos eventos, inspirada en `design_reference/screens/inicio.html`.
class HomeInicioScreen extends StatefulWidget {
  const HomeInicioScreen({super.key});

  @override
  State<HomeInicioScreen> createState() => _HomeInicioScreenState();
}

class _HomeInicioScreenState extends State<HomeInicioScreen> {
  final _repo = EventsRepository();
  List<Evento> _recent = [];
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
      _recent = eventos.take(4).toList();
      _loading = false;
    });
  }

  Future<void> _newEvent() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const EventNewScreen()));
    _load();
  }

  Future<void> _openEvent(Evento evento) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => EventSummaryResultScreen(eventId: evento.id)),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeaderBar(subtitle: 'Panel principal'),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'DIVIDE Y COMPARTE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.secondary,
                        letterSpacing: 1.5,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Bienvenido', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              'Escanea una boleta y divide la cuenta al instante.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            _NewTicketCard(onTap: _newEvent),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.group_outlined,
                    label: 'Contactos',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PeopleManagerScreen())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.api_outlined,
                    label: 'API Gemini',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Actividad reciente',
                    style: Theme.of(context).textTheme.titleMedium),
                TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HomeHistorialScreen())),
                  child: const Text('Ver todo'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_recent.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 40, color: AppTheme.onSurfaceVariant),
                      const SizedBox(height: 10),
                      Text(
                        'Todavía no tienes eventos. Toca "Nuevo Ticket" para dividir tu primera cuenta.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._recent.map((e) => _RecentEventTile(
                    evento: e,
                    onTap: () => _openEvent(e),
                  )),
          ],
        ),
      ),
    );
  }
}

class _NewTicketCard extends StatelessWidget {
  final VoidCallback onTap;
  const _NewTicketCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: const Icon(Icons.photo_camera_outlined,
                    color: Color(0xFF090D16), size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nuevo Ticket',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      'Escanea o sube la foto de una boleta',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppTheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.secondary),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentEventTile extends StatelessWidget {
  final Evento evento;
  final VoidCallback onTap;
  const _RecentEventTile({required this.evento, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(evento.date);
    final dateStr =
        date != null ? DateFormat('dd/MM/yyyy', 'es_CL').format(date) : '';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppTheme.surfaceContainerHigh,
          child: const Icon(Icons.receipt_outlined, color: AppTheme.secondary),
        ),
        title: Text(evento.name),
        subtitle: Text(dateStr),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.onSurfaceVariant),
      ),
    );
  }
}
