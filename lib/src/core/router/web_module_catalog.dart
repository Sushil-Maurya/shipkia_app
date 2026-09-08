import 'package:flutter/material.dart';

import '../api/api.dart';

enum WebModuleKind { section, list, custom }

class WebModuleRoute {
  const WebModuleRoute({
    required this.path,
    required this.label,
    required this.icon,
    required this.description,
    required this.kind,
    this.objectType,
    this.endpoint,
    this.method = HttpMethod.post,
    this.children = const <WebModuleRoute>[],
  });

  final String path;
  final String label;
  final IconData icon;
  final String description;
  final WebModuleKind kind;
  final String? objectType;
  final String? endpoint;
  final HttpMethod method;
  final List<WebModuleRoute> children;

  Iterable<WebModuleRoute> get flattened sync* {
    yield this;
    for (final child in children) {
      yield* child.flattened;
    }
  }
}

abstract final class WebModuleCatalog {
  static const routes = <WebModuleRoute>[
    WebModuleRoute(
      path: '/order_details',
      label: 'Orders',
      icon: Icons.shopping_cart_outlined,
      description: 'Admin order detail records.',
      kind: WebModuleKind.list,
      objectType: 'order_details',
    ),
    WebModuleRoute(
      path: '/return_orders',
      label: 'Returns',
      icon: Icons.assignment_return_outlined,
      description: 'Return order workflows from the web app.',
      kind: WebModuleKind.list,
      objectType: 'return_orders',
    ),
    WebModuleRoute(
      path: '/return_order_details',
      label: 'Returns',
      icon: Icons.assignment_return_outlined,
      description: 'Admin return order detail records.',
      kind: WebModuleKind.list,
      objectType: 'return_order_details',
    ),
    WebModuleRoute(
      path: '/pickup_and_manifest',
      label: 'Pickup and Manifest',
      icon: Icons.inventory_outlined,
      description: 'Pickup scheduling and manifest records.',
      kind: WebModuleKind.list,
      objectType: 'pickup_and_manifest',
    ),
    WebModuleRoute(
      path: '/pickup_and_manifest_details',
      label: 'Pickup and Manifest',
      icon: Icons.inventory_outlined,
      description: 'Admin pickup and manifest detail records.',
      kind: WebModuleKind.list,
      objectType: 'pickup_and_manifest_details',
    ),
    WebModuleRoute(
      path: '/delivery_attempt',
      label: 'NDR',
      icon: Icons.report_problem_outlined,
      description: 'Delivery attempts and buyer communication.',
      kind: WebModuleKind.list,
      objectType: 'delivery_attempt',
    ),
    WebModuleRoute(
      path: '/weight_dispute',
      label: 'Weight Disputes',
      icon: Icons.scale_outlined,
      description: 'Courier weight dispute records.',
      kind: WebModuleKind.list,
      objectType: 'weight_dispute',
    ),
    WebModuleRoute(
      path: '/weight_dispute_details',
      label: 'Weight Disputes',
      icon: Icons.scale_outlined,
      description: 'Admin weight dispute detail records.',
      kind: WebModuleKind.list,
      objectType: 'weight_dispute_details',
    ),
    WebModuleRoute(
      path: '/wallet_transactions',
      label: 'Wallet and Recharge',
      icon: Icons.account_balance_wallet_outlined,
      description: 'Wallet transaction and recharge records.',
      kind: WebModuleKind.list,
      objectType: 'wallet_transactions',
    ),
    WebModuleRoute(
      path: '/scheduled_delivery_action',
      label: 'Scheduled Delivery Action',
      icon: Icons.event_repeat_outlined,
      description: 'Scheduled delivery action records.',
      kind: WebModuleKind.list,
      objectType: 'scheduled_delivery_action',
    ),
    WebModuleRoute(
      path: '/support_ticket',
      label: 'Support',
      icon: Icons.support_agent,
      description: 'Support tickets and issue tracking.',
      kind: WebModuleKind.list,
      objectType: 'support_ticket',
    ),
    WebModuleRoute(
      path: '/order_channel',
      label: 'Channels',
      icon: Icons.storefront_outlined,
      description: 'Connected ecommerce channels and sync status.',
      kind: WebModuleKind.list,
      objectType: 'order_channel',
    ),
    WebModuleRoute(
      path: '/customers',
      label: 'Customers',
      icon: Icons.business_outlined,
      description: 'Customer account records.',
      kind: WebModuleKind.list,
      objectType: 'customers',
    ),
    WebModuleRoute(
      path: '/quotations',
      label: 'Quotation',
      icon: Icons.request_quote_outlined,
      description: 'Shipping quotation records.',
      kind: WebModuleKind.list,
      objectType: 'quotations',
    ),
    WebModuleRoute(
      path: '/invoice',
      label: 'Invoices',
      icon: Icons.receipt_long_outlined,
      description: 'Invoice records and documents.',
      kind: WebModuleKind.list,
      objectType: 'invoice',
    ),
    WebModuleRoute(
      path: '/dashboard/orders-overview',
      label: 'Orders Overview',
      icon: Icons.receipt_long_outlined,
      description: 'Dashboard orders overview.',
      kind: WebModuleKind.custom,
      endpoint: DashboardEndpoints.ordersOverview,
      method: HttpMethod.get,
    ),
    WebModuleRoute(
      path: '/dashboard/ndr-overview',
      label: 'NDR Overview',
      icon: Icons.message_outlined,
      description: 'Dashboard NDR overview.',
      kind: WebModuleKind.custom,
      endpoint: DashboardEndpoints.ndrOverview,
      method: HttpMethod.get,
    ),
    WebModuleRoute(
      path: '/dashboard/shipment-overview',
      label: 'Shipment Overview',
      icon: Icons.local_shipping_outlined,
      description: 'Dashboard shipment overview.',
      kind: WebModuleKind.custom,
      endpoint: DashboardEndpoints.shipmentOverview,
      method: HttpMethod.get,
    ),
    WebModuleRoute(
      path: '/dashboard/order-confirmation-overview',
      label: 'Order Confirmation Overview',
      icon: Icons.fact_check_outlined,
      description: 'Dashboard order confirmation overview.',
      kind: WebModuleKind.custom,
      endpoint: DashboardEndpoints.orderConfirmationOverview,
      method: HttpMethod.get,
    ),
    WebModuleRoute(
      path: '/remittance',
      label: 'Remittance',
      icon: Icons.payments_outlined,
      description: 'COD and remittance workspaces.',
      kind: WebModuleKind.section,
      children: [
        WebModuleRoute(
          path: '/remittance/cod_remittances',
          label: 'COD Remittances',
          icon: Icons.currency_rupee,
          description: 'COD remittance records.',
          kind: WebModuleKind.list,
          objectType: 'cod_remittances',
        ),
        WebModuleRoute(
          path: '/remittance/remittances',
          label: 'Remittance',
          icon: Icons.payments_outlined,
          description: 'Remittance records.',
          kind: WebModuleKind.list,
          objectType: 'remittances',
        ),
        WebModuleRoute(
          path: '/remittance/cod_remittance_details',
          label: 'COD Remittance Details',
          icon: Icons.receipt_long_outlined,
          description: 'Admin COD remittance detail records.',
          kind: WebModuleKind.list,
          objectType: 'cod_remittance_details',
        ),
        WebModuleRoute(
          path: '/remittance/remittance_details',
          label: 'Remittance Details',
          icon: Icons.account_balance_outlined,
          description: 'Admin remittance detail records.',
          kind: WebModuleKind.list,
          objectType: 'remittance_details',
        ),
        WebModuleRoute(
          path: '/remittance/early_remittance_plan',
          label: 'Early Remittance Plan',
          icon: Icons.calendar_month_outlined,
          description: 'Early remittance plan records.',
          kind: WebModuleKind.list,
          objectType: 'early_remittance_plan',
        ),
      ],
    ),
    WebModuleRoute(
      path: '/wallets',
      label: 'Wallet',
      icon: Icons.account_balance_wallet_outlined,
      description: 'Admin wallet workspaces.',
      kind: WebModuleKind.section,
      children: [
        WebModuleRoute(
          path: '/wallets/wallets',
          label: 'Wallet',
          icon: Icons.account_balance_wallet_outlined,
          description: 'Admin wallet records.',
          kind: WebModuleKind.list,
          objectType: 'wallets',
        ),
        WebModuleRoute(
          path: '/wallets/companies_transactions',
          label: 'Companies Transactions',
          icon: Icons.receipt_outlined,
          description: 'Company wallet transaction records.',
          kind: WebModuleKind.list,
          objectType: 'companies_transactions',
        ),
        WebModuleRoute(
          path: '/wallets/wallet_recharge',
          label: 'Wallet Recharge',
          icon: Icons.add_card_outlined,
          description: 'Wallet recharge records.',
          kind: WebModuleKind.list,
          objectType: 'wallet_recharge',
        ),
      ],
    ),
    WebModuleRoute(
      path: '/tools',
      label: 'Tools',
      icon: Icons.construction_outlined,
      description: 'Rate card, serviceability, and admin tools.',
      kind: WebModuleKind.section,
      children: [
        WebModuleRoute(
          path: '/tools/serviceability',
          label: 'Serviceability',
          icon: Icons.route_outlined,
          description: 'Courier serviceability checks.',
          kind: WebModuleKind.custom,
          endpoint: ShipmentEndpoints.serviceability,
          method: HttpMethod.get,
        ),
        WebModuleRoute(
          path: '/tools/rate-card',
          label: 'Rate Card',
          icon: Icons.local_shipping_outlined,
          description: 'Courier rate cards and zones.',
          kind: WebModuleKind.custom,
          endpoint: '/bms/rate_card',
          method: HttpMethod.get,
        ),
        WebModuleRoute(
          path: '/tools/delivery_bulk_upload',
          label: 'Bulk Upload',
          icon: Icons.upload_file_outlined,
          description: 'Admin delivery data upload workspace.',
          kind: WebModuleKind.custom,
        ),
        WebModuleRoute(
          path: '/tools/rate-configuration/delivery_zone_charges',
          label: 'Delivery Zone Charges',
          icon: Icons.map_outlined,
          description: 'Delivery zone charge records.',
          kind: WebModuleKind.list,
          objectType: 'delivery_zone_charges',
        ),
        WebModuleRoute(
          path: '/tools/rate-configuration/pincode_courier_info',
          label: 'Pincode Courier Info',
          icon: Icons.pin_drop_outlined,
          description: 'Pincode courier mapping records.',
          kind: WebModuleKind.list,
          objectType: 'pincode_courier_info',
        ),
        WebModuleRoute(
          path: '/tools/rate-configuration/postal_codes',
          label: 'Pincode Master',
          icon: Icons.location_on_outlined,
          description: 'Postal code master records.',
          kind: WebModuleKind.list,
          objectType: 'postal_codes',
        ),
        WebModuleRoute(
          path: '/tools/rate-configuration/courier_partner_mode_config',
          label: 'Courier Partner Mode Config',
          icon: Icons.tune_outlined,
          description: 'Courier mode configuration records.',
          kind: WebModuleKind.list,
          objectType: 'courier_partner_mode_config',
        ),
        WebModuleRoute(
          path: '/tools/rate-configuration/last_mile_charges',
          label: 'Last Mile Charges',
          icon: Icons.route,
          description: 'Last mile charge records.',
          kind: WebModuleKind.list,
          objectType: 'last_mile_charges',
        ),
        WebModuleRoute(
          path: '/tools/rate-configuration/origin_pincodes',
          label: 'Origin Pincodes',
          icon: Icons.warehouse_outlined,
          description: 'Origin pincode records.',
          kind: WebModuleKind.list,
          objectType: 'origin_pincodes',
        ),
      ],
    ),
    WebModuleRoute(
      path: '/settings',
      label: 'Settings',
      icon: Icons.settings_outlined,
      description: 'Workspace settings and configuration.',
      kind: WebModuleKind.section,
      children: [
        WebModuleRoute(
          path: '/settings/appearance',
          label: 'Appearance',
          icon: Icons.display_settings_outlined,
          description: 'Theme and density preferences.',
          kind: WebModuleKind.custom,
        ),
        WebModuleRoute(
          path: '/settings/company_info',
          label: 'Company Setup',
          icon: Icons.business_outlined,
          description: 'Company profile and billing details.',
          kind: WebModuleKind.list,
          objectType: 'company_info',
        ),
        WebModuleRoute(
          path: '/settings/pickup_address',
          label: 'Pickup Address',
          icon: Icons.pin_drop_outlined,
          description: 'Warehouse pickup locations.',
          kind: WebModuleKind.list,
          objectType: 'pickup_address',
        ),
        WebModuleRoute(
          path: '/settings/pickup_address_details',
          label: 'Pickup Address Details',
          icon: Icons.pin_drop_outlined,
          description: 'Admin pickup address records.',
          kind: WebModuleKind.list,
          objectType: 'pickup_address_details',
        ),
        WebModuleRoute(
          path: '/settings/tax_rate',
          label: 'Tax Rates',
          icon: Icons.percent_outlined,
          description: 'Tax rate templates.',
          kind: WebModuleKind.list,
          objectType: 'tax_rate',
        ),
        WebModuleRoute(
          path: '/settings/bank_accounts',
          label: 'Bank Details',
          icon: Icons.account_balance_outlined,
          description: 'Payout bank account records.',
          kind: WebModuleKind.list,
          objectType: 'bank_accounts',
        ),
        WebModuleRoute(
          path: '/settings/bank_account_details',
          label: 'Bank Details',
          icon: Icons.account_balance_outlined,
          description: 'Admin payout bank account records.',
          kind: WebModuleKind.list,
          objectType: 'bank_account_details',
        ),
        WebModuleRoute(
          path: '/settings/products',
          label: 'Products',
          icon: Icons.inventory_2_outlined,
          description: 'Product catalog records.',
          kind: WebModuleKind.list,
          objectType: 'products',
        ),
        WebModuleRoute(
          path: '/settings/box',
          label: 'Boxes',
          icon: Icons.inventory_outlined,
          description: 'Package box presets.',
          kind: WebModuleKind.list,
          objectType: 'box',
        ),
        WebModuleRoute(
          path: '/settings/product_box_combination',
          label: 'Product Box Combination',
          icon: Icons.category_outlined,
          description: 'Product to package mapping records.',
          kind: WebModuleKind.list,
          objectType: 'product_box_combination',
        ),
        WebModuleRoute(
          path: '/settings/product_box_proposal',
          label: 'Product Box Proposal',
          icon: Icons.lightbulb_outline,
          description: 'Suggested product and box pairings.',
          kind: WebModuleKind.list,
          objectType: 'product_box_proposal',
        ),
        WebModuleRoute(
          path: '/settings/template',
          label: 'Templates',
          icon: Icons.code_outlined,
          description: 'Label and invoice print templates.',
          kind: WebModuleKind.list,
          objectType: 'print_template',
        ),
        WebModuleRoute(
          path: '/settings/shipment-automation',
          label: 'Shipment Automation',
          icon: Icons.auto_mode_outlined,
          description: 'Courier allocation and scheduling automation.',
          kind: WebModuleKind.custom,
        ),
        WebModuleRoute(
          path: '/settings/ndr-flow',
          label: 'NDR Flow',
          icon: Icons.account_tree_outlined,
          description: 'NDR escalation and reattempt rules.',
          kind: WebModuleKind.custom,
        ),
        WebModuleRoute(
          path: '/settings/order-notification',
          label: 'Order Notification',
          icon: Icons.notifications_outlined,
          description: 'Order event notifications.',
          kind: WebModuleKind.custom,
        ),
        WebModuleRoute(
          path: '/settings/order-confirmation',
          label: 'Order Confirmation',
          icon: Icons.fact_check_outlined,
          description: 'COD and order verification settings.',
          kind: WebModuleKind.custom,
        ),
        WebModuleRoute(
          path: '/settings/default-dimension',
          label: 'Default Dimension',
          icon: Icons.straighten_outlined,
          description: 'Default package dimensions and weight.',
          kind: WebModuleKind.custom,
        ),
        WebModuleRoute(
          path: '/settings/users',
          label: 'Manage Users',
          icon: Icons.group_outlined,
          description: 'Subusers, roles, and access controls.',
          kind: WebModuleKind.list,
          objectType: 'users',
          endpoint: '/auth/users',
        ),
        WebModuleRoute(
          path: '/settings/order_status_logs',
          label: 'Order Status Logs',
          icon: Icons.manage_search_outlined,
          description: 'Order status history and logs.',
          kind: WebModuleKind.list,
          objectType: 'order_status_logs',
        ),
      ],
    ),
    WebModuleRoute(
      path: '/help',
      label: 'Help',
      icon: Icons.help_outline,
      description: 'Help resources and quick references.',
      kind: WebModuleKind.section,
      children: [
        WebModuleRoute(
          path: '/help/keyboard-shortcuts',
          label: 'Keyboard Shortcuts',
          icon: Icons.keyboard_outlined,
          description: 'Registered ShipKia keyboard shortcuts.',
          kind: WebModuleKind.custom,
        ),
        WebModuleRoute(
          path: '/help/learn-template',
          label: 'Learn Template',
          icon: Icons.school_outlined,
          description: 'Print template guidance.',
          kind: WebModuleKind.custom,
        ),
      ],
    ),
  ];

  static List<WebModuleRoute> get allRoutes {
    return routes.expand((route) => route.flattened).toList(growable: false);
  }

  static List<WebModuleRoute> get navigableRoutes {
    return allRoutes.where((route) => route.path != '/settings').toList();
  }

  static String listEndpointFor(String objectType) {
    if (objectType == 'users') return '/auth/users';
    return '/oms/$objectType/records/list';
  }
}
