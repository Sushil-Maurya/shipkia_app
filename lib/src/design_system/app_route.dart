import 'package:flutter/cupertino.dart';

import 'app_platform.dart';
import 'shipkia_tokens.dart';

enum ShipKiaRouteTransition { sharedAxis, fade, modal }

class ShipKiaPageRoute<T> extends PageRouteBuilder<T> {
  ShipKiaPageRoute({
    required WidgetBuilder builder,
    super.settings,
    ShipKiaRouteTransition transition = ShipKiaRouteTransition.sharedAxis,
    super.fullscreenDialog = false,
  }) : super(
         transitionDuration: ShipKiaMotion.normal,
         reverseTransitionDuration: ShipKiaMotion.fast,
         pageBuilder: (context, animation, secondaryAnimation) =>
             builder(context),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           if (ShipKiaMotion.reduceMotion(context)) return child;
           return shipKiaRouteTransitionBuilder(
             transition,
             animation,
             secondaryAnimation,
             child,
           );
         },
       );

}

Widget shipKiaRouteTransitionBuilder(
  ShipKiaRouteTransition transition,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final curved = CurvedAnimation(
    parent: animation,
    curve: ShipKiaMotion.standard,
    reverseCurve: ShipKiaMotion.exit,
  );

  return switch (transition) {
    ShipKiaRouteTransition.fade => FadeTransition(opacity: curved, child: child),
    ShipKiaRouteTransition.modal => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.05),
        end: Offset.zero,
      ).animate(curved),
      child: FadeTransition(opacity: curved, child: child),
    ),
    ShipKiaRouteTransition.sharedAxis => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.06, 0),
        end: Offset.zero,
      ).animate(curved),
      child: FadeTransition(opacity: curved, child: child),
    ),
  };
}

Route<T> shipKiaRoute<T>({
  required WidgetBuilder builder,
  ShipKiaRouteTransition transition = ShipKiaRouteTransition.sharedAxis,
  bool fullscreenDialog = false,
}) {
  if (AppPlatform.isCupertino) {
    return CupertinoPageRoute<T>(
      builder: builder,
      fullscreenDialog: fullscreenDialog,
    );
  }

  return ShipKiaPageRoute<T>(
    builder: builder,
    transition: transition,
    fullscreenDialog: fullscreenDialog,
  );
}
