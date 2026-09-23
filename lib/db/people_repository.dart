import 'package:uuid/uuid.dart';

import '../models/person.dart';
import 'db_helper.dart';

/// Repositorio de personas (libreta de contactos persistente y reutilizable
/// entre eventos).
class PeopleRepository {
  final _uuid = const Uuid();

  Future<List<Person>> getAll() async {
    final db = await DbHelper.instance.database;
    final rows = await db.query('people', orderBy: 'name COLLATE NOCASE ASC');
    return rows.map(Person.fromMap).toList();
  }

  Future<Person> add(String name) async {
    final db = await DbHelper.instance.database;
    final person = Person(
      id: _uuid.v4(),
      name: name.trim(),
      createdAt: DateTime.now().toIso8601String(),
    );
    await db.insert('people', person.toMap());
    return person;
  }

  Future<void> rename(String id, String newName) async {
    final db = await DbHelper.instance.database;
    await db.update('people', {'name': newName.trim()},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> delete(String id) async {
    final db = await DbHelper.instance.database;
    await db.delete('people', where: 'id = ?', whereArgs: [id]);
  }

  /// Busca por nombre exacto (case-insensitive), o crea una nueva persona.
  Future<Person> findOrCreateByName(String name) async {
    final trimmed = name.trim();
    final all = await getAll();
    for (final p in all) {
      if (p.name.toLowerCase() == trimmed.toLowerCase()) return p;
    }
    return add(trimmed);
  }
}
