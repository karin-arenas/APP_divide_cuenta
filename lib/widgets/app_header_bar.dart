import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';

/// Encabezado de marca reutilizado en las pantallas principales: logo +
/// "Divide_Cuenta" + subtítulo de la sección, como en el header de los
/// mockups (`design_reference/screens/*.html`).
class AppHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String subtitle;
  final List<Widget>? actions;

  const AppHeaderBar({super.key, required this.subtitle, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 16,
      title: Row(
        children: [
          SvgPicture.asset('assets/logo.svg', height: 32, width: 32),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Divide_Cuenta',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                subtitle.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
              ),
            ],
          ),
        ],
      ),
      actions: actions,
    );
  }
}
