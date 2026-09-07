import 'path_segment.dart';

abstract final class SupportEndpoints {
  static const tickets = '/api/support/tickets';
  static const createTicket = '/oms/support';

  static String ticketById(Object ticketId) {
    return '$tickets/${encodePathSegment(ticketId)}';
  }
}
