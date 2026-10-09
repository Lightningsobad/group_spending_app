import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:group_spending_app/features/notifications/domain/entities/notification_enums.dart';
import 'package:group_spending_app/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:group_spending_app/features/notifications/presentation/cubit/notifications_cubit.dart';

class FakeNotificationsRepository implements NotificationsRepository {
  List<NotificationEntity> mockItems = [];
  int mockUnreadCount = 2;

  @override
  Future<NotificationPageResult> getNotifications({
    bool? unreadOnly,
    NotificationType? type,
    int page = 0,
    int size = 20,
  }) async {
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
    mockUnreadCount = mockUnreadCount > 0 ? mockUnreadCount - 1 : 0;
  }

  @override
  Future<void> markAllAsRead() async {
    mockUnreadCount = 0;
  }

  @override
  Future<void> deleteNotification(int notificationId) async {}

  @override
  Future<void> deleteAllRead() async {}
}

void main() {
  group('NotificationsCubit Test', () {
    late FakeNotificationsRepository repo;
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

    setUp(() {
      repo = FakeNotificationsRepository();
      repo.mockItems = [notif1, notif2];
      cubit = NotificationsCubit(repo);
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
  });
}
