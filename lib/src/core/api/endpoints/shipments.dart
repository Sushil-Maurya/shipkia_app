import 'path_segment.dart';

abstract final class ShipmentEndpoints {
  static const estimatedCost = '/oms/shipping/estimated-cost';
  static const create = '/oms/shipping/order';
  static const createReturn = '/oms/shipping/return/order';
  static const schedulePickup = '/oms/shipping/order/schedule';
  static const serviceability = '/oms/shipping/serviceability';

  static String byId(Object shipmentId) {
    return '/oms/shipping/order/${encodePathSegment(shipmentId)}';
  }

  static String cancel(Object shipmentId) {
    return '${byId(shipmentId)}/cancel';
  }

  static String track(Object shipmentId) {
    return '${byId(shipmentId)}/track';
  }
}
