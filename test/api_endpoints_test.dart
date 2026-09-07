import 'package:flutter_test/flutter_test.dart';
import 'package:shipkia_app/src/core/api/api.dart';

void main() {
  test('network config centralizes environment base urls', () {
    expect(NetworkConfig.development.resolvedBaseUrl, 'http://api.shipkia.lcl');
    expect(
      const NetworkConfig(
        baseUrl: 'http://api.shipkia.lcl/',
        apiPrefix: '/api/v1/',
      ).resolvedBaseUrl,
      'http://api.shipkia.lcl/api/v1',
    );
    expect(
      NetworkConfig.staging.resolvedBaseUrl,
      'https://staging-api.shipkia.com',
    );
    expect(NetworkConfig.production.environment, NetworkEnvironment.production);
  });

  test('auth endpoints contain paths only', () {
    expect(AuthEndpoints.login, '/auth/login');
    expect(AuthEndpoints.logout, '/auth/logout');
    expect(AuthEndpoints.tokenRenew, '/auth/token/renew');
    expect(ApiEndpoints.auth.login, AuthEndpoints.login);
    expect(ApiEndpoints.auth.logout, AuthEndpoints.logout);
  });

  test('order endpoints centralize path construction', () {
    expect(OrderEndpoints.list, '/api/orders');
    expect(OrderEndpoints.create, '/api/orders');
    expect(OrderEndpoints.byId('ORD-123'), '/api/orders/ORD-123');
    expect(OrderEndpoints.update('ORD-123'), '/api/orders/ORD-123');
    expect(OrderEndpoints.delete('ORD-123'), '/api/orders/ORD-123');
    expect(OrderEndpoints.byId('ORD 123/ABC'), '/api/orders/ORD%20123%2FABC');
    expect(ApiEndpoints.orders.byId('ORD-123'), '/api/orders/ORD-123');
  });

  test('shipment, support, wallet, profile, and ndr endpoints are grouped', () {
    expect(
      ApiEndpoints.shipments.estimatedCost,
      '/oms/shipping/estimated-cost',
    );
    expect(ApiEndpoints.shipments.create, '/oms/shipping/order');
    expect(ApiEndpoints.shipments.createReturn, '/oms/shipping/return/order');
    expect(
      ApiEndpoints.shipments.schedulePickup,
      '/oms/shipping/order/schedule',
    );
    expect(
      ApiEndpoints.shipments.serviceability,
      '/oms/shipping/serviceability',
    );
    expect(
      ApiEndpoints.shipments.byId('SHIP 1'),
      '/oms/shipping/order/SHIP%201',
    );
    expect(
      ApiEndpoints.shipments.cancel('SHIP/1'),
      '/oms/shipping/order/SHIP%2F1/cancel',
    );
    expect(ApiEndpoints.ndr.process, '/oms/shipping/process-ndr');
    expect(ApiEndpoints.support.tickets, '/api/support/tickets');
    expect(
      ApiEndpoints.support.ticketById('T 1'),
      '/api/support/tickets/T%201',
    );
    expect(ApiEndpoints.wallet.summary, '/api/wallet/summary');
    expect(ApiEndpoints.profile.current, '/auth/users/profile');
  });

  test('endpoint constants integrate with ApiRequestConfig', () {
    final config = ApiRequestConfig(
      method: HttpMethod.post,
      path: ApiEndpoints.auth.login,
      data: const {
        'type': 'email',
        'uid': 'ops@shipkia.test',
        'password': 'secret',
      },
      params: const {'source': 'mobile'},
      requiresAuth: false,
    );

    expect(config.path, '/auth/login');
    expect(config.requiresAuth, isFalse);
    expect(config.params, {'source': 'mobile'});
  });

  test('legacy ApiRoutes remains a compatibility facade', () {
    expect(ApiRoutes.login, AuthEndpoints.login);
    expect(ApiRoutes.logout, AuthEndpoints.logout);
    expect(ApiRoutes.orders, OrderEndpoints.list);
    expect(ApiRoutes.walletSummary, WalletEndpoints.summary);
  });
}
