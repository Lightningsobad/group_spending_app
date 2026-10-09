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
          errorMessage == other.errorMessage;

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
      );
}
