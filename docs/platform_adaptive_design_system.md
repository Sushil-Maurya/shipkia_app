# Platform-Adaptive Design System

Feature/business UI should use `lib/src/design_system/design_system.dart` for application controls. The design-system layer decides per component whether to use Cupertino, Material, or a shared implementation.

Use `AppButton`, `AppTextField`, `AppSwitch`, `AppCheckbox`, `AppRadio`, `showAppDialog`, `showAppBottomSheet`, `AppNavigationBar`, `AppProgressIndicator`, `AppCard`, `AppListTile`, `AppMenu`, `showAppDatePicker`, and `showAppTimePicker` instead of directly instantiating Material/Cupertino control widgets in feature code.

Documented exceptions in feature code:
- Flutter layout/composition primitives: `Text`, `Icon`, `Row`, `Column`, `Stack`, `Padding`, `Container`, `SizedBox`, `ListView`, `GridView`, `Expanded`, `Flexible`, `SafeArea`, `Navigator`, and route classes.
- Screen-specific custom painting or decorative widgets.
- Custom anchored profile/menu panels that need rich composed content beyond a simple AppMenu item list; internal controls should still use design-system widgets.
- Existing `Theme.of(context)` and `MediaQuery` access for tokens and layout.

If a new component needs a Material or Cupertino primitive, add or extend an `App*` wrapper first and keep the feature-facing API platform-independent.