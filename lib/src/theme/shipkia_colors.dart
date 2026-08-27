import 'package:flutter/material.dart';

class ShipKiaColors {
  const ShipKiaColors._();

  static const shipkiaBlue = Color(0xFF1351D8);
  static const sky = Color(0xFF2F80ED);
  static const teal = Color(0xFF0E9F8F);
  static const ink = Color(0xFF0F0F0F);
  static const paper = Color(0xFFFFFFFF);
  static const neutralMuted = Color(0xFFF6F8FB);
  static const neutralBorder = Color(0xFFDDE3EA);
  static const mutedInk = Color(0xFF667085);
  static const night = Color(0xFF101418);
  static const nightCard = Color(0xFF171C22);
  static const nightMuted = Color(0xFF20262E);
  static const nightBorder = Color(0xFF303844);
  static const success = Color(0xFF307E4C);
  static const warning = Color(0xFFA66617);
  static const error = Color(0xFFB03B3B);
  static const destructive = error;
  static const info = Color(0xFF2563EB);

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? nightCard : paper;

  static Color surfaceMuted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? nightMuted
      : neutralMuted;

  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? nightBorder
      : neutralBorder;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? paper : ink;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFB8C0CC)
      : mutedInk;
}
