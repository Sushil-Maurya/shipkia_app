import 'path_segment.dart';

abstract final class OrderEndpoints {
  static const list = '/api/orders';
  static const create = '/api/orders';

  static String byId(Object orderId) => '$list/${encodePathSegment(orderId)}';

  static String update(Object orderId) => byId(orderId);

  static String delete(Object orderId) => byId(orderId);

  static String trackingInfo(Object orderId) {
    return '/oms/orders/${encodePathSegment(orderId)}/get_tracking_info';
  }

  static const trackingInfoLegacy = '/oms/orders/get_tracking_info';
}
