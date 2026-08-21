import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_platform.dart';

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  if (AppPlatform.isCupertino) {
    return showCupertinoModalPopup<T>(context: context, builder: builder);
  }

  return showModalBottomSheet<T>(context: context, builder: builder);
}
