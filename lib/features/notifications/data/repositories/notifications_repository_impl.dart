import '../../domain/entities/notification_enums.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;

  NotificationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<NotificationPageResult> getNotifications({
    bool? unreadOnly,
    NotificationType? type,
    int page = 0,
    int size = 20,
  }) async {
    final pageModel = await remoteDataSource.getNotifications(
      unreadOnly: unreadOnly,
      type: (type != null && type != NotificationType.unknown)
          ? type.value
          : null,
      page: page,
      size: size,
    );

    return NotificationPageResult(
      items: pageModel.content.map((m) => m.toEntity()).toList(),
      pageNumber: pageModel.pageNumber,
      totalElements: pageModel.totalElements,
      totalPages: pageModel.totalPages,
      isLast: pageModel.last,
    );
  }

  @override
  Future<int> getUnreadCount() {
    return remoteDataSource.getUnreadCount();
  }

  @override
  Future<void> markAsRead(int notificationId) {
    return remoteDataSource.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead() {
    return remoteDataSource.markAllAsRead();
  }

  @override
  Future<void> deleteNotification(int notificationId) {
    return remoteDataSource.deleteNotification(notificationId);
  }

  @override
  Future<void> deleteAllRead() {
    return remoteDataSource.deleteAllRead();
  }
}
