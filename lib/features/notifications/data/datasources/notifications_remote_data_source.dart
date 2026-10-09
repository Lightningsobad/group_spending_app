import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<NotificationPageModel> getNotifications({
    bool? unreadOnly,
    String? type,
    int page = 0,
    int size = 20,
  });

  Future<int> getUnreadCount();

  Future<void> markAsRead(int notificationId);

  Future<void> markAllAsRead();

  Future<void> deleteNotification(int notificationId);

  Future<void> deleteAllRead();
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final ApiClient _client;

  NotificationsRemoteDataSourceImpl(this._client);

  @override
  Future<NotificationPageModel> getNotifications({
    bool? unreadOnly,
    String? type,
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
    };
    if (unreadOnly != null) {
      queryParams['unreadOnly'] = unreadOnly;
    }
    if (type != null && type.isNotEmpty) {
      queryParams['type'] = type;
    }

    final response = await _client.get<Map<String, dynamic>>(
      '/notifications',
      queryParameters: queryParams,
    );

    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) {
      return const NotificationPageModel(
        content: [],
        pageNumber: 0,
        pageSize: 20,
        totalElements: 0,
        totalPages: 0,
        last: true,
      );
    }

    return NotificationPageModel.fromJson(data);
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/notifications/unread-count',
    );
    final data = response.data?['data'] as Map<String, dynamic>?;
    return (data?['unreadCount'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    await _client.patch<Map<String, dynamic>>(
      '/notifications/$notificationId/read',
    );
  }

  @override
  Future<void> markAllAsRead() async {
    await _client.patch<Map<String, dynamic>>(
      '/notifications/read-all',
    );
  }

  @override
  Future<void> deleteNotification(int notificationId) async {
    await _client.delete<Map<String, dynamic>>(
      '/notifications/$notificationId',
    );
  }

  @override
  Future<void> deleteAllRead() async {
    await _client.delete<Map<String, dynamic>>(
      '/notifications',
    );
  }
}
