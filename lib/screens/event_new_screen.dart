import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event_draft.dart';
import 'event_people_select_screen.dart';

/// Primer paso para crear un evento nuevo: nombre y fecha.
class EventNewScreen extends StatefulWidget {
  const EventNewScreen({super.key});

  @override
  State<EventNewScreen> createState() => _EventNewScreenState();
}

class _EventNewScreenState extends State<EventNewScreen> {
  final _nameController = TextEditingController();
  DateTime _date = DateTime.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _continue() {
    final draft = EventDraft(
      name: _nameController.text.trim().isEmpty
          ? 'Evento ${DateFormat('dd/MM').format(_date)}'
          : _nameController.text.trim(),
      date: _date,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventPeopleSelectScreen(draft: draft)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo evento')),
      body: SafeArea(
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nombre del evento',
                hintText: 'Ej: Cena Araguaney',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha'),
              subtitle: Text(DateFormat('dd/MM/yyyy', 'es_CL').format(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _continue,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Continuar: elegir personas'),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
