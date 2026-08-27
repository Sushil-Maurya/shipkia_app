import 'package:flutter/material.dart';

import 'shipkia_tokens.dart';

class AppStaggeredList extends StatelessWidget {
  const AppStaggeredList({
    required this.children,
    this.maxAnimatedChildren = 8,
    this.padding,
    super.key,
  });

  final List<Widget> children;
  final int maxAnimatedChildren;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: children.length,
      itemBuilder: (context, index) {
        final child = children[index];
        if (index >= maxAnimatedChildren ||
            ShipKiaMotion.reduceMotion(context)) {
          return child;
        }

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: ShipKiaMotion.normal + Duration(milliseconds: index * 28),
          curve: ShipKiaMotion.standard,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 10 * (1 - value)),
              child: child,
            ),
          ),
          child: child,
        );
      },
    );
  }
}

class AppAnimatedSwitcher extends StatelessWidget {
  const AppAnimatedSwitcher({
    required this.child,
    this.duration = ShipKiaMotion.normal,
    super.key,
  });

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (ShipKiaMotion.reduceMotion(context)) return child;

    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: ShipKiaMotion.standard,
      switchOutCurve: ShipKiaMotion.exit,
      transitionBuilder: (child, animation) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: ShipKiaMotion.standard,
          reverseCurve: ShipKiaMotion.exit,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.985, end: 1).animate(curved),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
