import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../domain/entities/notification_entity.dart';
import '../domain/entities/notification_enums.dart';

class NotificationNavigationHandler {
  NotificationNavigationHandler._();

  static void handleTap(
    NotificationEntity notification, {
    BuildContext? context,
  }) {
    final ctx = context ?? AppRouter.navigatorKey.currentContext;
    if (ctx == null) return;

    final type = notification.type;
    final referenceId = notification.referenceId;
    final groupId = notification.groupId;

    switch (type) {
      case NotificationType.expenseCreated:
      case NotificationType.expenseUpdated:
      case NotificationType.expenseDeleted:
        // Chuyển hướng tới tab Nhóm và màn hình chi tiêu
        if (groupId != null && groupId > 0) {
          ctx.go('/dashboard?tab=1');
        } else {
          ctx.go('/dashboard?tab=0');
        }
        break;

      case NotificationType.debtReminder:
      case NotificationType.debtPayRequest:
      case NotificationType.debtSettled:
      case NotificationType.debtRejected:
        // Chuyển hướng tới tab Công nợ
        ctx.go('/dashboard?tab=2');
        break;

      case NotificationType.fundCreated:
      case NotificationType.fundReminder:
      case NotificationType.fundPaid:
        // Chuyển hướng tới chi tiết quỹ nếu có đủ thông tin
        if (groupId != null && groupId > 0 && referenceId != null && referenceId > 0) {
          ctx.push('/groups/$groupId/funds/$referenceId');
        } else {
          ctx.go('/dashboard?tab=1');
        }
        break;

      case NotificationType.memberJoinRequest:
      case NotificationType.memberJoinApproved:
        ctx.go('/dashboard?tab=1');
        break;

      case NotificationType.memberJoinRejected:
      case NotificationType.unknown:
        ctx.go('/dashboard?tab=0');
        break;
    }
  }
}
