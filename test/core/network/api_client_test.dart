import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mga_admin_and_trainer_app/core/network/api_client.dart';
import 'package:mga_admin_and_trainer_app/services/auth_cache_service.dart';

import '../../test_helpers/fake_secure_storage.dart';

void main() {
  group('ApiClient — public (unauthenticated) requests', () {
    late http.Request captured;
    late ApiClient client;

    ApiClient buildClient(http.Response response) {
      final mockClient = MockClient((request) async {
        captured = request;
        return response;
      });
      return ApiClient(AuthCacheService(), client: mockClient);
    }

    test('GET builds the correct base URL and includes public headers only', () async {
      client = buildClient(http.Response('{}', 200));
      await client.get('/admins/inactiveadmins', auth: false);

      expect(captured.method, 'GET');
      expect(captured.url.toString(), 'https://api.06071995.xyz/api/admins/inactiveadmins');
      expect(captured.headers['Content-Type'], 'application/json');
      expect(captured.headers.containsKey('Authorization'), isFalse);
    });

    test('GET with query parameters appends them to the URL', () async {
      client = buildClient(http.Response('{}', 200));
      await client.get('/members', query: {'id': '55'}, auth: false);

      expect(captured.url.path, '/api/members');
      expect(captured.url.queryParameters['id'], '55');
    });

    test('POST with a body JSON-encodes it and sends it as-is', () async {
      client = buildClient(http.Response('{}', 201));
      await client.post('/admins', body: {'username': 'bob', 'password': 'pw'}, auth: false);

      expect(captured.method, 'POST');
      expect(captured.body, '{"username":"bob","password":"pw"}');
    });

    test('POST with no body sends a null body', () async {
      client = buildClient(http.Response('{}', 200));
      await client.post('/grievances', auth: false);

      expect(captured.body, isEmpty);
    });

    test('PUT with query parameters and no body still resolves correctly', () async {
      client = buildClient(http.Response('{}', 200));
      await client.put('/members/approve/55', query: {'duration': '30'}, auth: false);

      expect(captured.method, 'PUT');
      expect(captured.url.queryParameters['duration'], '30');
    });

    test('DELETE hits the right path with no body', () async {
      client = buildClient(http.Response('', 200));
      await client.delete('/trainers/77', auth: false);

      expect(captured.method, 'DELETE');
      expect(captured.url.path, '/api/trainers/77');
    });

    test('the raw http.Response (status code and body) is returned untouched', () async {
      client = buildClient(http.Response('{"ok":true}', 201));
      final response = await client.get('/admins', auth: false);

      expect(response.statusCode, 201);
      expect(response.body, '{"ok":true}');
    });
  });

  group('ApiClient — authenticated requests', () {
    setUp(() => FakeSecureStorage.install());
    tearDown(() => FakeSecureStorage.uninstall());

    test('injects a Bearer token from AuthCacheService when auth is true (the default)', () async {
      final authCacheService = AuthCacheService();
      await authCacheService.writeSecureToken('auth_token', 'test-token-123');
      await authCacheService.writeSecureToken(
        'token_issued_at',
        DateTime.now().millisecondsSinceEpoch.toString(),
      );

      late http.Request captured;
      final mockClient = MockClient((request) async {
        captured = request;
        return http.Response('{}', 200);
      });
      final client = ApiClient(authCacheService, client: mockClient);

      await client.get('/admins/inactiveadmins');

      expect(captured.headers['Authorization'], 'Bearer test-token-123');
    });

    test('sends no Authorization header when no token is cached', () async {
      final authCacheService = AuthCacheService();

      late http.Request captured;
      final mockClient = MockClient((request) async {
        captured = request;
        return http.Response('{}', 200);
      });
      final client = ApiClient(authCacheService, client: mockClient);

      await client.get('/admins/inactiveadmins');

      expect(captured.headers.containsKey('Authorization'), isFalse);
    });

    test('an expired cached token is not sent — matches AuthCacheService\'s 15-minute TTL', () async {
      final authCacheService = AuthCacheService();
      await authCacheService.writeSecureToken('auth_token', 'stale-token');
      final sixteenMinutesAgo = DateTime.now().subtract(const Duration(minutes: 16));
      await authCacheService.writeSecureToken(
        'token_issued_at',
        sixteenMinutesAgo.millisecondsSinceEpoch.toString(),
      );

      late http.Request captured;
      final mockClient = MockClient((request) async {
        captured = request;
        return http.Response('{}', 200);
      });
      final client = ApiClient(authCacheService, client: mockClient);

      await client.get('/admins/inactiveadmins');

      expect(captured.headers.containsKey('Authorization'), isFalse);
    });
  });
}
