import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:group_spending_app/features/notifications/domain/entities/notification_enums.dart';
import 'package:group_spending_app/features/notifications/services/notification_navigation_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationNavigationHandler Test', () {
    test('handleTap handles without crashing when context is null', () {
      final notif = NotificationEntity(
        id: 1,
        title: 'Test',
        body: 'Test body',
        type: NotificationType.expenseCreated,
        referenceType: NotificationReferenceType.expense,
        groupId: 10,
        referenceId: 20,
        isRead: false,
        createdAt: DateTime.now(),
      );

      // Should gracefully return when context / navigator is not mounted
      expect(() => NotificationNavigationHandler.handleTap(notif),
          returnsNormally);
    });

    test('handleTap handles debtReminder with simplifiedDebt reference type', () {
      final notif = NotificationEntity(
        id: 2,
        title: 'Nhắc nợ',
        body: 'Bạn có khoản nợ cần thanh toán',
        type: NotificationType.debtReminder,
        referenceType: NotificationReferenceType.simplifiedDebt,
        groupId: 10,
        referenceId: 101,
        isRead: false,
        createdAt: DateTime.now(),
      );

      expect(() => NotificationNavigationHandler.handleTap(notif),
          returnsNormally);
    });

    test('handleTap handles debtPayRequest with debtSettlement reference type', () {
      final notif = NotificationEntity(
        id: 3,
        title: 'Yêu cầu xác nhận',
        body: 'Thành viên đã thanh toán',
        type: NotificationType.debtPayRequest,
        referenceType: NotificationReferenceType.debtSettlement,
        groupId: 10,
        referenceId: 501,
        isRead: false,
        createdAt: DateTime.now(),
      );

      expect(() => NotificationNavigationHandler.handleTap(notif),
          returnsNormally);
    });

    test('handleTap handles debtRejected and debtSettled notifications', () {
      final notif = NotificationEntity(
        id: 4,
        title: 'Từ chối tất toán',
        body: 'Khoản thanh toán bị từ chối',
        type: NotificationType.debtRejected,
        referenceType: NotificationReferenceType.debtSettlement,
        groupId: 10,
        referenceId: 501,
        isRead: false,
        createdAt: DateTime.now(),
      );

      expect(() => NotificationNavigationHandler.handleTap(notif),
          returnsNormally);
    });
  });
}
