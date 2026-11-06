import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:group_spending_app/core/router/app_router.dart';
import 'package:group_spending_app/core/session/session_coordinator.dart';
import 'package:group_spending_app/core/storage/token_storage.dart';
import 'package:group_spending_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:group_spending_app/features/notifications/domain/entities/notification_enums.dart';
import 'package:group_spending_app/features/notifications/services/notification_navigation_handler.dart';

class FakeTokenStorage implements TokenStorage {
  @override
  Future<void> clearTokens() async {}

  @override
  Future<String?> getAccessToken() async => 'test';

  @override
  Future<String?> getRefreshToken() async => null;

  @override
  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationNavigationHandler Test', () {
    test('handleTap handles without crashing when context is null', () {
      final notif = NotificationEntity(
        id: 1,
        title: 'Test',
        body: 'Test body',
        type: NotificationType.expenseCreated,
        referenceType: NotificationReferenceType.expense,
        groupId: 10,
        referenceId: 20,
        isRead: false,
        createdAt: DateTime.now(),
      );

      expect(
        () => NotificationNavigationHandler.handleTap(notif),
        returnsNormally,
      );
    });

    test('NOTI-03: Queues pendingNotification when unauthenticated', () {
      final sessionCoordinator =
          SessionCoordinator(tokenStorage: FakeTokenStorage());
      // status is initial (not authenticated)
      expect(sessionCoordinator.isAuthenticated, isFalse);

      final notif = NotificationEntity(
        id: 100,
        title: 'Cold Start',
        body: 'Cold start notif',
        type: NotificationType.expenseCreated,
        referenceType: NotificationReferenceType.expense,
        groupId: 10,
        referenceId: 20,
        isRead: false,
        createdAt: DateTime.now(),
      );

      NotificationNavigationHandler.handleTap(
        notif,
        sessionCoordinator: sessionCoordinator,
      );

      expect(NotificationNavigationHandler.pendingNotification, equals(notif));
      NotificationNavigationHandler.clearPendingNotification();
      expect(NotificationNavigationHandler.pendingNotification, isNull);
    });

    testWidgets('NOTI-02 & NOTI-04: Navigates with correct route and parameters for Debt and Expense',
        (tester) async {
      String? lastNavigatedLocation;

      final router = GoRouter(
        navigatorKey: AppRouter.navigatorKey,
        initialLocation: '/dashboard?tab=0',
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) {
              lastNavigatedLocation = state.uri.toString();
              return const Scaffold(body: Text('Dashboard'));
            },
          ),
          GoRoute(
            path: '/groups/:groupId/expenses/:expenseId',
            builder: (context, state) {
              lastNavigatedLocation = state.uri.toString();
              return const Scaffold(body: Text('Expense Detail'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();

      // 1. Debt reminder -> routes to tab=2 with debtGroupId and debtDetailTab=0
      final debtNotif = NotificationEntity(
        id: 2,
        title: 'Nhắc nợ',
        body: 'Thanh toán nợ',
        type: NotificationType.debtReminder,
        referenceType: NotificationReferenceType.simplifiedDebt,
        groupId: 15,
        referenceId: 101,
        isRead: false,
        createdAt: DateTime.now(),
      );
      NotificationNavigationHandler.handleTap(
        debtNotif,
        context: tester.element(find.byType(Scaffold).last),
      );
      await tester.pumpAndSettle();
      expect(lastNavigatedLocation, contains('/dashboard?tab=2&debtGroupId=15&debtDetailTab=0'));

      // 2. Debt pay request -> routes to tab=2 with debtDetailTab=1
      final payRequestNotif = NotificationEntity(
        id: 3,
        title: 'Yêu cầu thanh toán',
        body: 'Xác nhận nợ',
        type: NotificationType.debtPayRequest,
        referenceType: NotificationReferenceType.debtSettlement,
        groupId: 15,
        referenceId: 501,
        isRead: false,
        createdAt: DateTime.now(),
      );
      NotificationNavigationHandler.handleTap(
        payRequestNotif,
        context: tester.element(find.byType(Scaffold).last),
      );
      await tester.pumpAndSettle();
      expect(lastNavigatedLocation, contains('/dashboard?tab=2&debtGroupId=15&debtDetailTab=1'));

      // 3. Expense created -> pushes /groups/15/expenses/20
      final expenseNotif = NotificationEntity(
        id: 4,
        title: 'Khoản chi mới',
        body: 'Chi tiêu',
        type: NotificationType.expenseCreated,
        referenceType: NotificationReferenceType.expense,
        groupId: 15,
        referenceId: 20,
        isRead: false,
        createdAt: DateTime.now(),
      );
      NotificationNavigationHandler.handleTap(
        expenseNotif,
        context: tester.element(find.byType(Scaffold).last),
      );
      await tester.pumpAndSettle();
      expect(lastNavigatedLocation, contains('/groups/15/expenses/20'));

      // 4. Member join request -> routes to tab=1, groupTab=3 (members tab)
      final memberJoinNotif = NotificationEntity(
        id: 5,
        title: 'Yêu cầu gia nhập',
        body: 'Có người xin vào nhóm',
        type: NotificationType.memberJoinRequest,
        referenceType: NotificationReferenceType.group,
        groupId: 15,
        isRead: false,
        createdAt: DateTime.now(),
      );
      NotificationNavigationHandler.handleTap(
        memberJoinNotif,
        context: tester.element(find.byType(Scaffold).last),
      );
      await tester.pumpAndSettle();
      expect(lastNavigatedLocation, contains('/dashboard?tab=1&groupId=15&groupTab=3'));
    });
  });
}
