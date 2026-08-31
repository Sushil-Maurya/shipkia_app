import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/app_route.dart';
import '../../design_system/shipkia_tokens.dart';
import 'app_routes.dart';

CustomTransitionPage<T> shipKiaPage<T>({
  required GoRouterState state,
  required Widget child,
  AppRouteTransitionType transition = AppRouteTransitionType.slide,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: ShipKiaMotion.normal,
    reverseTransitionDuration: ShipKiaMotion.fast,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (transition == AppRouteTransitionType.none ||
          ShipKiaMotion.reduceMotion(context)) {
        return child;
      }

      return shipKiaRouteTransitionBuilder(
        _toDesignSystemTransition(transition),
        animation,
        secondaryAnimation,
        child,
      );
    },
  );
}

ShipKiaRouteTransition _toDesignSystemTransition(
  AppRouteTransitionType transition,
) {
  return switch (transition) {
    AppRouteTransitionType.fade => ShipKiaRouteTransition.fade,
    AppRouteTransitionType.modal => ShipKiaRouteTransition.modal,
    AppRouteTransitionType.none ||
    AppRouteTransitionType.slide => ShipKiaRouteTransition.sharedAxis,
  };
}
