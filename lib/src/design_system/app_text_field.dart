import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/shipkia_colors.dart';
import 'app_platform.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.obscureText = false,
    this.autofillHints,
    this.textAlign = TextAlign.start,
    this.maxLength,
    this.height = 40,
    super.key,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final TextAlign textAlign;
  final int? maxLength;
  final double height;

  @override
  Widget build(BuildContext context) {
    final field = SizedBox(
      height: height,
      child: AppPlatform.isCupertino
          ? CupertinoTextField(
              controller: controller,
              placeholder: hintText,
              keyboardType: keyboardType,
              obscureText: obscureText,
              autofillHints: autofillHints,
              textAlign: textAlign,
              maxLength: maxLength,
              prefix: prefixIcon == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Icon(
                        prefixIcon,
                        size: 18,
                        color: ShipKiaColors.mutedInk,
                      ),
                    ),
              suffix: suffix == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: suffix,
                    ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _borderColor(context)),
              ),
            )
          : TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              autofillHints: autofillHints,
              textAlign: textAlign,
              maxLength: maxLength,
              decoration: InputDecoration(
                hintText: hintText,
                counterText: '',
                prefixIcon: prefixIcon == null
                    ? null
                    : Icon(prefixIcon, size: 18),
                suffixIcon: suffix,
              ),
            ),
    );

    if (label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 11,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }

  Color _borderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? ShipKiaColors.nightBorder
        : ShipKiaColors.neutralBorder;
  }
}
