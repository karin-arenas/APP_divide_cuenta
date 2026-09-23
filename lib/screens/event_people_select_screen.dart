import 'package:flutter/material.dart';

import '../db/people_repository.dart';
import '../models/event_draft.dart';
import '../models/person.dart';
import 'event_ocr_capture_screen.dart';

/// Selección de personas participantes del evento, desde la libreta
/// persistente. Permite agregar personas nuevas al vuelo (que también
/// quedan guardadas para el futuro).
class EventPeopleSelectScreen extends StatefulWidget {
  final EventDraft draft;
  const EventPeopleSelectScreen({super.key, required this.draft});

  @override
  State<EventPeopleSelectScreen> createState() => _EventPeopleSelectScreenState();
}

class _EventPeopleSelectScreenState extends State<EventPeopleSelectScreen> {
  final _repo = PeopleRepository();
  List<Person> _allPeople = [];
  final Set<String> _selected = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selected.addAll(widget.draft.participants.map((p) => p.id));
    _load();
  }

  Future<void> _load() async {
    final people = await _repo.getAll();
    setState(() {
      _allPeople = people;
      _loading = false;
    });
  }

  Future<void> _addNewPerson() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar persona'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Nombre / apodo'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    final person = await _repo.findOrCreateByName(name);
    setState(() {
      _selected.add(person.id);
    });
    _load();
  }

  void _continue() {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elige al menos una persona.')),
      );
      return;
    }
    widget.draft.participants =
        _allPeople.where((p) => _selected.contains(p.id)).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => EventOcrCaptureScreen(draft: widget.draft)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personas'),
        actions: [
          IconButton(icon: const Icon(Icons.person_add), onPressed: _addNewPerson),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _allPeople.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('No tienes personas guardadas todavía.'),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _addNewPerson,
                          icon: const Icon(Icons.person_add),
                          label: const Text('Agregar persona'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _allPeople.length,
                  itemBuilder: (ctx, i) {
                    final p = _allPeople[i];
                    final checked = _selected.contains(p.id);
                    return CheckboxListTile(
                      value: checked,
                      title: Text(p.name),
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _selected.add(p.id);
                          } else {
                            _selected.remove(p.id);
                          }
                        });
                      },
                    );
                  },
                ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _continue,
            child: Text('Continuar (${_selected.length} seleccionadas)'),
          ),
        ),
      ),
    );
  }
}
