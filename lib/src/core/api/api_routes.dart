import 'endpoints/auth.dart';
import 'endpoints/ndr.dart';
import 'endpoints/orders.dart';
import 'endpoints/profile.dart';
import 'endpoints/shipments.dart';
import 'endpoints/support.dart';
import 'endpoints/wallet.dart';

@Deprecated('Use ApiEndpoints instead.')
class ApiRoutes {
  const ApiRoutes._();

  static const login = AuthEndpoints.login;
  static const logout = AuthEndpoints.logout;
  static const tokenRenew = AuthEndpoints.tokenRenew;
  static const profile = ProfileEndpoints.current;
  static const orders = OrderEndpoints.list;
  static const orderTrackingInfo = OrderEndpoints.trackingInfoLegacy;
  static const estimatedCost = ShipmentEndpoints.estimatedCost;
  static const createShipment = ShipmentEndpoints.create;
  static const createReturnShipment = ShipmentEndpoints.createReturn;
  static const schedulePickup = ShipmentEndpoints.schedulePickup;
  static const processNdr = NdrEndpoints.process;
  static const serviceability = ShipmentEndpoints.serviceability;
  static const supportTickets = SupportEndpoints.tickets;
  static const createTicket = SupportEndpoints.createTicket;
  static const wallet = WalletEndpoints.wallet;
  static const walletSummary = WalletEndpoints.summary;
  static const walletRechargeOrder = WalletEndpoints.rechargeOrder;
  static const walletRechargeVerify = WalletEndpoints.rechargeVerify;
}
