import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/navigation_service.dart';
import '../../core/router/web_module_catalog.dart';
import '../../design_system/design_system.dart';
import '../../theme/shipkia_colors.dart';
import '../../widgets/shipkia_widgets.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SkSectionHeader(title: 'Modules'),
        AppListTile(
          leading: const Icon(
            Icons.travel_explore,
            color: ShipKiaColors.shipkiaBlue,
          ),
          title: 'Tracking',
          subtitle: 'Public AWB or order lookup',
          trailing: const Icon(Icons.chevron_right, size: 18),
          onTap: () => context.toTracking(),
        ),
        for (final module in WebModuleCatalog.routes)
          _ModuleTile(route: module),
      ],
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({required this.route});

  final WebModuleRoute route;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      leading: Icon(route.icon, color: ShipKiaColors.shipkiaBlue),
      title: route.label,
      subtitle: route.children.isEmpty
          ? route.description
          : '${route.children.length} pages - ${route.description}',
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: () => context.push(route.path),
    );
  }
}
