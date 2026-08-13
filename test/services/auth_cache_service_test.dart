import 'package:flutter_test/flutter_test.dart';
import 'package:mga_admin_and_trainer_app/services/auth_cache_service.dart';

import '../test_helpers/fake_secure_storage.dart';

void main() {
  late AuthCacheService authCacheService;

  setUp(() {
    FakeSecureStorage.install();
    authCacheService = AuthCacheService();
  });

  tearDown(() => FakeSecureStorage.uninstall());

  group('getValidAuthToken', () {
    test('returns null when no token has ever been cached', () async {
      expect(await authCacheService.getValidAuthToken(), isNull);
    });

    test('returns the token when it was cached less than 15 minutes ago', () async {
      await authCacheService.writeSecureToken('auth_token', 'fresh-token');
      await authCacheService.writeSecureToken(
        'token_issued_at',
        DateTime.now().subtract(const Duration(minutes: 5)).millisecondsSinceEpoch.toString(),
      );

      expect(await authCacheService.getValidAuthToken(), 'fresh-token');
    });

    test('returns null when the token was cached more than 15 minutes ago', () async {
      await authCacheService.writeSecureToken('auth_token', 'stale-token');
      await authCacheService.writeSecureToken(
        'token_issued_at',
        DateTime.now().subtract(const Duration(minutes: 16)).millisecondsSinceEpoch.toString(),
      );

      expect(await authCacheService.getValidAuthToken(), isNull);
    });

    test('a token exactly at the 15-minute boundary is still considered expired', () async {
      // Uses a hair over 15 minutes to avoid test flakiness from the few
      // milliseconds of execution time between writing and reading.
      await authCacheService.writeSecureToken('auth_token', 'boundary-token');
      await authCacheService.writeSecureToken(
        'token_issued_at',
        DateTime.now().subtract(const Duration(minutes: 15, seconds: 1)).millisecondsSinceEpoch.toString(),
      );

      expect(await authCacheService.getValidAuthToken(), isNull);
    });

    test('expiry wipes the entire session, not just the token', () async {
      await authCacheService.writeSecureToken('auth_token', 'stale-token');
      await authCacheService.writeSecureToken('user_role', 'Admin');
      await authCacheService.writeSecureToken('logged_in_admin_id', 'A-1');
      await authCacheService.writeSecureToken(
        'token_issued_at',
        DateTime.now().subtract(const Duration(minutes: 20)).millisecondsSinceEpoch.toString(),
      );

      await authCacheService.getValidAuthToken();

      expect(await authCacheService.readSecureToken('auth_token'), isNull);
      expect(await authCacheService.readSecureToken('user_role'), isNull);
      expect(await authCacheService.readSecureToken('logged_in_admin_id'), isNull);
    });

    test('a token with no issued-at timestamp is treated as not expired', () async {
      // Defensive case: sessions cached before this TTL feature existed.
      await authCacheService.writeSecureToken('auth_token', 'legacy-token');
      expect(await authCacheService.getValidAuthToken(), 'legacy-token');
    });
  });

  group('getSecureHeaders', () {
    test('includes a Bearer token when a valid one is cached', () async {
      await authCacheService.writeSecureToken('auth_token', 'my-token');
      await authCacheService.writeSecureToken(
        'token_issued_at',
        DateTime.now().millisecondsSinceEpoch.toString(),
      );

      final headers = await authCacheService.getSecureHeaders();
      expect(headers['Authorization'], 'Bearer my-token');
      expect(headers['Content-Type'], 'application/json');
    });

    test('omits Authorization when the token has expired', () async {
      await authCacheService.writeSecureToken('auth_token', 'my-token');
      await authCacheService.writeSecureToken(
        'token_issued_at',
        DateTime.now().subtract(const Duration(minutes: 30)).millisecondsSinceEpoch.toString(),
      );

      final headers = await authCacheService.getSecureHeaders();
      expect(headers.containsKey('Authorization'), isFalse);
    });
  });

  group('clearSession', () {
    test('removes every cached session key', () async {
      await authCacheService.writeSecureToken('auth_token', 't');
      await authCacheService.writeSecureToken('token_issued_at', '123');
      await authCacheService.writeSecureToken('user_role', 'Trainer');
      await authCacheService.writeSecureToken('logged_in_trainer_id', 'T-1');
      await authCacheService.writeSecureToken('logged_in_branch_id', 'B-1');

      await authCacheService.clearSession();

      expect(await authCacheService.readSecureToken('auth_token'), isNull);
      expect(await authCacheService.readSecureToken('token_issued_at'), isNull);
      expect(await authCacheService.readSecureToken('user_role'), isNull);
      expect(await authCacheService.readSecureToken('logged_in_trainer_id'), isNull);
      expect(await authCacheService.readSecureToken('logged_in_branch_id'), isNull);
    });
  });

  group('cached-id getters fall back to sentinel strings when nothing is cached', () {
    test('getCachedAdminId', () async {
      expect(await authCacheService.getCachedAdminId(), 'UnknownAdmin');
    });

    test('getCachedTrainerId', () async {
      expect(await authCacheService.getCachedTrainerId(), 'UnknownTrainer');
    });

    test('getCachedBranchId', () async {
      expect(await authCacheService.getCachedBranchId(), 'UnknownBranch');
    });
  });
}
