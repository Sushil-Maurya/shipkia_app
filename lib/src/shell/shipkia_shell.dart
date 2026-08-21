import 'package:flutter/material.dart';

import '../features/dashboard/dashboard_screen.dart';
import '../features/home/home_screen.dart';
import '../features/more/more_screen.dart';
import '../features/ndr/ndr_screen.dart';
import '../features/orders/orders_screen.dart';
import '../features/wallet/wallet_screen.dart';
import '../widgets/shipkia_shell_widgets.dart';

class ShipKiaShell extends StatefulWidget {
  const ShipKiaShell({super.key});

  @override
  State<ShipKiaShell> createState() => _ShipKiaShellState();
}

class _ShipKiaShellState extends State<ShipKiaShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    DashboardScreen(),
    OrdersScreen(),
    NdrScreen(),
    WalletScreen(),
    MoreScreen(),
  ];

  static const _titles = [
    ('Home', 'Dispatch Console'),
    ('Dashboard', 'Orders, NDR, shipment and COD overview'),
    ('Orders', 'Object list with filters and row actions'),
    ('NDR', 'Delivery attempts and buyer communication'),
    ('Wallet', 'Balance, charges and transactions'),
    ('More', 'Settings, tools, support and channels'),
  ];

  static const _modules = [
    (Icons.home_outlined, 'Home', 'Operational landing page'),
    (Icons.dashboard_outlined, 'Dashboard', 'Overview tabs and alerts'),
    (Icons.inventory_2_outlined, 'Orders', 'Forward order management'),
    (Icons.assignment_return_outlined, 'Returns', 'Return order workflows'),
    (Icons.report_problem_outlined, 'NDR', 'Delivery attempt resolution'),
    (Icons.receipt_long_outlined, 'Invoices', 'Billing documents'),
    (Icons.account_balance_wallet_outlined, 'Wallet', 'Balance and recharges'),
    (Icons.support_agent, 'Support', 'Tickets and comments'),
    (Icons.settings_outlined, 'Settings', 'Company, products, users'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ShipKiaModuleDrawer(modules: _modules),
      body: Builder(
        builder: (context) => Column(
          children: [
            ShipKiaTopBar(
              title: _titles[_index].$1,
              subtitle: _titles[_index].$2,
              onOpenModules: () => Scaffold.of(context).openDrawer(),
            ),
            Expanded(
              child: IndexedStack(index: _index, children: _screens),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ShipKiaBottomNav(
        selectedIndex: _index,
        onSelected: (value) => setState(() => _index = value),
      ),
    );
  }
}
