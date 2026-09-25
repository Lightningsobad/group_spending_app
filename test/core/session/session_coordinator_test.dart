import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/session/session_coordinator.dart';
import 'package:group_spending_app/core/storage/token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  late TokenStorage tokenStorage;
  late SessionCoordinator coordinator;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    tokenStorage = TokenStorage();
    coordinator = SessionCoordinator(tokenStorage: tokenStorage);
  });

  group('SessionCoordinator Tests', () {
    test('init() sets unauthenticated when no token exists', () async {
      await coordinator.init();
      expect(coordinator.status, SessionStatus.unauthenticated);
      expect(coordinator.isAuthenticated, isFalse);
    });

    test('init() sets authenticated when token exists in storage', () async {
      await tokenStorage.saveTokens(
        accessToken: 'valid_access_token',
        refreshToken: 'valid_refresh_token',
      );

      await coordinator.init();
      expect(coordinator.status, SessionStatus.authenticated);
      expect(coordinator.isAuthenticated, isTrue);
    });

    test('commitTokens() succeeds when epoch matches current epoch', () async {
      final initialEpoch = coordinator.sessionEpoch;
      final committed = await coordinator.commitTokens(
        accessToken: 'new_access',
        refreshToken: 'new_refresh',
        forEpoch: initialEpoch,
      );

      expect(committed, isTrue);
      expect(coordinator.status, SessionStatus.authenticated);
      expect(await tokenStorage.getAccessToken(), 'new_access');
    });

    test(
      'commitTokens() drops token if user logged out while request was in-flight (epoch changed)',
      () async {
        final oldEpoch = coordinator.sessionEpoch;

        // User logs out while request was pending
        await coordinator.clearSession();
        expect(coordinator.sessionEpoch, greaterThan(oldEpoch));
        expect(coordinator.status, SessionStatus.unauthenticated);

        // In-flight response arrives with old epoch
        final committed = await coordinator.commitTokens(
          accessToken: 'stale_access',
          refreshToken: 'stale_refresh',
          forEpoch: oldEpoch,
        );

        expect(committed, isFalse);
        expect(coordinator.status, SessionStatus.unauthenticated);
        expect(await tokenStorage.getAccessToken(), isNull);
      },
    );

    test(
      'clearSession(isExpired: true) sets status to sessionExpired',
      () async {
        await tokenStorage.saveTokens(
          accessToken: 'old_access',
          refreshToken: 'old_refresh',
        );

        await coordinator.clearSession(isExpired: true);

        expect(coordinator.status, SessionStatus.sessionExpired);
        expect(coordinator.isAuthenticated, isFalse);
        expect(await tokenStorage.getAccessToken(), isNull);
      },
    );
  });
}
