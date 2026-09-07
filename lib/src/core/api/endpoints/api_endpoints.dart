import 'auth.dart';
import 'dashboard.dart';
import 'ndr.dart';
import 'orders.dart';
import 'profile.dart';
import 'shipments.dart';
import 'support.dart';
import 'wallet.dart';

abstract final class ApiEndpoints {
  static const auth = AuthEndpointGroup();
  static const dashboard = DashboardEndpointGroup();
  static const orders = OrderEndpointGroup();
  static const shipments = ShipmentEndpointGroup();
  static const ndr = NdrEndpointGroup();
  static const support = SupportEndpointGroup();
  static const wallet = WalletEndpointGroup();
  static const profile = ProfileEndpointGroup();
}

final class DashboardEndpointGroup {
  const DashboardEndpointGroup();

  String get metrics => DashboardEndpoints.metrics;
  String get ordersOverview => DashboardEndpoints.ordersOverview;
  String get ndrOverview => DashboardEndpoints.ndrOverview;
  String get shipmentOverview => DashboardEndpoints.shipmentOverview;
  String get orderConfirmationOverview =>
      DashboardEndpoints.orderConfirmationOverview;
}

final class AuthEndpointGroup {
  const AuthEndpointGroup();

  String get login => AuthEndpoints.login;
  String get logout => AuthEndpoints.logout;
  String get tokenRenew => AuthEndpoints.tokenRenew;
}

final class OrderEndpointGroup {
  const OrderEndpointGroup();

  String get list => OrderEndpoints.list;
  String get create => OrderEndpoints.create;
  String byId(Object orderId) => OrderEndpoints.byId(orderId);
  String update(Object orderId) => OrderEndpoints.update(orderId);
  String delete(Object orderId) => OrderEndpoints.delete(orderId);
  String trackingInfo(Object orderId) => OrderEndpoints.trackingInfo(orderId);
}

final class ShipmentEndpointGroup {
  const ShipmentEndpointGroup();

  String get estimatedCost => ShipmentEndpoints.estimatedCost;
  String get create => ShipmentEndpoints.create;
  String get createReturn => ShipmentEndpoints.createReturn;
  String get schedulePickup => ShipmentEndpoints.schedulePickup;
  String get serviceability => ShipmentEndpoints.serviceability;
  String byId(Object shipmentId) => ShipmentEndpoints.byId(shipmentId);
  String cancel(Object shipmentId) => ShipmentEndpoints.cancel(shipmentId);
  String track(Object shipmentId) => ShipmentEndpoints.track(shipmentId);
}

final class NdrEndpointGroup {
  const NdrEndpointGroup();

  String get process => NdrEndpoints.process;
}

final class SupportEndpointGroup {
  const SupportEndpointGroup();

  String get tickets => SupportEndpoints.tickets;
  String get createTicket => SupportEndpoints.createTicket;
  String ticketById(Object ticketId) => SupportEndpoints.ticketById(ticketId);
}

final class WalletEndpointGroup {
  const WalletEndpointGroup();

  String get wallet => WalletEndpoints.wallet;
  String get summary => WalletEndpoints.summary;
  String get rechargeOrder => WalletEndpoints.rechargeOrder;
  String get rechargeVerify => WalletEndpoints.rechargeVerify;
}

final class ProfileEndpointGroup {
  const ProfileEndpointGroup();

  String get current => ProfileEndpoints.current;
}
