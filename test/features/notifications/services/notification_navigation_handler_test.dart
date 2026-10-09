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
  });
}
