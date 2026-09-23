import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/home_inicio_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_CL', null);
  runApp(const DivideCuentaApp());
}

class DivideCuentaApp extends StatelessWidget {
  const DivideCuentaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Divide_Cuenta',
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', 'CL'),
      supportedLocales: const [Locale('es', 'CL'), Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.dark(),
      theme: AppTheme.dark(),
      home: const HomeInicioScreen(),
    );
  }
}
