import 'package:flutter/foundation.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_enums.dart';

class NotificationsState {
  final int unreadCount;
  final List<NotificationEntity> notifications;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int page;
  final bool unreadOnlyFilter;
  final NotificationType? selectedTypeFilter;
  final String? errorMessage;
  final bool hasInitialError;
  final bool hasLoadMoreError;
  final Set<int> pendingMutationIds;
  final bool isBulkActionInProgress;

  const NotificationsState({
    this.unreadCount = 0,
    this.notifications = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.page = 0,
    this.unreadOnlyFilter = false,
    this.selectedTypeFilter,
    this.errorMessage,
    this.hasInitialError = false,
    this.hasLoadMoreError = false,
    this.pendingMutationIds = const {},
    this.isBulkActionInProgress = false,
  });

  NotificationsState copyWith({
    int? unreadCount,
    List<NotificationEntity>? notifications,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    int? page,
    bool? unreadOnlyFilter,
    NotificationType? selectedTypeFilter,
    bool clearTypeFilter = false,
    String? errorMessage,
    bool clearError = false,
    bool? hasInitialError,
    bool? hasLoadMoreError,
    Set<int>? pendingMutationIds,
    bool? isBulkActionInProgress,
  }) {
    return NotificationsState(
      unreadCount: unreadCount ?? this.unreadCount,
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
      unreadOnlyFilter: unreadOnlyFilter ?? this.unreadOnlyFilter,
      selectedTypeFilter: clearTypeFilter
          ? null
          : (selectedTypeFilter ?? this.selectedTypeFilter),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasInitialError: hasInitialError ?? this.hasInitialError,
      hasLoadMoreError: hasLoadMoreError ?? this.hasLoadMoreError,
      pendingMutationIds: pendingMutationIds ?? this.pendingMutationIds,
      isBulkActionInProgress:
          isBulkActionInProgress ?? this.isBulkActionInProgress,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationsState &&
          runtimeType == other.runtimeType &&
          unreadCount == other.unreadCount &&
          listEquals(notifications, other.notifications) &&
          isLoading == other.isLoading &&
          isLoadingMore == other.isLoadingMore &&
          hasReachedMax == other.hasReachedMax &&
          page == other.page &&
          unreadOnlyFilter == other.unreadOnlyFilter &&
          selectedTypeFilter == other.selectedTypeFilter &&
          errorMessage == other.errorMessage &&
          hasInitialError == other.hasInitialError &&
          hasLoadMoreError == other.hasLoadMoreError &&
          setEquals(pendingMutationIds, other.pendingMutationIds) &&
          isBulkActionInProgress == other.isBulkActionInProgress;

  @override
  int get hashCode => Object.hash(
        unreadCount,
        notifications.length,
        isLoading,
        isLoadingMore,
        hasReachedMax,
        page,
        unreadOnlyFilter,
        selectedTypeFilter,
        errorMessage,
        hasInitialError,
        hasLoadMoreError,
        pendingMutationIds.length,
        isBulkActionInProgress,
      );
}
