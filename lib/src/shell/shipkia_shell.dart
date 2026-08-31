import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/router/navigation_service.dart';
import '../design_system/design_system.dart';
import '../widgets/shipkia_shell_widgets.dart';

class ShipKiaShell extends StatefulWidget {
  const ShipKiaShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<ShipKiaShell> createState() => _ShipKiaShellState();
}

class _ShipKiaShellState extends State<ShipKiaShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
    return AppScaffold(
      scaffoldKey: _scaffoldKey,
      drawer: const ShipKiaModuleDrawer(modules: _modules),
      body: Builder(
        builder: (context) => Column(
          children: [
            ShipKiaTopBar(
              title: _titles[widget.navigationShell.currentIndex].$1,
              subtitle: _titles[widget.navigationShell.currentIndex].$2,
              onOpenModules: () => _scaffoldKey.currentState?.openDrawer(),
              onOpenProfile: () => context.toAccount(),
            ),
            Expanded(child: widget.navigationShell),
          ],
        ),
      ),
      bottomNavigationBar: ShipKiaBottomNav(
        selectedIndex: widget.navigationShell.currentIndex,
        onSelected: _goBranch,
      ),
    );
  }

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}
