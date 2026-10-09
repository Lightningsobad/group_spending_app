import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_enums.dart';
import '../../domain/repositories/notifications_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository _repository;

  NotificationsCubit(this._repository) : super(const NotificationsState());

  Future<void> loadUnreadCount() async {
    try {
      final count = await _repository.getUnreadCount();
      emit(state.copyWith(unreadCount: count));
    } catch (_) {
      // Bỏ qua lỗi mạng khi đếm thông báo
    }
  }

  Future<void> loadNotifications({
    bool refresh = false,
    bool? unreadOnly,
    NotificationType? type,
  }) async {
    final effectiveUnreadOnly = unreadOnly ?? state.unreadOnlyFilter;
    final effectiveType = type ?? state.selectedTypeFilter;

    if (!refresh && state.notifications.isNotEmpty && !state.isLoading) {
      // Nếu đã có dữ liệu và không phải refresh, chỉ cập nhật unread count
      loadUnreadCount();
    }

    emit(
      state.copyWith(
        isLoading: true,
        clearError: true,
        page: 0,
        unreadOnlyFilter: effectiveUnreadOnly,
        selectedTypeFilter: effectiveType,
      ),
    );

    try {
      final result = await _repository.getNotifications(
        unreadOnly: effectiveUnreadOnly ? true : null,
        type: effectiveType,
        page: 0,
        size: 20,
      );

      int count = state.unreadCount;
      try {
        count = await _repository.getUnreadCount();
      } catch (_) {}

      emit(
        state.copyWith(
          isLoading: false,
          notifications: result.items,
          unreadCount: count,
          page: 0,
          hasReachedMax: result.isLast,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Không thể tải danh sách thông báo.',
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || state.hasReachedMax) return;

    final nextPage = state.page + 1;
    emit(state.copyWith(isLoadingMore: true, clearError: true));

    try {
      final result = await _repository.getNotifications(
        unreadOnly: state.unreadOnlyFilter ? true : null,
        type: state.selectedTypeFilter,
        page: nextPage,
        size: 20,
      );

      final combined = [...state.notifications, ...result.items];
      // Loại bỏ trùng lặp id nếu có
      final uniqueMap = {for (var item in combined) item.id: item};

      emit(
        state.copyWith(
          isLoadingMore: false,
          notifications: uniqueMap.values.toList(),
          page: nextPage,
          hasReachedMax: result.isLast,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  void setUnreadOnlyFilter(bool unreadOnly) {
    if (state.unreadOnlyFilter == unreadOnly) return;
    loadNotifications(refresh: true, unreadOnly: unreadOnly);
  }

  Future<void> markAsRead(int notificationId) async {
    final index =
        state.notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;

    final target = state.notifications[index];
    if (target.isRead) return;

    // Optimistic update
    final updatedList = List<NotificationEntity>.from(state.notifications);
    updatedList[index] = target.copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );

    final newCount = max(0, state.unreadCount - 1);
    emit(state.copyWith(notifications: updatedList, unreadCount: newCount));

    try {
      await _repository.markAsRead(notificationId);
    } catch (_) {
      // Giữ nguyên trạng thái lạc quan trên UI
    }
  }

  Future<void> markAllAsRead() async {
    if (state.unreadCount == 0 &&
        state.notifications.every((n) => n.isRead)) {
      return;
    }

    // Optimistic update
    final now = DateTime.now();
    final updatedList = state.notifications
        .map((n) => n.copyWith(isRead: true, readAt: n.readAt ?? now))
        .toList();

    emit(state.copyWith(notifications: updatedList, unreadCount: 0));

    try {
      await _repository.markAllAsRead();
    } catch (_) {
      // Giữ nguyên trạng thái lạc quan
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    final index =
        state.notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;

    final target = state.notifications[index];
    final updatedList = List<NotificationEntity>.from(state.notifications)
      ..removeAt(index);
    final newCount =
        target.isRead ? state.unreadCount : max(0, state.unreadCount - 1);

    emit(state.copyWith(notifications: updatedList, unreadCount: newCount));

    try {
      await _repository.deleteNotification(notificationId);
    } catch (_) {
      // Có thể giữ hoặc rollback nếu cần thiết
    }
  }

  Future<void> deleteAllRead() async {
    final updatedList =
        state.notifications.where((n) => !n.isRead).toList();

    emit(state.copyWith(notifications: updatedList));

    try {
      await _repository.deleteAllRead();
    } catch (_) {
      // Giữ danh sách đã lọc
    }
  }

  void onNotificationReceived(NotificationEntity notification) {
    // Deduplication theo ID
    final exists = state.notifications.any((n) => n.id == notification.id);
    if (exists) return;

    final updated = [notification, ...state.notifications];
    final newCount = notification.isRead ? state.unreadCount : state.unreadCount + 1;

    emit(state.copyWith(notifications: updated, unreadCount: newCount));
  }

  void clear() {
    emit(const NotificationsState());
  }
}
