import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/errors/app_exception.dart';
import 'package:group_spending_app/core/session/session_coordinator.dart';
import 'package:group_spending_app/core/storage/token_storage.dart';
import 'package:group_spending_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:group_spending_app/features/notifications/domain/entities/notification_enums.dart';
import 'package:group_spending_app/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:group_spending_app/features/notifications/presentation/cubit/notifications_cubit.dart';

class FakeTokenStorage implements TokenStorage {
  @override
  Future<void> clearTokens() async {}

  @override
  Future<String?> getAccessToken() async => 'fake-token';

  @override
  Future<String?> getRefreshToken() async => null;

  @override
  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {}
}

class FakeNotificationsRepository implements NotificationsRepository {
  List<NotificationEntity> mockItems = [];
  int mockUnreadCount = 2;
  Completer<NotificationPageResult>? getNotificationsCompleter;
  bool shouldThrowOnGetNotifications = false;
  bool shouldThrowOnMarkAsRead = false;
  bool shouldThrowOnMarkAllAsRead = false;
  bool shouldThrowOnDelete = false;
  AppException? customExceptionOnMarkAsRead;

  @override
  Future<NotificationPageResult> getNotifications({
    bool? unreadOnly,
    NotificationType? type,
    int page = 0,
    int size = 20,
  }) async {
    if (getNotificationsCompleter != null) {
      return getNotificationsCompleter!.future;
    }
    if (shouldThrowOnGetNotifications) {
      throw const AppException(message: 'Network error');
    }
    return NotificationPageResult(
      items: mockItems,
      pageNumber: page,
      totalElements: mockItems.length,
      totalPages: 1,
      isLast: true,
    );
  }

  @override
  Future<int> getUnreadCount() async => mockUnreadCount;

  @override
  Future<void> markAsRead(int notificationId) async {
    if (customExceptionOnMarkAsRead != null) {
      throw customExceptionOnMarkAsRead!;
    }
    if (shouldThrowOnMarkAsRead) {
      throw const AppException(message: 'Network error');
    }
    mockUnreadCount = mockUnreadCount > 0 ? mockUnreadCount - 1 : 0;
  }

  @override
  Future<void> markAllAsRead() async {
    if (shouldThrowOnMarkAllAsRead) {
      throw const AppException(message: 'Network error');
    }
    mockUnreadCount = 0;
  }

  @override
  Future<void> deleteNotification(int notificationId) async {
    if (shouldThrowOnDelete) {
      throw const AppException(message: 'Delete failed');
    }
  }

  @override
  Future<void> deleteAllRead() async {}
}

void main() {
  group('NotificationsCubit Test', () {
    late FakeNotificationsRepository repo;
    late SessionCoordinator sessionCoordinator;
    late NotificationsCubit cubit;

    final notif1 = NotificationEntity(
      id: 1,
      title: 'Item 1',
      body: 'Body 1',
      type: NotificationType.expenseCreated,
      referenceType: NotificationReferenceType.expense,
      isRead: false,
      createdAt: DateTime.now(),
    );

    final notif2 = NotificationEntity(
      id: 2,
      title: 'Item 2',
      body: 'Body 2',
      type: NotificationType.debtReminder,
      referenceType: NotificationReferenceType.debt,
      isRead: false,
      createdAt: DateTime.now(),
    );

    setUp(() async {
      repo = FakeNotificationsRepository();
      repo.mockItems = [notif1, notif2];
      sessionCoordinator = SessionCoordinator(tokenStorage: FakeTokenStorage());
      await sessionCoordinator.init();
      cubit = NotificationsCubit(repo, sessionCoordinator: sessionCoordinator);
    });

    tearDown(() {
      cubit.close();
    });

    test('loadUnreadCount emits updated unreadCount', () async {
      await cubit.loadUnreadCount();
      expect(cubit.state.unreadCount, 2);
    });

    test('loadNotifications loads items and updates unreadCount', () async {
      await cubit.loadNotifications(refresh: true);
      expect(cubit.state.notifications.length, 2);
      expect(cubit.state.isLoading, isFalse);
    });

    test('markAsRead optimistically marks item as read and decrements count',
        () async {
      await cubit.loadNotifications(refresh: true);
      expect(cubit.state.notifications.first.isRead, isFalse);

      await cubit.markAsRead(1);

      expect(cubit.state.notifications.first.isRead, isTrue);
      expect(cubit.state.unreadCount, 1);
    });

    test('markAllAsRead marks all items as read and zeroes unread count',
        () async {
      await cubit.loadNotifications(refresh: true);
      await cubit.markAllAsRead();

      expect(cubit.state.notifications.every((n) => n.isRead), isTrue);
      expect(cubit.state.unreadCount, 0);
    });

    test('deleteNotification removes item and updates count', () async {
      await cubit.loadNotifications(refresh: true);
      await cubit.deleteNotification(1);

      expect(cubit.state.notifications.any((n) => n.id == 1), isFalse);
      expect(cubit.state.unreadCount, 1);
    });

    test('deleteAllRead removes only read notifications', () async {
      await cubit.loadNotifications(refresh: true);
      await cubit.markAsRead(1);

      await cubit.deleteAllRead();

      expect(cubit.state.notifications.length, 1);
      expect(cubit.state.notifications.first.id, 2);
    });

    test('onNotificationReceived prepends new item and ignores duplicate', () {
      final notifNew = NotificationEntity(
        id: 99,
        title: 'New',
        body: 'New item',
        type: NotificationType.memberJoinApproved,
        referenceType: NotificationReferenceType.group,
        isRead: false,
        createdAt: DateTime.now(),
      );

      cubit.onNotificationReceived(notifNew);
      expect(cubit.state.notifications.length, 1);
      expect(cubit.state.notifications.first.id, 99);
      expect(cubit.state.unreadCount, 1);

      // Deduplication test: receive same id again
      cubit.onNotificationReceived(notifNew);
      expect(cubit.state.notifications.length, 1);
      expect(cubit.state.unreadCount, 1);
    });

    // NOTI-01: Session isolation test with Completer
    test('NOTI-01: Response from old session does not leak into new session after logout', () async {
      final completer = Completer<NotificationPageResult>();
      repo.getNotificationsCompleter = completer;

      // Start loading for user A in epoch 0
      final future = cubit.loadNotifications(refresh: true);
      expect(cubit.state.isLoading, isTrue);

      // User A logs out (epoch advances to 1) and cubit cleared
      await sessionCoordinator.clearSession();
      cubit.clear();
      expect(cubit.state.notifications, isEmpty);
      expect(cubit.state.isLoading, isFalse);

      // User A's slow response finally completes
      completer.complete(
        NotificationPageResult(
          items: [notif1],
          pageNumber: 0,
          totalElements: 1,
          totalPages: 1,
          isLast: true,
        ),
      );
      await future;

      // Verify user A's items are NOT in state
      expect(cubit.state.notifications, isEmpty);
    });

    // NOTI-05: Realtime notification received during fetch is preserved (merged)
    test('NOTI-05: Realtime notification received during loadNotifications is not overwritten', () async {
      final completer = Completer<NotificationPageResult>();
      repo.getNotificationsCompleter = completer;

      final future = cubit.loadNotifications(refresh: true);

      // Realtime notification arrives while HTTP request is in-flight
      final realtimeNotif = NotificationEntity(
        id: 999,
        title: 'Realtime title',
        body: 'Realtime body',
        type: NotificationType.expenseCreated,
        referenceType: NotificationReferenceType.expense,
        isRead: false,
        createdAt: DateTime.now(),
      );
      cubit.onNotificationReceived(realtimeNotif);
      expect(cubit.state.notifications.any((n) => n.id == 999), isTrue);

      // Complete HTTP request with [notif1, notif2]
      completer.complete(
        NotificationPageResult(
          items: [notif1, notif2],
          pageNumber: 0,
          totalElements: 2,
          totalPages: 1,
          isLast: true,
        ),
      );
      await future;

      // Both realtimeNotif and fetched items must be present!
      expect(cubit.state.notifications.any((n) => n.id == 999), isTrue);
      expect(cubit.state.notifications.any((n) => n.id == 1), isTrue);
      expect(cubit.state.notifications.any((n) => n.id == 2), isTrue);
    });

    // NOTI-06: Mutation error rollback for markAsRead
    test('NOTI-06: markAsRead rolls back isRead and unreadCount when API fails', () async {
      await cubit.loadNotifications(refresh: true);
      expect(cubit.state.unreadCount, 2);

      repo.shouldThrowOnMarkAsRead = true;

      await cubit.markAsRead(1);

      // Rolled back
      expect(cubit.state.notifications.firstWhere((n) => n.id == 1).isRead, isFalse);
      expect(cubit.state.unreadCount, 2);
      expect(cubit.state.errorMessage, isNotNull);
    });

    // NOTI-06: 404 NOTIFICATION_NOT_FOUND removes item without rollback
    test('NOTI-06: markAsRead on 404 NOTIFICATION_NOT_FOUND permanently removes item from state', () async {
      await cubit.loadNotifications(refresh: true);
      repo.customExceptionOnMarkAsRead = const AppException(
        message: 'Không tìm thấy thông báo',
        statusCode: 404,
        errorCode: 'NOTIFICATION_NOT_FOUND',
      );

      await cubit.markAsRead(1);

      // Item 1 removed from local list because it no longer exists on server
      expect(cubit.state.notifications.any((n) => n.id == 1), isFalse);
      expect(cubit.state.errorMessage, contains('không còn tồn tại'));
    });

    // NOTI-06: deleteNotification rollback on failure
    test('NOTI-06: deleteNotification restores item on API failure', () async {
      await cubit.loadNotifications(refresh: true);
      repo.shouldThrowOnDelete = true;

      await cubit.deleteNotification(1);

      expect(cubit.state.notifications.any((n) => n.id == 1), isTrue);
      expect(cubit.state.errorMessage, contains('Không thể xóa'));
    });

    // NOTI-07: Initial error state vs empty state
    test('NOTI-07: loadNotifications failure sets hasInitialError when empty', () async {
      repo.shouldThrowOnGetNotifications = true;

      await cubit.loadNotifications(refresh: true);

      expect(cubit.state.hasInitialError, isTrue);
      expect(cubit.state.notifications, isEmpty);
      expect(cubit.state.errorMessage, isNotNull);
    });
  });
}
