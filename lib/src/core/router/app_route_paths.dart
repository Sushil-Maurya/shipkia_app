abstract final class AppRoutePaths {
  static const splash = '/splash';
  static const login = '/login';
  static const signUp = '/sign-up';
  static const signUpWeb = '/signup';
  static const signUpEmbed = '/signup/embed';
  static const loginEmbed = '/login/embed';
  static const commit = '/commit';
  static const onboardingWelcome = '/welcome';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const updatePasswordWeb = '/update-password';
  static const registerVerify = '/register-verify';

  static const home = '/home';
  static const dashboard = '/dashboard';
  static const orders = '/orders';
  static const orderCreate = '/orders/create';
  static const shipments = '/shipments';
  static const tracking = '/tracking';
  static const ndr = '/ndr';
  static const wallet = '/wallet';
  static const more = '/more';
  static const account = '/account';
  static const help = '/help';
  static const settings = '/settings';
  static const tools = '/tools';
  static const remittance = '/remittance';
  static const channels = '/order_channel';
  static const returns = '/return_orders';
  static const pickupAndManifest = '/pickup_and_manifest';
  static const deliveryAttempt = '/delivery_attempt';
  static const weightDispute = '/weight_dispute';
  static const walletTransactions = '/wallet_transactions';
  static const wallets = '/wallets';
  static const supportTicket = '/support_ticket';
  static const orderDetailsWeb = '/order_details';
  static const returnOrderDetails = '/return_order_details';
  static const pickupAndManifestDetails = '/pickup_and_manifest_details';
  static const weightDisputeDetails = '/weight_dispute_details';
  static const scheduledDeliveryAction = '/scheduled_delivery_action';
  static const customers = '/customers';
  static const quotations = '/quotations';
  static const invoice = '/invoice';

  static const notAuthorized = '/not-authorized';
  static const notFound = '/not-found';

  static String orderDetails(String orderId) => '/orders/$orderId';
  static String orderEdit(String orderId) => '/orders/$orderId/edit';
  static String shipmentDetails(String shipmentId) => '/shipments/$shipmentId';
  static String trackingDetails(String trackingId) => '/tracking/$trackingId';
  static String ndrDetails(String ndrId) => '/ndr/$ndrId';
}
