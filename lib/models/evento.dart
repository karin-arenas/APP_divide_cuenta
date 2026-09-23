/// Un evento (una "cuenta" a dividir): junta, salida, cena, etc.
class Evento {
  final String id;
  final String name;
  final String date; // ISO8601
  final double tipPercent; // porcentaje de propina por defecto (ej: 10.0)
  final bool tipEnabled; // si la propina está activa globalmente
  final String createdAt;

  Evento({
    required this.id,
    required this.name,
    required this.date,
    this.tipPercent = 10.0,
    this.tipEnabled = true,
    required this.createdAt,
  });

  Evento copyWith({
    String? name,
    String? date,
    double? tipPercent,
    bool? tipEnabled,
  }) =>
      Evento(
        id: id,
        name: name ?? this.name,
        date: date ?? this.date,
        tipPercent: tipPercent ?? this.tipPercent,
        tipEnabled: tipEnabled ?? this.tipEnabled,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'date': date,
        'tip_percent': tipPercent,
        'tip_enabled': tipEnabled ? 1 : 0,
        'created_at': createdAt,
      };

  factory Evento.fromMap(Map<String, dynamic> map) => Evento(
        id: map['id'] as String,
        name: map['name'] as String,
        date: map['date'] as String,
        tipPercent: (map['tip_percent'] as num).toDouble(),
        tipEnabled: (map['tip_enabled'] as int) == 1,
        createdAt: map['created_at'] as String,
      );
}

/// Anulación de propina para una persona específica dentro de un evento.
/// Si no existe una fila para una persona, se usa el [Evento.tipPercent] global.
class TipOverride {
  final String eventId;
  final String personId;
  final String type; // 'percent' | 'flat' | 'none'
  final double value; // porcentaje (0-100) o monto plano en pesos; ignorado si type == 'none'

  TipOverride({
    required this.eventId,
    required this.personId,
    required this.type,
    required this.value,
  });

  Map<String, dynamic> toMap() => {
        'event_id': eventId,
        'person_id': personId,
        'type': type,
        'value': value,
      };

  factory TipOverride.fromMap(Map<String, dynamic> map) => TipOverride(
        eventId: map['event_id'] as String,
        personId: map['person_id'] as String,
        type: map['type'] as String,
        value: (map['value'] as num).toDouble(),
      );
}
