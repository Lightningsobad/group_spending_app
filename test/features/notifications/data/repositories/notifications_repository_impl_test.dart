import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:group_spending_app/features/notifications/data/models/notification_model.dart';
import 'package:group_spending_app/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:group_spending_app/features/notifications/domain/entities/notification_enums.dart';

class FakeNotificationsRemoteDataSource
    implements NotificationsRemoteDataSource {
  int unreadCount = 5;
  bool markAsReadCalled = false;
  bool markAllAsReadCalled = false;
  bool deleteNotificationCalled = false;
  bool deleteAllReadCalled = false;

  @override
  Future<NotificationPageModel> getNotifications({
    bool? unreadOnly,
    String? type,
    int page = 0,
    int size = 20,
  }) async {
    return NotificationPageModel(
      content: [
        NotificationModel(
          id: 1,
          title: 'Test',
          body: 'Test body',
          type: 'EXPENSE_CREATED',
          isRead: false,
          createdAt: DateTime.now(),
        ),
      ],
      pageNumber: page,
      pageSize: size,
      totalElements: 1,
      totalPages: 1,
      last: true,
    );
  }

  @override
  Future<int> getUnreadCount() async => unreadCount;

  @override
  Future<void> markAsRead(int notificationId) async {
    markAsReadCalled = true;
  }

  @override
  Future<void> markAllAsRead() async {
    markAllAsReadCalled = true;
  }

  @override
  Future<void> deleteNotification(int notificationId) async {
    deleteNotificationCalled = true;
  }

  @override
  Future<void> deleteAllRead() async {
    deleteAllReadCalled = true;
  }
}

void main() {
  group('NotificationsRepositoryImpl Test', () {
    late FakeNotificationsRemoteDataSource fakeDataSource;
    late NotificationsRepositoryImpl repository;

    setUp(() {
      fakeDataSource = FakeNotificationsRemoteDataSource();
      repository = NotificationsRepositoryImpl(remoteDataSource: fakeDataSource);
    });

    test('getNotifications returns parsed NotificationPageResult', () async {
      final result = await repository.getNotifications(
        unreadOnly: true,
        type: NotificationType.expenseCreated,
      );

      expect(result.items.length, 1);
      expect(result.items.first.id, 1);
      expect(result.items.first.type, NotificationType.expenseCreated);
      expect(result.isLast, true);
    });

    test('getUnreadCount returns correct count', () async {
      final count = await repository.getUnreadCount();
      expect(count, 5);
    });

    test('markAsRead delegates to remote data source', () async {
      await repository.markAsRead(1);
      expect(fakeDataSource.markAsReadCalled, isTrue);
    });

    test('markAllAsRead delegates to remote data source', () async {
      await repository.markAllAsRead();
      expect(fakeDataSource.markAllAsReadCalled, isTrue);
    });

    test('deleteNotification delegates to remote data source', () async {
      await repository.deleteNotification(1);
      expect(fakeDataSource.deleteNotificationCalled, isTrue);
    });

    test('deleteAllRead delegates to remote data source', () async {
      await repository.deleteAllRead();
      expect(fakeDataSource.deleteAllReadCalled, isTrue);
    });
  });
}
