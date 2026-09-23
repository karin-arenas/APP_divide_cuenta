import 'package:flutter/material.dart';

import '../models/person.dart';
import '../theme/app_theme.dart';

/// Fila de chips seleccionables para elegir qué personas comparten un ítem
/// (o participan de un evento). Muestra un chip por persona; el
/// seleccionado se resalta.
class PersonChipSelector extends StatelessWidget {
  final List<Person> people;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  const PersonChipSelector({
    super.key,
    required this.people,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: people.map((p) {
        final selected = selectedIds.contains(p.id);
        return FilterChip(
          label: Text(p.name),
          selected: selected,
          onSelected: (_) => onToggle(p.id),
          showCheckmark: false,
          labelStyle: TextStyle(
            color: selected ? const Color(0xFF090D16) : AppTheme.onSurface,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        );
      }).toList(),
    );
  }
}
