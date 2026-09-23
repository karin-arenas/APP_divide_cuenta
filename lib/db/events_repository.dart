import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/evento.dart';
import '../models/person.dart';
import '../models/receipt_item.dart';
import 'db_helper.dart';

/// Snapshot completo de un evento: cabecera, participantes, ítems (con sus
/// personas asignadas) y overrides de propina. Se usa para cargar/guardar
/// un evento completo de una vez (crear, editar, reabrir).
class EventFullData {
  final Evento evento;
  final List<Person> participants;
  final List<ReceiptItem> items;
  final List<TipOverride> tipOverrides;

  EventFullData({
    required this.evento,
    required this.participants,
    required this.items,
    required this.tipOverrides,
  });
}

class EventsRepository {
  final _uuid = const Uuid();

  Future<List<Evento>> getAll() async {
    final db = await DbHelper.instance.database;
    final rows = await db.query('events', orderBy: 'date DESC, created_at DESC');
    return rows.map(Evento.fromMap).toList();
  }

  Future<EventFullData?> getFullEvent(String eventId) async {
    final db = await DbHelper.instance.database;
    final eventRows = await db.query('events', where: 'id = ?', whereArgs: [eventId]);
    if (eventRows.isEmpty) return null;
    final evento = Evento.fromMap(eventRows.first);

    final participantRows = await db.rawQuery('''
      SELECT p.* FROM people p
      INNER JOIN event_participants ep ON ep.person_id = p.id
      WHERE ep.event_id = ?
      ORDER BY ep.sort_order ASC
    ''', [eventId]);
    final participants = participantRows.map(Person.fromMap).toList();

    final itemRows = await db.query('items',
        where: 'event_id = ?', whereArgs: [eventId], orderBy: 'sort_order ASC');
    final items = <ReceiptItem>[];
    for (final row in itemRows) {
      var item = ReceiptItem.fromMap(row);
      final shareRows = await db.query('item_shares',
          where: 'item_id = ?', whereArgs: [item.id]);
      final personIds = shareRows.map((r) => r['person_id'] as String).toList();
      item = item.copyWith(sharedByPersonIds: personIds);
      items.add(item);
    }

    final overrideRows =
        await db.query('tip_overrides', where: 'event_id = ?', whereArgs: [eventId]);
    final overrides = overrideRows.map(TipOverride.fromMap).toList();

    return EventFullData(
      evento: evento,
      participants: participants,
      items: items,
      tipOverrides: overrides,
    );
  }

  String newEventId() => _uuid.v4();
  String newItemId() => _uuid.v4();

  /// Guarda (crea o reemplaza) un evento completo de forma transaccional.
  Future<void> saveFullEvent(EventFullData data) async {
    final db = await DbHelper.instance.database;
    await db.transaction((txn) async {
      await txn.insert('events', data.evento.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);

      await txn.delete('event_participants',
          where: 'event_id = ?', whereArgs: [data.evento.id]);
      for (var i = 0; i < data.participants.length; i++) {
        await txn.insert('event_participants', {
          'event_id': data.evento.id,
          'person_id': data.participants[i].id,
          'sort_order': i,
        });
      }

      // Borra ítems anteriores (y sus shares, por cascade) y vuelve a
      // insertar todo desde cero: más simple y seguro para un flujo de
      // edición completa.
      await txn.delete('items', where: 'event_id = ?', whereArgs: [data.evento.id]);
      for (var i = 0; i < data.items.length; i++) {
        final item = data.items[i].copyWith(sortOrder: i);
        await txn.insert('items', item.toMap());
        for (final personId in item.sharedByPersonIds) {
          await txn.insert('item_shares', {
            'item_id': item.id,
            'person_id': personId,
          });
        }
      }

      await txn.delete('tip_overrides',
          where: 'event_id = ?', whereArgs: [data.evento.id]);
      for (final override in data.tipOverrides) {
        await txn.insert('tip_overrides', override.toMap());
      }
    });
  }

  Future<void> deleteEvent(String eventId) async {
    final db = await DbHelper.instance.database;
    await db.delete('events', where: 'id = ?', whereArgs: [eventId]);
  }
}
