import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_platform.dart';
import 'shipkia_tokens.dart';

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
}) {
  if (AppPlatform.isCupertino) {
    return showCupertinoModalPopup<T>(
      context: context,
      builder: (context) => SafeArea(
        top: false,
        child: AnimatedPadding(
          duration: ShipKiaMotion.duration(context, ShipKiaMotion.normal),
          curve: ShipKiaMotion.standard,
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: builder(context),
        ),
      ),
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => AnimatedPadding(
      duration: ShipKiaMotion.duration(context, ShipKiaMotion.normal),
      curve: ShipKiaMotion.standard,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: builder(context),
    ),
  );
}
