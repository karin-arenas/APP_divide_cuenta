import 'package:flutter/material.dart';

import '../screens/event_new_screen.dart';
import '../screens/home_historial.dart';
import '../screens/home_inicio_screen.dart';
import '../screens/people_manager_screen.dart';
import '../screens/settings_screen.dart';

/// Barra de navegación inferior persistente entre las pantallas principales
/// (Inicio / Nuevo / Historial / Contactos / Ajustes), como en los mockups
/// de `design_reference/screens/*.html`. Cada pantalla de nivel superior
/// incluye esta barra y usa `pushReplacement` al cambiar de pestaña, para
/// no apilar pantallas infinitamente.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, required this.currentIndex});

  void _go(BuildContext context, int index) {
    if (index == currentIndex) return;
    final Widget screen;
    switch (index) {
      case 0:
        screen = const HomeInicioScreen();
        break;
      case 1:
        screen = const EventNewScreen();
        break;
      case 2:
        screen = const HomeHistorialScreen();
        break;
      case 3:
        screen = const PeopleManagerScreen();
        break;
      default:
        screen = const SettingsScreen();
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) => _go(context, i),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Nuevo',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: 'Historial',
        ),
        NavigationDestination(
          icon: Icon(Icons.group_outlined),
          selectedIcon: Icon(Icons.group),
          label: 'Contactos',
        ),
        NavigationDestination(
          icon: Icon(Icons.api_outlined),
          selectedIcon: Icon(Icons.api),
          label: 'API',
        ),
      ],
    );
  }
}
