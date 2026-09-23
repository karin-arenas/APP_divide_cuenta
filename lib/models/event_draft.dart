import 'package:uuid/uuid.dart';

import 'evento.dart';
import 'person.dart';
import 'receipt_item.dart';

/// Estado mutable en memoria de un evento mientras se está creando o
/// editando, compartido entre las distintas pantallas del flujo (captura
/// OCR -> corrección -> selección de personas -> asignación -> extras ->
/// propina -> resumen). Se guarda a la base de datos sólo al confirmar.
class EventDraft {
  static final _uuid = Uuid();

  String id;
  String name;
  DateTime date;
  double tipPercent;
  bool tipEnabled;
  List<Person> participants;
  List<ReceiptItem> items;
  List<TipOverride> tipOverrides;

  EventDraft({
    String? id,
    this.name = '',
    DateTime? date,
    this.tipPercent = 10.0,
    this.tipEnabled = true,
    List<Person>? participants,
    List<ReceiptItem>? items,
    List<TipOverride>? tipOverrides,
  })  : id = id ?? _uuid.v4(),
        date = date ?? DateTime.now(),
        participants = participants ?? [],
        items = items ?? [],
        tipOverrides = tipOverrides ?? [];

  factory EventDraft.fromEvento(
    Evento evento,
    List<Person> participants,
    List<ReceiptItem> items,
    List<TipOverride> overrides,
  ) {
    return EventDraft(
      id: evento.id,
      name: evento.name,
      date: DateTime.tryParse(evento.date) ?? DateTime.now(),
      tipPercent: evento.tipPercent,
      tipEnabled: evento.tipEnabled,
      participants: List.of(participants),
      items: items.map((i) => i.copyWith()).toList(),
      tipOverrides: List.of(overrides),
    );
  }

  Evento toEvento({String? createdAt}) => Evento(
        id: id,
        name: name.trim().isEmpty ? 'Evento sin nombre' : name.trim(),
        date: date.toIso8601String(),
        tipPercent: tipPercent,
        tipEnabled: tipEnabled,
        createdAt: createdAt ?? DateTime.now().toIso8601String(),
      );

  String newItemId() => _uuid.v4();
}
