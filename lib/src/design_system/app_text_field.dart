import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.prefix,
    this.suffix,
    this.keyboardType,
    this.obscureText = false,
    this.autofillHints,
    this.textAlign = TextAlign.start,
    this.maxLength,
    this.maxLines = 1,
    this.readOnly = false,
    this.enabled = true,
    this.showReadOnlyBadge = true,
    this.helperText,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.inputFormatters,
    this.height = 40,
    super.key,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final TextAlign textAlign;
  final int? maxLength;
  final int? maxLines;
  final bool readOnly;
  final bool enabled;
  final bool showReadOnlyBadge;
  final String? helperText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
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
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              placeholder: widget.hintText,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText,
              autofillHints: widget.autofillHints,
              textAlign: widget.textAlign,
              maxLength: widget.maxLength,
              maxLines: widget.maxLines,
              readOnly: widget.readOnly,
              enabled: widget.enabled,
              onChanged: widget.readOnly ? null : widget.onChanged,
              onSubmitted: widget.onSubmitted,
              textInputAction: widget.textInputAction,
              inputFormatters: widget.inputFormatters,
              prefix:
                  widget.prefix ??
                  (widget.prefixIcon == null
                      ? null
                      : Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Icon(
                            widget.prefixIcon,
                            size: 18,
                            color: ShipKiaColors.mutedInk,
                          ),
                        )),
              suffix: widget.suffix == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: widget.suffix,
                    ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: widget.enabled && !widget.readOnly
                    ? Theme.of(context).colorScheme.surface
                    : widget.enabled
                    ? ShipKiaColors.surfaceMuted(context)
                    : _disabledFill(context),
                borderRadius: ShipKiaRadius.mdBorder,
                border: Border.all(color: _borderColor(context)),
              ),
            )
          : TextField(
              controller: controller,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText,
              autofillHints: widget.autofillHints,
              textAlign: widget.textAlign,
              maxLength: widget.maxLength,
              maxLines: widget.maxLines,
              readOnly: widget.readOnly,
              enabled: widget.enabled,
              onChanged: widget.readOnly ? null : widget.onChanged,
              onSubmitted: widget.onSubmitted,
              textInputAction: widget.textInputAction,
              inputFormatters: widget.inputFormatters,
              decoration: InputDecoration(
                hintText: widget.hintText,
                errorText: widget.errorText,
                helperText: widget.helperText,
                counterText: '',
                filled: !widget.enabled || widget.readOnly,
                fillColor: widget.enabled
                    ? ShipKiaColors.surfaceMuted(context)
                    : _disabledFill(context),
                prefixIcon:
                    widget.prefix ??
                    (widget.prefixIcon == null
                        ? null
                        : Icon(widget.prefixIcon, size: 18)),
                suffixIcon: widget.suffix,
              ),
            ),
    );

    if (widget.label == null && AppPlatform.isCupertino) {
      return _withCupertinoSupportText(context, field);
    }
    if (widget.label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.label!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 11,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _withCupertinoSupportText(context, field),
      ],
    );
  }

  Widget _withCupertinoSupportText(BuildContext context, Widget field) {
    if (!AppPlatform.isCupertino) return field;
    final supportText = widget.errorText ?? widget.helperText;
    if (supportText == null || supportText.trim().isEmpty) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        field,
        const SizedBox(height: 5),
        Text(
          supportText,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: widget.errorText == null
                ? ShipKiaColors.textSecondary(context)
                : ShipKiaColors.error,
          ),
        ),
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
