import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/features/notifications/data/models/notification_model.dart';
import 'package:group_spending_app/features/notifications/domain/entities/notification_enums.dart';

void main() {
  group('NotificationModel & NotificationPageModel Test', () {
    final sampleJson = {
      'id': 105,
      'title': 'Khoản chi mới',
      'body':
          'Nguyễn Văn A vừa thêm khoản chi "Ăn tối lẩu Haidilao" (650.000 VNĐ) vào nhóm Đi Chơi Đà Lạt',
      'type': 'EXPENSE_CREATED',
      'referenceType': 'EXPENSE',
      'referenceId': 42,
      'groupId': 10,
      'groupName': 'Đi Chơi Đà Lạt',
      'actorId': 2,
      'actorName': 'Nguyễn Văn A',
      'actorAvatarUrl': 'https://res.cloudinary.com/.../avatar.jpg',
      'isRead': false,
      'readAt': null,
      'createdAt': '2026-10-08T14:30:00Z',
      'data': '{"groupId":"10","expenseId":"42"}',
    };

    test('parse NotificationModel from json correctly', () {
      final model = NotificationModel.fromJson(sampleJson);

      expect(model.id, 105);
      expect(model.title, 'Khoản chi mới');
      expect(model.type, 'EXPENSE_CREATED');
      expect(model.referenceType, 'EXPENSE');
      expect(model.referenceId, 42);
      expect(model.groupId, 10);
      expect(model.groupName, 'Đi Chơi Đà Lạt');
      expect(model.actorId, 2);
      expect(model.actorName, 'Nguyễn Văn A');
      expect(model.actorAvatarUrl, 'https://res.cloudinary.com/.../avatar.jpg');
      expect(model.isRead, false);
      expect(model.readAt, isNull);
      expect(model.data?['expenseId'], '42');
    });

    test('convert NotificationModel to NotificationEntity correctly', () {
      final model = NotificationModel.fromJson(sampleJson);
      final entity = model.toEntity();

      expect(entity.id, 105);
      expect(entity.type, NotificationType.expenseCreated);
      expect(entity.referenceType, NotificationReferenceType.expense);
      expect(entity.referenceId, 42);
      expect(entity.groupId, 10);
      expect(entity.isRead, false);
      expect(entity.data?['groupId'], '10');
    });

    test('parse NotificationPageModel from json correctly', () {
      final pageJson = {
        'content': [sampleJson],
        'pageable': {
          'pageNumber': 0,
          'pageSize': 20,
        },
        'totalElements': 1,
        'totalPages': 1,
        'last': true,
      };

      final pageModel = NotificationPageModel.fromJson(pageJson);

      expect(pageModel.content.length, 1);
      expect(pageModel.pageNumber, 0);
      expect(pageModel.pageSize, 20);
      expect(pageModel.totalElements, 1);
      expect(pageModel.totalPages, 1);
      expect(pageModel.last, true);
    });

    test('NotificationType fromString resolves all types and fallback', () {
      expect(NotificationType.fromString('EXPENSE_CREATED'),
          NotificationType.expenseCreated);
      expect(NotificationType.fromString('DEBT_REMINDER'),
          NotificationType.debtReminder);
      expect(NotificationType.fromString('FUND_PAID'),
          NotificationType.fundPaid);
      expect(NotificationType.fromString('NON_EXISTENT'),
          NotificationType.unknown);
    });
  });
}
