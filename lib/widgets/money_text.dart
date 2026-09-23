import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';

/// Formatea un entero como moneda chilena: "$11.550" (punto como separador
/// de miles, sin decimales).
String formatMoney(int value) {
  final formatter = NumberFormat.decimalPattern('es_CL');
  return '\$${formatter.format(value)}';
}

/// Texto de un monto en CLP, siempre en tipografía monoespaciada
/// (JetBrains Mono), según el sistema de diseño "Precision Ledger".
class MoneyText extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final TextAlign? textAlign;

  const MoneyText(this.value, {super.key, this.style, this.textAlign});

  @override
  Widget build(BuildContext context) {
    final base = AppTheme.moneyStyle(
      color: Theme.of(context).colorScheme.onSurface,
    );
    return Text(
      formatMoney(value),
      style: base.merge(style),
      textAlign: textAlign,
    );
  }
}
