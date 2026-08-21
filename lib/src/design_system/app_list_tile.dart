import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/shipkia_colors.dart';
import 'app_platform.dart';

class AppListTile extends StatelessWidget {
  const AppListTile({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.dense = true,
    this.destructive = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool dense;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final titleColor = destructive ? ShipKiaColors.destructive : null;
    final titleStyle = Theme.of(context).textTheme.titleMedium
        ?.copyWith(color: titleColor, fontWeight: FontWeight.w700);

    if (AppPlatform.isCupertino) {
      return CupertinoListTile(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        leading: leading,
        title: Text(title, style: titleStyle),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: trailing,
        onTap: onTap,
      );
    }

    return ListTile(
      dense: dense,
      leading: leading,
      title: Text(title, style: titleStyle),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
