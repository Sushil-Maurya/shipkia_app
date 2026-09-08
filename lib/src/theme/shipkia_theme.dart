import 'package:flutter/material.dart';

import '../design_system/shipkia_tokens.dart';
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
      fontFamily: ShipKiaTypography.fontFamily,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      textTheme: ShipKiaTypography.textTheme(text),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surface,
        foregroundColor: text,
        titleTextStyle: TextStyle(
          fontFamily: ShipKiaTypography.fontFamily,
          color: text,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: isDark ? ShipKiaColors.nightCard : ShipKiaColors.paper,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ShipKiaSpacing.md,
          vertical: ShipKiaSpacing.sm,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 34,
          minHeight: 28,
        ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 34,
          minHeight: 28,
        ),
        border: OutlineInputBorder(
          borderRadius: ShipKiaRadius.mdBorder,
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: ShipKiaRadius.mdBorder,
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: ShipKiaRadius.mdBorder,
          borderSide: const BorderSide(color: ShipKiaColors.shipkiaBlue),
        ),
      ),
      chipTheme: const ChipThemeData(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        labelPadding: EdgeInsets.symmetric(horizontal: 4),
        labelStyle: TextStyle(fontSize: 12, height: 1.2),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: ShipKiaRadius.mdBorder),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: ShipKiaRadius.mdBorder),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? ShipKiaColors.nightCard : ShipKiaColors.paper,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: ShipKiaRadius.lgBorder,
          side: BorderSide(color: border),
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? ShipKiaColors.nightCard : ShipKiaColors.paper,
        modalBackgroundColor: isDark
            ? ShipKiaColors.nightCard
            : ShipKiaColors.paper,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(ShipKiaRadius.lg),
          ),
          side: BorderSide(color: border),
        ),
        showDragHandle: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? ShipKiaColors.nightCard : ShipKiaColors.paper,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: ShipKiaRadius.lgBorder),
      ),
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
