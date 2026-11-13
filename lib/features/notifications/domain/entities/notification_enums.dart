import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum NotificationType {
  expenseCreated('EXPENSE_CREATED'),
  expenseUpdated('EXPENSE_UPDATED'),
  expenseDeleted('EXPENSE_DELETED'),
  debtReminder('DEBT_REMINDER'),
  debtPayRequest('DEBT_PAY_REQUEST'),
  debtSettled('DEBT_SETTLED'),
  debtRejected('DEBT_REJECTED'),
  fundCreated('FUND_CREATED'),
  fundReminder('FUND_REMINDER'),
  fundPaid('FUND_PAID'),
  memberJoinRequest('MEMBER_JOIN_REQUEST'),
  memberJoinApproved('MEMBER_JOIN_APPROVED'),
  memberJoinRejected('MEMBER_JOIN_REJECTED'),
  unknown('UNKNOWN');

  final String value;
  const NotificationType(this.value);

  static NotificationType fromString(String? val) {
    if (val == null) return NotificationType.unknown;
    return NotificationType.values.firstWhere(
      (e) => e.value.toUpperCase() == val.trim().toUpperCase(),
      orElse: () => NotificationType.unknown,
    );
  }

  IconData get icon {
    switch (this) {
      case NotificationType.expenseCreated:
        return LucideIcons.circlePlus;
      case NotificationType.expenseUpdated:
        return LucideIcons.pencil;
      case NotificationType.expenseDeleted:
        return LucideIcons.trash2;
      case NotificationType.debtReminder:
        return LucideIcons.bellRing;
      case NotificationType.debtPayRequest:
        return LucideIcons.creditCard;
      case NotificationType.debtSettled:
        return LucideIcons.checkCheck;
      case NotificationType.debtRejected:
        return LucideIcons.alertTriangle;
      case NotificationType.fundCreated:
        return LucideIcons.landmark;
      case NotificationType.fundReminder:
        return LucideIcons.alarmClock;
      case NotificationType.fundPaid:
        return LucideIcons.sparkles;
      case NotificationType.memberJoinRequest:
        return LucideIcons.userPlus;
      case NotificationType.memberJoinApproved:
        return LucideIcons.partyPopper;
      case NotificationType.memberJoinRejected:
        return LucideIcons.circleX;
      case NotificationType.unknown:
        return LucideIcons.bell;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.expenseCreated:
      case NotificationType.expenseUpdated:
        return const Color(0xFF0D9488); // Teal
      case NotificationType.expenseDeleted:
      case NotificationType.debtRejected:
      case NotificationType.memberJoinRejected:
        return const Color(0xFFEF4444); // Red
      case NotificationType.debtReminder:
      case NotificationType.fundReminder:
        return const Color(0xFFF59E0B); // Amber
      case NotificationType.debtPayRequest:
        return const Color(0xFF3B82F6); // Blue
      case NotificationType.debtSettled:
      case NotificationType.fundPaid:
      case NotificationType.memberJoinApproved:
        return const Color(0xFF10B981); // Emerald / Green
      case NotificationType.fundCreated:
        return const Color(0xFF8B5CF6); // Purple
      case NotificationType.memberJoinRequest:
        return const Color(0xFF6366F1); // Indigo
      case NotificationType.unknown:
        return const Color(0xFF64748B); // Slate
    }
  }
}

enum NotificationReferenceType {
  expense('EXPENSE'),
  debt('DEBT'),
  simplifiedDebt('SIMPLIFIED_DEBT'),
  debtSettlement('DEBT_SETTLEMENT'),
  fund('FUND'),
  group('GROUP'),
  unknown('UNKNOWN');

  final String value;
  const NotificationReferenceType(this.value);

  static NotificationReferenceType fromString(String? val) {
    if (val == null) return NotificationReferenceType.unknown;
    return NotificationReferenceType.values.firstWhere(
      (e) => e.value.toUpperCase() == val.trim().toUpperCase(),
      orElse: () => NotificationReferenceType.unknown,
    );
  }
}
