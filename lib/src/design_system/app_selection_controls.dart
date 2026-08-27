import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/shipkia_colors.dart';
import 'app_platform.dart';
import 'shipkia_tokens.dart';

class AppSwitch extends StatelessWidget {
  const AppSwitch({required this.value, required this.onChanged, super.key});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AppPlatform.isCupertino
        ? CupertinoSwitch(value: value, onChanged: onChanged)
        : Switch(value: value, onChanged: onChanged);
  }
}

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({required this.value, required this.onChanged, super.key});

  final bool value;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    // Shared implementation: Cupertino has no first-class checkbox, and the
    // app uses compact operational check states rather than a platform metaphor.
    return Checkbox(
      value: value,
      onChanged: onChanged,
      visualDensity: VisualDensity.compact,
      activeColor: ShipKiaColors.shipkiaBlue,
    );
  }
}

class AppRadio<T> extends StatelessWidget {
  const AppRadio({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    super.key,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    // Shared implementation: Cupertino has no direct radio equivalent, and
    // Flutter's Material Radio API is moving to RadioGroup. This keeps feature
    // code stable behind the app design-system API.
    final selected = value == groupValue;

    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onChanged == null ? null : () => onChanged!(value),
      child: SizedBox.square(
        dimension: 28,
        child: Center(
          child: AnimatedContainer(
            duration: ShipKiaMotion.duration(context, ShipKiaMotion.fast),
            curve: ShipKiaMotion.standard,
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? ShipKiaColors.shipkiaBlue
                    : ShipKiaColors.border(context),
                width: selected ? 5 : 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
