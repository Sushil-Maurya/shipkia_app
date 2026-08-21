class ApiRoutes {
  const ApiRoutes._();

  static const login = '/auth/login';
  static const tokenRenew = '/auth/token/renew';
  static const profile = '/auth/user/profile';
  static const orders = '/api/orders';
  static const orderTrackingInfo = '/oms/orders/get_tracking_info';
  static const estimatedCost = '/oms/shipping/estimated-cost';
  static const createShipment = '/oms/shipping/order';
  static const createReturnShipment = '/oms/shipping/return/order';
  static const schedulePickup = '/oms/shipping/order/schedule';
  static const processNdr = '/oms/shipping/process-ndr';
  static const serviceability = '/oms/shipping/serviceability';
  static const supportTickets = '/api/support/tickets';
  static const createTicket = '/oms/support';
  static const wallet = '/bms/wallet';
  static const walletSummary = '/api/wallet/summary';
  static const walletRechargeOrder = '/bms/wallet/order';
  static const walletRechargeVerify = '/bms/wallet/verify';
}
