import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/session/session_coordinator.dart';
import '../domain/entities/notification_entity.dart';
import '../domain/entities/notification_enums.dart';
import '../presentation/cubit/notifications_cubit.dart';

class NotificationNavigationHandler {
  NotificationNavigationHandler._();

  static NotificationEntity? _pendingNotification;
  static NotificationEntity? get pendingNotification => _pendingNotification;
  static void clearPendingNotification() => _pendingNotification = null;

  static void handleTap(
    NotificationEntity notification, {
    BuildContext? context,
    NotificationsCubit? cubit,
    SessionCoordinator? sessionCoordinator,
  }) {
    if (sessionCoordinator != null && !sessionCoordinator.isAuthenticated) {
      _pendingNotification = notification;
      return;
    }

    try {
      final targetCubit = cubit ??
          (context != null && context.mounted
              ? (context.findAncestorStateOfType<State>() != null
                  ? context.read<NotificationsCubit>()
                  : null)
              : null);
      targetCubit?.markAsRead(notification.id);
    } catch (_) {}

    final ctx = (context != null && context.mounted)
        ? context
        : AppRouter.navigatorKey.currentContext;
    if (ctx == null) {
      _pendingNotification = notification;
      return;
    }
    _pendingNotification = null;

    final type = notification.type;
    final referenceId = notification.referenceId;
    final groupId = notification.groupId;

    switch (type) {
      case NotificationType.expenseCreated:
      case NotificationType.expenseUpdated:
        if (groupId != null &&
            groupId > 0 &&
            referenceId != null &&
            referenceId > 0) {
          ctx.go('/groups/$groupId/expenses/$referenceId');
        } else if (groupId != null && groupId > 0) {
          ctx.go('/dashboard?tab=1&groupId=$groupId&groupTab=1');
        } else {
          ctx.go('/dashboard?tab=1');
        }
        break;

      case NotificationType.expenseDeleted:
        if (groupId != null && groupId > 0) {
          ctx.go('/dashboard?tab=1&groupId=$groupId&groupTab=1');
        } else {
          ctx.go('/dashboard?tab=1');
        }
        break;

      case NotificationType.debtReminder:
      case NotificationType.debtPayRequest:
      case NotificationType.debtSettled:
      case NotificationType.debtRejected:
        final detailTab =
            (notification.referenceType == NotificationReferenceType.simplifiedDebt)
                ? 0
                : 1;
        if (groupId != null && groupId > 0) {
          ctx.go(
            '/dashboard?tab=2&debtGroupId=$groupId&debtDetailTab=$detailTab',
          );
        } else {
          ctx.go('/dashboard?tab=2&debtDetailTab=$detailTab');
        }
        break;

      case NotificationType.fundCreated:
      case NotificationType.fundReminder:
      case NotificationType.fundPaid:
        if (groupId != null &&
            groupId > 0 &&
            referenceId != null &&
            referenceId > 0) {
          ctx.go('/groups/$groupId/funds/$referenceId');
        } else if (groupId != null && groupId > 0) {
          ctx.go('/dashboard?tab=1&groupId=$groupId&groupTab=2');
        } else {
          ctx.go('/dashboard?tab=1');
        }
        break;

      case NotificationType.memberJoinRequest:
        if (groupId != null && groupId > 0) {
          ctx.go('/dashboard?tab=1&groupId=$groupId&groupTab=3');
        } else {
          ctx.go('/dashboard?tab=1');
        }
        break;

      case NotificationType.memberJoinApproved:
        if (groupId != null && groupId > 0) {
          ctx.go('/dashboard?tab=1&groupId=$groupId&groupTab=0');
        } else {
          ctx.go('/dashboard?tab=1');
        }
        break;

      case NotificationType.memberJoinRejected:
      case NotificationType.unknown:
        ctx.go('/dashboard?tab=0');
        break;
    }
  }

  static void consumePendingNotification(
    BuildContext context, {
    NotificationsCubit? cubit,
  }) {
    if (_pendingNotification != null) {
      final notif = _pendingNotification!;
      _pendingNotification = null;
      handleTap(notif, context: context, cubit: cubit);
    }
  }
}
