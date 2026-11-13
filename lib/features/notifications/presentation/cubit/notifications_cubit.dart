import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/session/session_coordinator.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_enums.dart';
import '../../domain/repositories/notifications_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository _repository;
  final SessionCoordinator? sessionCoordinator;

  int _sessionGeneration = 0;
  int _queryGeneration = 0;
  int _unreadCountRevision = 0;

  NotificationsCubit(
    this._repository, {
    this.sessionCoordinator,
  }) : super(const NotificationsState());

  bool _isStale(int epoch, int sessionGen, [int? queryGen]) {
    if (isClosed) return true;
    if (sessionCoordinator != null &&
        sessionCoordinator!.sessionEpoch != epoch) {
      return true;
    }
    if (_sessionGeneration != sessionGen) return true;
    if (queryGen != null && _queryGeneration != queryGen) return true;
    return false;
  }

  Future<void> loadUnreadCount() async {
    final epoch = sessionCoordinator?.sessionEpoch ?? 0;
    final sessionGen = _sessionGeneration;
    final revision = ++_unreadCountRevision;

    try {
      final count = await _repository.getUnreadCount();
      if (_isStale(epoch, sessionGen) || revision != _unreadCountRevision) {
        return;
      }
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
    final epoch = sessionCoordinator?.sessionEpoch ?? 0;
    final sessionGen = _sessionGeneration;
    final queryGen = ++_queryGeneration;

    final effectiveUnreadOnly = unreadOnly ?? state.unreadOnlyFilter;
    final effectiveType = type ?? state.selectedTypeFilter;

    if (!refresh && state.notifications.isNotEmpty && !state.isLoading) {
      loadUnreadCount();
    }

    emit(
      state.copyWith(
        isLoading: true,
        clearError: true,
        hasInitialError: false,
        page: 0,
        unreadOnlyFilter: effectiveUnreadOnly,
        selectedTypeFilter: effectiveType,
      ),
    );

    // Chụp lại danh sách hiện tại trước khi gọi API để theo dõi item realtime đến trong lúc await
    final preCallNotifications = state.notifications;

    try {
      final result = await _repository.getNotifications(
        unreadOnly: effectiveUnreadOnly ? true : null,
        type: effectiveType,
        page: 0,
        size: 20,
      );

      if (_isStale(epoch, sessionGen, queryGen)) return;

      int count = state.unreadCount;
      try {
        count = await _repository.getUnreadCount();
      } catch (_) {}

      if (_isStale(epoch, sessionGen, queryGen)) return;

      // Hợp nhất (realtime merge): nếu có thông báo realtime mới nhận được trong lúc chờ response
      final realtimeItems = state.notifications
          .where((item) => !preCallNotifications.any((p) => p.id == item.id))
          .where((item) {
        if (effectiveUnreadOnly && item.isRead) return false;
        if (effectiveType != null && item.type != effectiveType) return false;
        return true;
      }).toList();

      final combined = [...realtimeItems, ...result.items];
      final uniqueMap = {for (var item in combined) item.id: item};

      emit(
        state.copyWith(
          isLoading: false,
          notifications: uniqueMap.values.toList(),
          unreadCount: count,
          page: 0,
          hasReachedMax: result.isLast,
          hasInitialError: false,
          clearError: true,
        ),
      );
    } catch (e) {
      if (_isStale(epoch, sessionGen, queryGen)) return;

      final isInitialEmpty = state.notifications.isEmpty;
      emit(
        state.copyWith(
          isLoading: false,
          hasInitialError: isInitialEmpty,
          errorMessage: 'Không thể tải danh sách thông báo.',
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || state.hasReachedMax) return;

    final epoch = sessionCoordinator?.sessionEpoch ?? 0;
    final sessionGen = _sessionGeneration;
    final queryGen = _queryGeneration;
    final nextPage = state.page + 1;

    emit(
      state.copyWith(
        isLoadingMore: true,
        clearError: true,
        hasLoadMoreError: false,
      ),
    );

    try {
      final result = await _repository.getNotifications(
        unreadOnly: state.unreadOnlyFilter ? true : null,
        type: state.selectedTypeFilter,
        page: nextPage,
        size: 20,
      );

      if (_isStale(epoch, sessionGen, queryGen)) return;

      final combined = [...state.notifications, ...result.items];
      final uniqueMap = {for (var item in combined) item.id: item};

      emit(
        state.copyWith(
          isLoadingMore: false,
          notifications: uniqueMap.values.toList(),
          page: nextPage,
          hasReachedMax: result.isLast,
          hasLoadMoreError: false,
        ),
      );
    } catch (_) {
      if (_isStale(epoch, sessionGen, queryGen)) return;
      emit(
        state.copyWith(
          isLoadingMore: false,
          hasLoadMoreError: true,
        ),
      );
    }
  }

  void setUnreadOnlyFilter(bool unreadOnly) {
    if (state.unreadOnlyFilter == unreadOnly) return;
    loadNotifications(refresh: true, unreadOnly: unreadOnly);
  }

  Future<void> markAsRead(int notificationId) async {
    if (state.pendingMutationIds.contains(notificationId)) return;

    final epoch = sessionCoordinator?.sessionEpoch ?? 0;
    final sessionGen = _sessionGeneration;

    final targetIndex =
        state.notifications.indexWhere((n) => n.id == notificationId);
    final target = targetIndex != -1 ? state.notifications[targetIndex] : null;

    if (target != null && target.isRead) return;

    // Đánh dấu đang xử lý mutation
    final newPending = Set<int>.from(state.pendingMutationIds)..add(notificationId);

    // Optimistic update
    if (target != null) {
      List<NotificationEntity> updatedList;
      if (state.unreadOnlyFilter) {
        // Nếu đang xem lọc chưa đọc thì loại bỏ khỏi danh sách hiển thị
        updatedList = List<NotificationEntity>.from(state.notifications)
          ..removeAt(targetIndex);
      } else {
        updatedList = List<NotificationEntity>.from(state.notifications);
        updatedList[targetIndex] = target.copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
      }
      final newCount = max(0, state.unreadCount - 1);
      _unreadCountRevision++;

      emit(
        state.copyWith(
          notifications: updatedList,
          unreadCount: newCount,
          pendingMutationIds: newPending,
          clearError: true,
        ),
      );
    } else {
      emit(state.copyWith(pendingMutationIds: newPending, clearError: true));
    }

    try {
      await _repository.markAsRead(notificationId);

      if (_isStale(epoch, sessionGen)) return;

      // Nếu item không có trong local trước đó (ví dụ từ push/toast), đồng bộ lại unreadCount
      if (target == null) {
        loadUnreadCount();
      }
    } on AppException catch (e) {
      if (_isStale(epoch, sessionGen)) return;

      if (e.statusCode == 404 || e.errorCode == 'NOTIFICATION_NOT_FOUND') {
        // Thông báo không còn tồn tại trên server: xóa khỏi local (nếu còn)
        final filtered =
            state.notifications.where((n) => n.id != notificationId).toList();
        emit(
          state.copyWith(
            notifications: filtered,
            errorMessage: 'Thông báo này không còn tồn tại.',
          ),
        );
      } else {
        _rollbackMarkAsRead(target, targetIndex);
      }
    } catch (_) {
      if (_isStale(epoch, sessionGen)) return;
      _rollbackMarkAsRead(target, targetIndex);
    } finally {
      if (!_isStale(epoch, sessionGen)) {
        final remainingPending = Set<int>.from(state.pendingMutationIds)
          ..remove(notificationId);
        emit(state.copyWith(pendingMutationIds: remainingPending));
      }
    }
  }

  void _rollbackMarkAsRead(NotificationEntity? target, int targetIndex) {
    if (target == null) return;

    final currentList = List<NotificationEntity>.from(state.notifications);
    final existsIndex = currentList.indexWhere((n) => n.id == target.id);

    if (existsIndex != -1) {
      currentList[existsIndex] = target; // Phục hồi isRead = false
    } else {
      // Re-insert vào vị trí thích hợp nếu đã bị remove do unreadOnlyFilter
      final insertIndex = min(targetIndex, currentList.length);
      currentList.insert(insertIndex, target);
    }

    _unreadCountRevision++;
    emit(
      state.copyWith(
        notifications: currentList,
        unreadCount: state.unreadCount + 1,
        errorMessage: 'Không thể đánh dấu đã đọc. Vui lòng thử lại.',
      ),
    );
  }

  Future<void> markAllAsRead() async {
    if (state.isBulkActionInProgress) return;
    if (state.unreadCount == 0 && state.notifications.every((n) => n.isRead)) {
      return;
    }

    final epoch = sessionCoordinator?.sessionEpoch ?? 0;
    final sessionGen = _sessionGeneration;

    final snapshot = List<NotificationEntity>.from(state.notifications);
    final previousCount = state.unreadCount;

    // Optimistic update
    final now = DateTime.now();
    final updatedList = state.unreadOnlyFilter
        ? <NotificationEntity>[]
        : state.notifications
            .map((n) => n.copyWith(isRead: true, readAt: n.readAt ?? now))
            .toList();

    _unreadCountRevision++;
    emit(
      state.copyWith(
        notifications: updatedList,
        unreadCount: 0,
        isBulkActionInProgress: true,
        clearError: true,
      ),
    );

    try {
      await _repository.markAllAsRead();
    } catch (_) {
      if (_isStale(epoch, sessionGen)) return;

      // Rollback
      _unreadCountRevision++;
      emit(
        state.copyWith(
          notifications: snapshot,
          unreadCount: previousCount,
          errorMessage: 'Không thể đánh dấu tất cả đã đọc.',
        ),
      );
    } finally {
      if (!_isStale(epoch, sessionGen)) {
        emit(state.copyWith(isBulkActionInProgress: false));
      }
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    if (state.pendingMutationIds.contains(notificationId)) return;

    final epoch = sessionCoordinator?.sessionEpoch ?? 0;
    final sessionGen = _sessionGeneration;

    final index =
        state.notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;

    final target = state.notifications[index];
    final newPending = Set<int>.from(state.pendingMutationIds)..add(notificationId);

    // Optimistic delete
    final updatedList = List<NotificationEntity>.from(state.notifications)
      ..removeAt(index);
    final newCount =
        target.isRead ? state.unreadCount : max(0, state.unreadCount - 1);
    if (!target.isRead) _unreadCountRevision++;

    emit(
      state.copyWith(
        notifications: updatedList,
        unreadCount: newCount,
        pendingMutationIds: newPending,
        clearError: true,
      ),
    );

    try {
      await _repository.deleteNotification(notificationId);
    } catch (_) {
      if (_isStale(epoch, sessionGen)) return;

      // Rollback: khôi phục lại item tại vị trí ban đầu
      final rollbackList = List<NotificationEntity>.from(state.notifications);
      final insertIndex = min(index, rollbackList.length);
      rollbackList.insert(insertIndex, target);
      final restoredCount =
          target.isRead ? state.unreadCount : state.unreadCount + 1;
      if (!target.isRead) _unreadCountRevision++;

      emit(
        state.copyWith(
          notifications: rollbackList,
          unreadCount: restoredCount,
          errorMessage: 'Không thể xóa thông báo. Vui lòng thử lại.',
        ),
      );
    } finally {
      if (!_isStale(epoch, sessionGen)) {
        final remainingPending = Set<int>.from(state.pendingMutationIds)
          ..remove(notificationId);
        emit(state.copyWith(pendingMutationIds: remainingPending));
      }
    }
  }

  Future<void> deleteAllRead() async {
    if (state.isBulkActionInProgress) return;

    final epoch = sessionCoordinator?.sessionEpoch ?? 0;
    final sessionGen = _sessionGeneration;

    final snapshot = List<NotificationEntity>.from(state.notifications);
    final updatedList = state.notifications.where((n) => !n.isRead).toList();

    emit(
      state.copyWith(
        notifications: updatedList,
        isBulkActionInProgress: true,
        clearError: true,
      ),
    );

    try {
      await _repository.deleteAllRead();
    } catch (_) {
      if (_isStale(epoch, sessionGen)) return;

      emit(
        state.copyWith(
          notifications: snapshot,
          errorMessage: 'Không thể xóa các thông báo đã đọc.',
        ),
      );
    } finally {
      if (!_isStale(epoch, sessionGen)) {
        emit(state.copyWith(isBulkActionInProgress: false));
      }
    }
  }

  void onNotificationReceived(NotificationEntity notification) {
    if (sessionCoordinator != null && !sessionCoordinator!.isAuthenticated) {
      return;
    }

    // Deduplication theo ID
    final exists = state.notifications.any((n) => n.id == notification.id);
    if (exists) return;

    // Kiểm tra xem có thỏa mãn bộ lọc hiện tại không
    bool shouldAddToList = true;
    if (state.unreadOnlyFilter && notification.isRead) {
      shouldAddToList = false;
    }
    if (state.selectedTypeFilter != null &&
        notification.type != state.selectedTypeFilter) {
      shouldAddToList = false;
    }

    final updated = shouldAddToList
        ? [notification, ...state.notifications]
        : state.notifications;

    final newCount =
        notification.isRead ? state.unreadCount : state.unreadCount + 1;
    if (!notification.isRead) _unreadCountRevision++;

    emit(state.copyWith(notifications: updated, unreadCount: newCount));
  }

  void clear() {
    _sessionGeneration++;
    _queryGeneration++;
    _unreadCountRevision++;
    emit(const NotificationsState());
  }
}
