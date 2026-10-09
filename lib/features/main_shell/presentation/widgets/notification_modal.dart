import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../../../notifications/domain/entities/notification_enums.dart';
import '../../../notifications/domain/repositories/notifications_repository.dart';
import '../../../notifications/presentation/cubit/notifications_state.dart';
import '../../../notifications/services/notification_navigation_handler.dart';

class NotificationModal extends StatefulWidget {
  const NotificationModal({super.key});

  static Future<void> show(BuildContext context) {
    NotificationsCubit? cubit;
    try {
      cubit = context.read<NotificationsCubit>();
      cubit.loadNotifications(refresh: true);
    } catch (_) {}

    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        if (cubit != null) {
          return BlocProvider.value(
            value: cubit,
            child: const NotificationModal(),
          );
        }
        return BlocProvider<NotificationsCubit>(
          create: (_) => NotificationsCubit(_FallbackNotificationsRepository()),
          child: const NotificationModal(),
        );
      },
    );
  }

  @override
  State<NotificationModal> createState() => _NotificationModalState();
}

class _NotificationModalState extends State<NotificationModal> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (currentScroll >= maxScroll * 0.8) {
        context.read<NotificationsCubit>().loadMore();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollSheetController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            LucideIcons.bell,
                            size: 18,
                            color: AppColors.emeraldForest,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          tr.notificationsTitle,
                          style: AppTextStyle.bold(
                            fontSize: 17,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Nút Đánh dấu tất cả đã đọc
                        BlocBuilder<NotificationsCubit, NotificationsState>(
                          builder: (context, state) {
                            if (state.unreadCount == 0) return const SizedBox.shrink();
                            return TextButton.icon(
                              onPressed: () {
                                context.read<NotificationsCubit>().markAllAsRead();
                              },
                              icon: const Icon(
                                LucideIcons.checkCheck,
                                size: 16,
                                color: AppColors.emerald,
                              ),
                              label: Text(
                                'Đã đọc tất cả',
                                style: AppTextStyle.bold(
                                  fontSize: 12,
                                  color: AppColors.emerald,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, size: 20),
                          color: colors.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Filter Chips
              BlocBuilder<NotificationsCubit, NotificationsState>(
                buildWhen: (prev, curr) =>
                    prev.unreadOnlyFilter != curr.unreadOnlyFilter,
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: 'Tất cả',
                          isSelected: !state.unreadOnlyFilter,
                          onTap: () => context
                              .read<NotificationsCubit>()
                              .setUnreadOnlyFilter(false),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Chưa đọc',
                          isSelected: state.unreadOnlyFilter,
                          onTap: () => context
                              .read<NotificationsCubit>()
                              .setUnreadOnlyFilter(true),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 1),
              // Body list
              Expanded(
                child: BlocBuilder<NotificationsCubit, NotificationsState>(
                  builder: (context, state) {
                    if (state.isLoading && state.notifications.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.emerald,
                        ),
                      );
                    }

                    if (state.notifications.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: colors.surfaceMuted,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  LucideIcons.bellRing,
                                  size: 34,
                                  color: AppColors.emeraldForest,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                tr.noNotifications,
                                textAlign: TextAlign.center,
                                style: AppTextStyle.semiBold(
                                  fontSize: 14,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.emerald,
                      onRefresh: () => context
                          .read<NotificationsCubit>()
                          .loadNotifications(refresh: true),
                      child: ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemCount: state.notifications.length +
                            (state.isLoadingMore ? 1 : 0),
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          if (index == state.notifications.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.emerald,
                                  ),
                                ),
                              ),
                            );
                          }

                          final item = state.notifications[index];
                          return _buildNotificationItem(
                            context,
                            item: item,
                            formattedTime: _formatRelativeTime(item.createdAt),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              // Footer action: "Xóa thông báo đã đọc"
              BlocBuilder<NotificationsCubit, NotificationsState>(
                builder: (context, state) {
                  final hasReadItems =
                      state.notifications.any((n) => n.isRead);
                  if (!hasReadItems) return const SizedBox.shrink();

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: colors.cardBackground,
                      border: Border(top: BorderSide(color: colors.divider)),
                    ),
                    child: Center(
                      child: TextButton.icon(
                        onPressed: () {
                          context.read<NotificationsCubit>().deleteAllRead();
                        },
                        icon: const Icon(
                          LucideIcons.trash2,
                          size: 14,
                          color: AppColors.error,
                        ),
                        label: Text(
                          'Xóa các thông báo đã đọc',
                          style: AppTextStyle.medium(
                            fontSize: 12,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.emeraldForest
                : colors.surfaceMuted,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.emeraldForest
                  : colors.cardBorder,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyle.bold(
              fontSize: 12,
              color: isSelected ? Colors.white : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required NotificationEntity item,
    required String formattedTime,
  }) {
    final colors = context.colors;
    final type = item.type;

    return Dismissible(
      key: ValueKey('notification_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          LucideIcons.trash2,
          color: AppColors.error,
          size: 20,
        ),
      ),
      onDismissed: (_) {
        context.read<NotificationsCubit>().deleteNotification(item.id);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.read<NotificationsCubit>().markAsRead(item.id);
            Navigator.of(context).pop();
            NotificationNavigationHandler.handleTap(item, context: context);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: item.isRead
                  ? colors.cardBackground
                  : AppColors.emerald.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: item.isRead
                    ? colors.cardBorder
                    : AppColors.emerald.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with Badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.surfaceMuted,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: item.actorAvatarUrl != null &&
                              item.actorAvatarUrl!.isNotEmpty
                          ? Image.network(
                              item.actorAvatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Center(
                                child: Icon(
                                  type.icon,
                                  size: 20,
                                  color: type.color,
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                type.icon,
                                size: 20,
                                color: type.color,
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: type.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.cardBackground,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          type.icon,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: AppTextStyle.bold(
                                fontSize: 13,
                                color: colors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            formattedTime,
                            style: AppTextStyle.regular(
                              fontSize: 10,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.body,
                        style: AppTextStyle.regular(
                          fontSize: 12,
                          color: item.isRead
                              ? colors.textSecondary
                              : colors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!item.isRead) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.emerald,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FallbackNotificationsRepository implements NotificationsRepository {
  @override
  Future<NotificationPageResult> getNotifications({
    bool? unreadOnly,
    NotificationType? type,
    int page = 0,
    int size = 20,
  }) async =>
      const NotificationPageResult(
        items: [],
        pageNumber: 0,
        totalElements: 0,
        totalPages: 0,
        isLast: true,
      );

  @override
  Future<int> getUnreadCount() async => 0;

  @override
  Future<void> markAsRead(int notificationId) async {}

  @override
  Future<void> markAllAsRead() async {}

  @override
  Future<void> deleteNotification(int notificationId) async {}

  @override
  Future<void> deleteAllRead() async {}
}
