import 'package:flutter/material.dart';

import '../db/people_repository.dart';
import '../models/person.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_header_bar.dart';

/// Libreta de personas: lista persistente y reutilizable entre eventos.
/// Permite agregar, renombrar y eliminar personas independientemente de
/// cualquier evento.
class PeopleManagerScreen extends StatefulWidget {
  const PeopleManagerScreen({super.key});

  @override
  State<PeopleManagerScreen> createState() => _PeopleManagerScreenState();
}

class _PeopleManagerScreenState extends State<PeopleManagerScreen> {
  final _repo = PeopleRepository();
  List<Person> _people = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final people = await _repo.getAll();
    setState(() {
      _people = people;
      _loading = false;
    });
  }

  Future<void> _addPerson() async {
    final name = await _promptName(title: 'Agregar persona');
    if (name == null || name.trim().isEmpty) return;
    await _repo.add(name);
    _load();
  }

  Future<void> _renamePerson(Person p) async {
    final name = await _promptName(title: 'Renombrar', initial: p.name);
    if (name == null || name.trim().isEmpty) return;
    await _repo.rename(p.id, name);
    _load();
  }

  Future<void> _deletePerson(Person p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar persona'),
        content: Text(
            '¿Eliminar a "${p.name}" de la libreta? No se borrará de eventos ya guardados, pero no podrás elegirla en eventos nuevos.'),
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
    await _repo.delete(p.id);
    _load();
  }

  Future<String?> _promptName({required String title, String initial = ''}) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nombre / apodo'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeaderBar(subtitle: 'Contactos frecuentes'),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPerson,
        child: const Icon(Icons.person_add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _people.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Aún no tienes personas guardadas. Agrega amigos para reutilizarlos en tus eventos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.onSurfaceVariant),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  itemCount: _people.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final p = _people[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryContainer,
                          child: Text(
                            p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                                color: Color(0xFF090D16),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(p.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _renamePerson(p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deletePerson(p),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
