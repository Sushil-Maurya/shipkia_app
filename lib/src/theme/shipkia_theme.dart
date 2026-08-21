import 'package:flutter/material.dart';

import 'shipkia_colors.dart';

class ShipKiaTheme {
  const ShipKiaTheme._();

  static ThemeData get light => _base(
    colorScheme: ColorScheme.fromSeed(
      seedColor: ShipKiaColors.shipkiaBlue,
      primary: ShipKiaColors.shipkiaBlue,
      surface: ShipKiaColors.paper,
    ),
    brightness: Brightness.light,
  );

  static ThemeData get dark => _base(
    colorScheme: ColorScheme.fromSeed(
      seedColor: ShipKiaColors.shipkiaBlue,
      brightness: Brightness.dark,
      primary: ShipKiaColors.shipkiaBlue,
      surface: ShipKiaColors.night,
    ),
    brightness: Brightness.dark,
  );

  static ThemeData _base({
    required ColorScheme colorScheme,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;
    final surface = isDark ? ShipKiaColors.night : ShipKiaColors.paper;
    final text = isDark ? ShipKiaColors.paper : ShipKiaColors.ink;
    final border = isDark
        ? ShipKiaColors.nightBorder
        : ShipKiaColors.neutralBorder;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      fontFamily: 'Manrope',
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          color: text,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          color: text,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(color: text, fontSize: 12, height: 1.35),
        labelSmall: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surface,
        foregroundColor: text,
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: isDark ? ShipKiaColors.nightCard : ShipKiaColors.paper,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 34,
          minHeight: 28,
        ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 34,
          minHeight: 28,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ShipKiaColors.shipkiaBlue),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 28),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 28),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? ShipKiaColors.nightCard : ShipKiaColors.paper,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: border),
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      navigationBarTheme: NavigationBarThemeData(
        height: 58,
        backgroundColor: surface,
        indicatorColor: ShipKiaColors.shipkiaBlue,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? ShipKiaColors.shipkiaBlue
                : ShipKiaColors.mutedInk,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? ShipKiaColors.paper
                : ShipKiaColors.mutedInk,
            size: 20,
          ),
        ),
      ),
    );
  }
}
