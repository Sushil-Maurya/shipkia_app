import 'package:flutter/material.dart';

import '../../data/shipkia_mock_data.dart';
import '../../theme/shipkia_colors.dart';
import '../../widgets/shipkia_shell_widgets.dart';
import '../../widgets/shipkia_widgets.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShipKiaCommandBar(
          hint: 'Search by order, AWB, customer',
          trailing: FilledButton(
            onPressed: () {},
            child: const Icon(Icons.add, size: 18),
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            scrollDirection: Axis.horizontal,
            children: const [
              _FilterChip(label: 'All', selected: true),
              _FilterChip(label: 'Ready'),
              _FilterChip(label: 'In Transit'),
              _FilterChip(label: 'NDR'),
              _FilterChip(label: 'Delivered'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Text(
                '${orders.length} records',
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: ShipKiaColors.mutedInk),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.file_download_outlined, size: 15),
                label: const Text('Export'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              for (final order in orders)
                SkOrderRow(
                  order: order,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => OrderDetailScreen(order: order),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) {},
        label: Text(label),
        selectedColor: ShipKiaColors.shipkiaBlue,
        side: const BorderSide(color: ShipKiaColors.neutralBorder),
        labelStyle: TextStyle(
          color: selected ? Colors.white : ShipKiaColors.ink,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
