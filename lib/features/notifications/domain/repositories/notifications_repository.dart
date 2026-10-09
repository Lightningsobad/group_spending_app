import '../entities/notification_entity.dart';
import '../entities/notification_enums.dart';

class NotificationPageResult {
  final List<NotificationEntity> items;
  final int pageNumber;
  final int totalElements;
  final int totalPages;
  final bool isLast;

  const NotificationPageResult({
    required this.items,
    required this.pageNumber,
    required this.totalElements,
    required this.totalPages,
    required this.isLast,
  });
}

abstract class NotificationsRepository {
  Future<NotificationPageResult> getNotifications({
    bool? unreadOnly,
    NotificationType? type,
    int page = 0,
    int size = 20,
  });

  Future<int> getUnreadCount();

  Future<void> markAsRead(int notificationId);

  Future<void> markAllAsRead();

  Future<void> deleteNotification(int notificationId);

  Future<void> deleteAllRead();
}
