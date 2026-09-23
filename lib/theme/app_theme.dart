import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema visual de la app, basado en el sistema de diseño "Precision Ledger"
/// (ver `design_reference/design_system.md` y `design_reference/screens/*.html`):
/// un tema oscuro financiero de alto contraste, con azul/cian hielo como
/// acento, tipografía Space Grotesk (titulares) + Hanken Grotesk (cuerpo) +
/// JetBrains Mono (cifras monetarias), y esquinas redondeadas suaves.
class AppTheme {
  AppTheme._();

  // Paleta exacta de design_reference/design_system.md
  static const surface = Color(0xFF0F131C);
  static const surfaceDim = Color(0xFF0F131C);
  static const surfaceBright = Color(0xFF353943);
  static const surfaceContainerLowest = Color(0xFF0A0E17);
  static const surfaceContainerLow = Color(0xFF181B25);
  static const surfaceContainer = Color(0xFF1C1F29);
  static const surfaceContainerHigh = Color(0xFF262A34);
  static const surfaceContainerHighest = Color(0xFF31353F);
  static const onSurface = Color(0xFFDFE2EF);
  static const onSurfaceVariant = Color(0xFFBEC8CE);
  static const inverseSurface = Color(0xFFDFE2EF);
  static const inverseOnSurface = Color(0xFF2C303A);
  static const outline = Color(0xFF899298);
  static const outlineVariant = Color(0xFF3F484E);
  static const surfaceTint = Color(0xFF7BD1FA);
  static const primary = Color(0xFFC5EAFF);
  static const onPrimary = Color(0xFF003547);
  static const primaryContainer = Color(0xFF7DD3FC);
  static const onPrimaryContainer = Color(0xFF005B78);
  static const inversePrimary = Color(0xFF006686);
  static const secondary = Color(0xFF4CD7F6);
  static const onSecondary = Color(0xFF003640);
  static const secondaryContainer = Color(0xFF03B5D3);
  static const onSecondaryContainer = Color(0xFF00424E);
  static const tertiary = Color(0xFFCDE8FF);
  static const onTertiary = Color(0xFF00344D);
  static const tertiaryContainer = Color(0xFF8ED0FF);
  static const onTertiaryContainer = Color(0xFF005981);
  static const error = Color(0xFFFFB4AB);
  static const onError = Color(0xFF690005);
  static const errorContainer = Color(0xFF93000A);
  static const onErrorContainer = Color(0xFFFFDAD6);

  // Colores semánticos usados en tarjetas de resumen (éxito/advertencia).
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);

  static const radiusSm = 4.0;
  static const radiusMd = 8.0;
  static const radiusLg = 16.0;
  static const radiusXl = 24.0;

  /// Estilo monoespaciado (JetBrains Mono) para toda cifra monetaria,
  /// porcentaje o timestamp, según el sistema de diseño.
  static TextStyle moneyStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static ThemeData dark() {
    final colorScheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
      surfaceTint: surfaceTint,
      scrim: Colors.black,
      shadow: Colors.black,
    );

    final baseTextTheme = TextTheme(
      displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 40, fontWeight: FontWeight.w700, height: 48 / 40),
      headlineLarge: GoogleFonts.spaceGrotesk(
          fontSize: 28, fontWeight: FontWeight.w600, height: 34 / 28),
      headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 22, fontWeight: FontWeight.w600, height: 28 / 22),
      headlineSmall: GoogleFonts.spaceGrotesk(
          fontSize: 18, fontWeight: FontWeight.w600, height: 24 / 18),
      titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 18, fontWeight: FontWeight.w600, height: 24 / 18),
      titleMedium: GoogleFonts.hankenGrotesk(
          fontSize: 16, fontWeight: FontWeight.w600, height: 22 / 16),
      titleSmall: GoogleFonts.hankenGrotesk(
          fontSize: 14, fontWeight: FontWeight.w600, height: 18 / 14),
      bodyLarge: GoogleFonts.hankenGrotesk(
          fontSize: 16, fontWeight: FontWeight.w400, height: 24 / 16),
      bodyMedium: GoogleFonts.hankenGrotesk(
          fontSize: 14, fontWeight: FontWeight.w400, height: 20 / 14),
      bodySmall: GoogleFonts.hankenGrotesk(
          fontSize: 12, fontWeight: FontWeight.w400, height: 16 / 12),
      labelLarge: GoogleFonts.jetBrainsMono(
          fontSize: 14, fontWeight: FontWeight.w500, height: 18 / 14),
      labelMedium: GoogleFonts.jetBrainsMono(
          fontSize: 12, fontWeight: FontWeight.w500, height: 16 / 12),
      labelSmall: GoogleFonts.jetBrainsMono(
          fontSize: 10, fontWeight: FontWeight.w600, height: 14 / 10),
    ).apply(
      bodyColor: onSurface,
      displayColor: onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      canvasColor: surface,
      textTheme: baseTextTheme,
      fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: surface.withOpacity(0.92),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: onSurface,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        iconTheme: const IconThemeData(color: onSurface),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: outlineVariant.withOpacity(0.4)),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: onSurfaceVariant,
        textColor: onSurface,
      ),
      dividerTheme: DividerThemeData(
        color: outlineVariant.withOpacity(0.5),
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLow,
        hintStyle: GoogleFonts.hankenGrotesk(color: onSurfaceVariant),
        labelStyle: GoogleFonts.hankenGrotesk(color: onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: secondary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryContainer,
          foregroundColor: const Color(0xFF090D16),
          textStyle: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          side: BorderSide(color: outlineVariant),
          textStyle: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondary,
          textStyle: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryContainer,
        foregroundColor: Color(0xFF090D16),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainerHigh,
        selectedColor: primaryContainer,
        labelStyle: GoogleFonts.hankenGrotesk(color: onSurface),
        secondaryLabelStyle:
            GoogleFonts.hankenGrotesk(color: const Color(0xFF090D16)),
        side: BorderSide(color: outlineVariant),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        contentTextStyle: GoogleFonts.hankenGrotesk(color: onSurfaceVariant),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(radiusXl)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceContainerHigh,
        contentTextStyle: GoogleFonts.hankenGrotesk(color: onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? primaryContainer : outline),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? secondaryContainer.withOpacity(0.5)
                : surfaceContainerHigh),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? primaryContainer
                : Colors.transparent),
        checkColor: const WidgetStatePropertyAll(Color(0xFF090D16)),
        side: const BorderSide(color: outline),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? primaryContainer : outline),
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: GoogleFonts.jetBrainsMono(
            color: onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: 12),
        dataTextStyle: GoogleFonts.jetBrainsMono(color: onSurface, fontSize: 13),
        dividerThickness: 0.6,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: secondary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceContainerLowest.withOpacity(0.95),
        indicatorColor: primaryContainer.withOpacity(0.22),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? secondary : onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
              color: selected ? secondary : onSurfaceVariant, size: 24);
        }),
      ),
      colorSchemeSeed: null,
    );
  }
}
