import 'package:flutter/material.dart';

class ShipKiaSpacing {
  const ShipKiaSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double page = 16;
}

class ShipKiaRadius {
  const ShipKiaRadius._();

  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double pill = 999;

  static BorderRadius get smBorder => BorderRadius.circular(sm);
  static BorderRadius get mdBorder => BorderRadius.circular(md);
  static BorderRadius get lgBorder => BorderRadius.circular(lg);
  static BorderRadius get pillBorder => BorderRadius.circular(pill);
}

class ShipKiaElevation {
  const ShipKiaElevation._();

  static const List<BoxShadow> none = [];
  static const List<BoxShadow> raised = [
    BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, 8)),
  ];
  static const List<BoxShadow> overlay = [
    BoxShadow(color: Color(0x26000000), blurRadius: 48, offset: Offset(0, 18)),
  ];
}

class ShipKiaMotion {
  const ShipKiaMotion._();

  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration normal = Duration(milliseconds: 240);
  static const Duration emphasized = Duration(milliseconds: 360);
  static const Duration startup = Duration(milliseconds: 520);
  static const Duration refresh = Duration(milliseconds: 450);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasizedCurve = Curves.easeInOutCubicEmphasized;
  static const Curve exit = Curves.easeInCubic;

  static bool reduceMotion(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  static Duration duration(BuildContext context, Duration value) =>
      reduceMotion(context) ? instant : value;
}

class ShipKiaBreakpoints {
  const ShipKiaBreakpoints._();

  static const double compact = 0;
  static const double medium = 600;
  static const double expanded = 900;

  static bool isCompact(double width) => width < medium;
  static bool isMedium(double width) => width >= medium && width < expanded;
  static bool isExpanded(double width) => width >= expanded;

  static int dashboardColumns(double width) {
    if (width >= expanded) return 4;
    if (width >= medium) return 3;
    return 2;
  }
}

class ShipKiaTypography {
  const ShipKiaTypography._();

  static const String fontFamily = 'Manrope';

  static TextTheme textTheme(Color text) => TextTheme(
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
    bodySmall: TextStyle(color: text, fontSize: 11, height: 1.35),
    labelSmall: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w800,
      letterSpacing: 0,
    ),
  );
}
