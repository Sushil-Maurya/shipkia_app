import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/shipkia_colors.dart';
import 'app_platform.dart';
import 'shipkia_tokens.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    this.controller,
    this.initialValue,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.obscureText = false,
    this.autofillHints,
    this.textAlign = TextAlign.start,
    this.maxLength,
    this.maxLines = 1,
    this.readOnly = false,
    this.enabled = true,
    this.height = 40,
    super.key,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final TextAlign textAlign;
  final int? maxLength;
  final int? maxLines;
  final bool readOnly;
  final bool enabled;
  final double height;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  TextEditingController? _controller;

  TextEditingController? get _effectiveController {
    if (widget.controller != null) return widget.controller;
    if (widget.initialValue == null) return null;
    return _controller ??= TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null) return;
    if (oldWidget.initialValue == widget.initialValue) return;

    final nextValue = widget.initialValue ?? '';
    final controller = _controller;
    if (controller == null) {
      if (widget.initialValue != null) {
        _controller = TextEditingController(text: nextValue);
      }
      return;
    }

    if (controller.text != nextValue) {
      controller.text = nextValue;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _effectiveController;
    final field = SizedBox(
      height: widget.height,
      child: AppPlatform.isCupertino
          ? CupertinoTextField(
              controller: controller,
              placeholder: widget.hintText,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText,
              autofillHints: widget.autofillHints,
              textAlign: widget.textAlign,
              maxLength: widget.maxLength,
              maxLines: widget.maxLines,
              readOnly: widget.readOnly,
              enabled: widget.enabled,
              prefix: widget.prefixIcon == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Icon(
                        widget.prefixIcon,
                        size: 18,
                        color: ShipKiaColors.mutedInk,
                      ),
                    ),
              suffix: widget.suffix == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: widget.suffix,
                    ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: widget.enabled
                    ? Theme.of(context).colorScheme.surface
                    : _disabledFill(context),
                borderRadius: ShipKiaRadius.mdBorder,
                border: Border.all(color: _borderColor(context)),
              ),
            )
          : TextField(
              controller: controller,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText,
              autofillHints: widget.autofillHints,
              textAlign: widget.textAlign,
              maxLength: widget.maxLength,
              maxLines: widget.maxLines,
              readOnly: widget.readOnly,
              enabled: widget.enabled,
              decoration: InputDecoration(
                hintText: widget.hintText,
                counterText: '',
                filled: !widget.enabled,
                fillColor: _disabledFill(context),
                prefixIcon: widget.prefixIcon == null
                    ? null
                    : Icon(widget.prefixIcon, size: 18),
                suffixIcon: widget.suffix,
              ),
            ),
    );

    if (widget.label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label!,
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

  Color _disabledFill(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? ShipKiaColors.nightCard
        : ShipKiaColors.neutralMuted;
  }
}
