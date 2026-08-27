import 'package:flutter/material.dart';

import '../../data/shipkia_mock_data.dart';
import '../../design_system/design_system.dart';
import '../../theme/shipkia_colors.dart';
import '../../widgets/shipkia_widgets.dart';
import '../tracking/tracking_screen.dart';

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
          onTap: () => Navigator.of(context)
              .push(shipKiaRoute<void>(builder: (_) => const TrackingScreen())),
        ),
        for (final module in primaryModules)
          AppListTile(
            leading: const Icon(Icons.apps_outlined),
            title: module,
            subtitle: _moduleDescription(module),
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: () {},
          ),
      ],
    );
  }

  String _moduleDescription(String module) {
    return switch (module) {
      'Tools' => 'Rate card, calculator, serviceability',
      'Settings' => 'Company, products, boxes, users, automation',
      'Support' => 'Tickets, comments, issue categories',
      'Channels' => 'Stores, Shopify sync, ecommerce logs',
      'Remittance' => 'COD, deductions, disputes',
      _ => 'ShipKia operations workspace',
    };
  }
}
