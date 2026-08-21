import 'package:flutter/material.dart';

import '../../theme/shipkia_colors.dart';
import '../../widgets/shipkia_widgets.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tracking')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter AWB or order id',
                prefixIcon: const Icon(Icons.travel_explore, size: 18),
                suffixIcon: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  tooltip: 'Track',
                ),
              ),
            ),
          ),
          const SkSectionHeader(title: 'Shipment Status'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ShipKiaColors.paper,
              border: Border.all(color: ShipKiaColors.neutralBorder),
              borderRadius: BorderRadius.circular(8),
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
                const LinearProgressIndicator(
                  value: 0.62,
                  color: ShipKiaColors.shipkiaBlue,
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
    return ListTile(
      dense: true,
      leading: const Icon(
        Icons.check_circle_outline,
        color: ShipKiaColors.success,
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(meta),
    );
  }
}
