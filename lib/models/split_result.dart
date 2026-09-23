import 'evento.dart';
import 'person.dart';
import 'receipt_item.dart';

/// Utilidades de reparto con redondeo exacto (sin perder ni ganar pesos).
///
/// Estrategia: se calcula el reparto "ideal" (con decimales), se trunca cada
/// parte hacia abajo, y el resto (la diferencia entre el total real y la
/// suma de las partes truncadas) se reparte de a 1 peso entre las primeras
/// N personas de la lista (orden determinístico: el orden en que fueron
/// pasadas las personas, típicamente el orden en que están en el evento).
class RoundedSplit {
  /// Reparte [totalPesos] (entero, sin decimales) entre las personas cuyo id
  /// está en [personIds] (orden importa para el reparto del resto),
  /// devolviendo un mapa personId -> monto entero en pesos.
  /// La suma de los valores del mapa siempre es exactamente [totalPesos].
  static Map<String, int> distribute(int totalPesos, List<String> personIds) {
    if (personIds.isEmpty) return {};
    final n = personIds.length;
    final base = totalPesos ~/ n;
    final resto = totalPesos - base * n; // 0 <= resto < n (si totalPesos>=0)
    final result = <String, int>{};
    for (var i = 0; i < n; i++) {
      result[personIds[i]] = base + (i < resto ? 1 : 0);
    }
    return result;
  }
}

/// Fila calculada para la tabla de resultados: un ítem y el reparto por
/// persona.
class ItemRow {
  final ReceiptItem item;
  final Map<String, int> shares; // personId -> monto

  ItemRow({required this.item, required this.shares});
}

/// Resultado completo calculado para un evento: filas de ítems, consumo por
/// persona, propina por persona y total final por persona.
class EventBreakdown {
  final List<ItemRow> rows;
  final Map<String, int> consumoPorPersona; // subtotal (sin propina)
  final Map<String, int> propinaPorPersona;
  final Map<String, int> totalPorPersona; // consumo + propina
  final int consumoTotal;
  final int propinaTotal;
  final int totalFinal;

  EventBreakdown({
    required this.rows,
    required this.consumoPorPersona,
    required this.propinaPorPersona,
    required this.totalPorPersona,
    required this.consumoTotal,
    required this.propinaTotal,
    required this.totalFinal,
  });

  /// Calcula todo el desglose a partir de los ítems, las personas
  /// participantes (en orden) y la configuración de propina del evento.
  factory EventBreakdown.calculate({
    required List<ReceiptItem> items,
    required List<Person> participants,
    required Evento evento,
    required List<TipOverride> tipOverrides,
  }) {
    final personIds = participants.map((p) => p.id).toList();

    final rows = <ItemRow>[];
    final consumo = <String, int>{for (final id in personIds) id: 0};

    for (final item in items) {
      final sharers = item.sharedByPersonIds
          .where((id) => personIds.contains(id))
          .toList();
      // Mantener el orden de participantes para el reparto del resto.
      sharers.sort((a, b) => personIds.indexOf(a).compareTo(personIds.indexOf(b)));
      final shares = RoundedSplit.distribute(item.totalPrice, sharers);
      for (final entry in shares.entries) {
        consumo[entry.key] = (consumo[entry.key] ?? 0) + entry.value;
      }
      rows.add(ItemRow(item: item, shares: shares));
    }

    final consumoTotal = consumo.values.fold<int>(0, (a, b) => a + b);

    // Propina: por defecto evento.tipPercent aplicado al consumo de cada
    // persona, salvo que haya un override para esa persona (flat/none/otro %).
    final propina = <String, int>{for (final id in personIds) id: 0};
    if (evento.tipEnabled) {
      final overrideMap = {for (final o in tipOverrides) o.personId: o};
      final defaultGroupIds = <String>[];
      double defaultGroupIdealSum = 0;

      for (final id in personIds) {
        final override = overrideMap[id];
        final personConsumo = consumo[id] ?? 0;
        if (override != null) {
          if (override.type == 'none') {
            propina[id] = 0;
          } else if (override.type == 'flat') {
            propina[id] = override.value.round();
          } else {
            // percent individual: se redondea de forma independiente, ya
            // que el usuario definió explícitamente un % distinto al grupo.
            propina[id] = (personConsumo * override.value / 100).round();
          }
        } else {
          // Sin override: usa el % global del evento. Este grupo se
          // reconcilia para que la suma coincida exactamente con el
          // redondeo del total del grupo (método del mayor resto).
          defaultGroupIds.add(id);
          defaultGroupIdealSum += personConsumo * evento.tipPercent / 100;
        }
      }

      if (defaultGroupIds.isNotEmpty) {
        final groupTarget = defaultGroupIdealSum.round();
        final ideal = <String, double>{
          for (final id in defaultGroupIds)
            id: (consumo[id] ?? 0) * evento.tipPercent / 100
        };
        final floors = <String, int>{
          for (final id in defaultGroupIds) id: ideal[id]!.floor()
        };
        var assigned = floors.values.fold<int>(0, (a, b) => a + b);
        var remainder = groupTarget - assigned;
        // Ordena por la parte decimal descendente para asignar el resto
        // de forma determinística (mayor resto primero).
        final sortedByFrac = List<String>.from(defaultGroupIds)
          ..sort((a, b) {
            final fa = ideal[a]! - floors[a]!;
            final fb = ideal[b]! - floors[b]!;
            return fb.compareTo(fa);
          });
        final result = Map<String, int>.from(floors);
        var idx = 0;
        while (remainder > 0 && sortedByFrac.isNotEmpty) {
          final id = sortedByFrac[idx % sortedByFrac.length];
          result[id] = (result[id] ?? 0) + 1;
          remainder--;
          idx++;
        }
        while (remainder < 0 && sortedByFrac.isNotEmpty) {
          final id = sortedByFrac[idx % sortedByFrac.length];
          if ((result[id] ?? 0) > 0) {
            result[id] = (result[id] ?? 0) - 1;
            remainder++;
          }
          idx++;
        }
        for (final id in defaultGroupIds) {
          propina[id] = result[id] ?? 0;
        }
      }
    }

    final propinaTotal = propina.values.fold<int>(0, (a, b) => a + b);

    final total = <String, int>{
      for (final id in personIds) id: (consumo[id] ?? 0) + (propina[id] ?? 0)
    };
    final totalFinal = total.values.fold<int>(0, (a, b) => a + b);

    return EventBreakdown(
      rows: rows,
      consumoPorPersona: consumo,
      propinaPorPersona: propina,
      totalPorPersona: total,
      consumoTotal: consumoTotal,
      propinaTotal: propinaTotal,
      totalFinal: totalFinal,
    );
  }
}

extension FirstOrNullExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
