import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_platform.dart';

Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  if (!AppPlatform.isCupertino) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }

  var selected = initialDate;
  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (context) => Container(
      height: 280,
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: CupertinoButton(
              child: const Text('Done'),
              onPressed: () => Navigator.of(context).pop(selected),
            ),
          ),
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: initialDate,
              minimumDate: firstDate,
              maximumDate: lastDate,
              onDateTimeChanged: (value) => selected = value,
            ),
          ),
        ],
      ),
    ),
  );
}

Future<TimeOfDay?> showAppTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) async {
  if (!AppPlatform.isCupertino) {
    return showTimePicker(context: context, initialTime: initialTime);
  }

  var selected = DateTime(0, 1, 1, initialTime.hour, initialTime.minute);
  final result = await showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (context) => Container(
      height: 280,
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: CupertinoButton(
              child: const Text('Done'),
              onPressed: () => Navigator.of(context).pop(selected),
            ),
          ),
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: selected,
              onDateTimeChanged: (value) => selected = value,
            ),
          ),
        ],
      ),
    ),
  );

  return result == null
      ? null
      : TimeOfDay(hour: result.hour, minute: result.minute);
}
