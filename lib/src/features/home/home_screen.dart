import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/shipkia_auth_scope.dart';
import '../../design_system/design_system.dart';

/// Member workspace, matching the web Home rather than invented dashboard metrics.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final name = context
        .dependOnInheritedWidgetOfExactType<ShipKiaAuthScope>()
        ?.notifier
        ?.profile
        ?.name
        .trim();
    const actions = [
      ('Track shipment', 'Find shipment status.', '/tracking', Icons.search),
      (
        'Orders',
        'Manage active shipments.',
        '/orders',
        Icons.inventory_2_outlined,
      ),
      (
        'Returns',
        'Track return pickups.',
        '/return_orders',
        Icons.assignment_return_outlined,
      ),
      (
        'Rate card',
        'Compare shipping rates.',
        '/tools/rate-card',
        Icons.local_shipping_outlined,
      ),
      (
        'Serviceability',
        'Check pincode coverage.',
        '/tools/serviceability',
        Icons.route_outlined,
      ),
      (
        'Wallet',
        'View wallet transactions.',
        '/wallet_transactions',
        Icons.account_balance_wallet_outlined,
      ),
      (
        'Support',
        'Resolve shipping issues.',
        '/support_ticket',
        Icons.support_agent,
      ),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Welcome ${name == null || name.isEmpty ? 'there' : name}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'Your shipping workspace is ready. Pick a workflow below and keep the day moving.',
        ),
        const SizedBox(height: 24),
        Text('Quick actions', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        for (final action in actions)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Icon(action.$4),
                title: Text(action.$1),
                subtitle: Text(action.$2),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(action.$3),
              ),
            ),
          ),
      ],
    );
  }
}
