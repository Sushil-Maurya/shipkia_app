abstract final class AppRoutePaths {
  static const splash = '/splash';
  static const login = '/login';
  static const signUp = '/sign-up';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
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

  static const notAuthorized = '/not-authorized';
  static const notFound = '/not-found';

  static String orderDetails(String orderId) => '/orders/$orderId';
  static String orderEdit(String orderId) => '/orders/$orderId/edit';
  static String shipmentDetails(String shipmentId) => '/shipments/$shipmentId';
  static String trackingDetails(String trackingId) => '/tracking/$trackingId';
  static String ndrDetails(String ndrId) => '/ndr/$ndrId';
}

