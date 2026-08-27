import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';
import '../../theme/shipkia_colors.dart';
import '../../widgets/shipkia_widgets.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Tracking',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              hintText: 'Enter AWB or order id',
              prefixIcon: Icons.travel_explore,
              suffix: AppIconButton(
                icon: Icons.arrow_forward,
                onPressed: () {},
                tooltip: 'Track',
                size: 28,
              ),
            ),
          ),
          const SkSectionHeader(title: 'Shipment Status'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ShipKiaColors.surface(context),
              border: Border.all(color: ShipKiaColors.border(context)),
              borderRadius: ShipKiaRadius.mdBorder,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SKA784950112',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                const Text('Delhivery - In transit to Pune hub'),
                const SizedBox(height: 12),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 0.62),
                  duration: ShipKiaMotion.duration(
                    context,
                    ShipKiaMotion.emphasized,
                  ),
                  curve: ShipKiaMotion.standard,
                  builder: (context, value, child) =>
                      AppProgressIndicator(value: value),
                ),
              ],
            ),
          ),
          const SkSectionHeader(title: 'Timeline'),
          const _TrackingEvent(
            title: 'Picked up',
            meta: 'Delhi origin hub - 16 Aug, 7:10 PM',
          ),
          const _TrackingEvent(
            title: 'In transit',
            meta: 'Nagpur linehaul - 17 Aug, 8:20 AM',
          ),
          const _TrackingEvent(
            title: 'Out for delivery',
            meta: 'Expected 18 Aug',
          ),
        ],
      ),
    );
  }
}

class _TrackingEvent extends StatelessWidget {
  const _TrackingEvent({required this.title, required this.meta});

  final String title;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      leading: const Icon(
        Icons.check_circle_outline,
        color: ShipKiaColors.success,
      ),
      title: title,
      subtitle: meta,
    );
  }
}
