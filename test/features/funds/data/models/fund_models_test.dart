import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/features/funds/data/models/fund_models.dart';
import 'package:group_spending_app/features/funds/domain/entities/fund_enums.dart';

void main() {
  group('Fund Models Test', () {
    test('FundMemberModel parses from JSON correctly', () {
      final json = {
        'id': 1,
        'userId': 2,
        'fullName': 'Nguyễn Văn A',
        'email': 'a@example.com',
        'avatarUrl': 'https://example.com/avatar.jpg',
        'status': 'PAID',
        'paidAt': '2026-09-28T09:30:00Z',
      };

      final model = FundMemberModel.fromJson(json);

      expect(model.id, 1);
      expect(model.userId, 2);
      expect(model.fullName, 'Nguyễn Văn A');
      expect(model.email, 'a@example.com');
      expect(model.isPaid, isTrue);
      expect(model.status, FundMemberStatus.paid);
      expect(model.paidAt, '2026-09-28T09:30:00Z');
    });

    test('FundMemberModel handles unpaid member correctly', () {
      final json = {
        'id': 2,
        'userId': 3,
        'fullName': 'Trần B',
        'status': 'PENDING',
      };

      final model = FundMemberModel.fromJson(json);

      expect(model.userId, 3);
      expect(model.isPaid, isFalse);
      expect(model.status, FundMemberStatus.pending);
      expect(model.paidAt, isNull);
    });

    test('FundCollectionItemModel parses JSON correctly', () {
      final json = {
        'id': 101,
        'name': 'Quỹ liên hoan Q3',
        'status': 'COLLECTING',
        'statusText': 'Đang thu',
        'startDate': '2026-09-20',
        'totalTargetAmount': 1000,
        'totalTargetAmountVnd': 1000000,
        'totalCollectedAmount': 600,
        'totalCollectedAmountVnd': 600000,
        'totalMemberCount': 5,
        'paidCount': 3,
      };

      final model = FundCollectionItemModel.fromJson(json);

      expect(model.id, 101);
      expect(model.name, 'Quỹ liên hoan Q3');
      expect(model.status, FundCollectionStatus.collecting);
      expect(model.totalTargetAmountVnd, 1000000);
      expect(model.totalCollectedAmountVnd, 600000);
      expect(model.totalMemberCount, 5);
      expect(model.paidCount, 3);
      expect(model.isCollecting, isTrue);
      expect(model.startDate, '2026-09-20');
    });

    test('FundCollectionModel parses detail JSON correctly', () {
      final json = {
        'id': 101,
        'groupId': 5,
        'name': 'Quỹ liên hoan Q3',
        'targetAmountPerPerson': 100,
        'targetAmountPerPersonVnd': 100000,
        'totalTargetAmount': 200,
        'totalTargetAmountVnd': 200000,
        'totalCollectedAmount': 200,
        'totalCollectedAmountVnd': 200000,
        'paidCount': 2,
        'totalMemberCount': 2,
        'status': 'COMPLETED',
        'members': [
          {
            'id': 1,
            'userId': 1,
            'fullName': 'Admin',
            'status': 'PAID',
          },
          {
            'id': 2,
            'userId': 2,
            'fullName': 'Member',
            'status': 'PAID',
          }
        ],
      };

      final model = FundCollectionModel.fromJson(json);

      expect(model.id, 101);
      expect(model.groupId, 5);
      expect(model.status, FundCollectionStatus.completed);
      expect(model.members.length, 2);
      expect(model.members.every((m) => m.isPaid), isTrue);
    });

    test('GroupFundsOverviewModel parses overview correctly', () {
      final json = {
        'groupId': 5,
        'totalCollectedAmount': 1500,
        'totalCollectedAmountVnd': 1500000,
        'totalTargetAmount': 3000,
        'totalTargetAmountVnd': 3000000,
        'completionPercentage': 50.0,
        'funds': [
          {
            'id': 101,
            'name': 'Quỹ liên hoan',
            'status': 'COLLECTING',
            'totalTargetAmountVnd': 1000000,
            'totalCollectedAmountVnd': 600000,
            'totalMemberCount': 5,
            'paidCount': 3,
          }
        ]
      };

      final model = GroupFundsOverviewModel.fromJson(json);

      expect(model.groupId, 5);
      expect(model.totalCollectedAmountVnd, 1500000);
      expect(model.totalTargetAmountVnd, 3000000);
      expect(model.completionPercentage, 50.0);
      expect(model.funds.length, 1);
      expect(model.funds.first.name, 'Quỹ liên hoan');
    });

    test('CreateFundCollectionRequest serializes correctly', () {
      const request = CreateFundCollectionRequest(
        name: 'Quỹ du lịch',
        description: 'Chi phí đi chơi',
        targetAmountPerPerson: 250, // in k
        dueDate: '2026-10-20',
        memberUserIds: [1, 2, 3],
      );

      final json = request.toJson();

      expect(json['name'], 'Quỹ du lịch');
      expect(json['description'], 'Chi phí đi chơi');
      expect(json['targetAmountPerPerson'], 250);
      expect(json['dueDate'], '2026-10-20');
      expect(json['memberUserIds'], [1, 2, 3]);
    });

    test('UpdateFundCollectionRequest serializes correctly', () {
      const request = UpdateFundCollectionRequest(
        name: 'Quỹ sửa đổi',
        targetAmountPerPerson: 500, // in k
        memberUserIds: [1, 2],
      );

      final json = request.toJson();

      expect(json['name'], 'Quỹ sửa đổi');
      expect(json['targetAmountPerPerson'], 500);
      expect(json.containsKey('dueDate'), isFalse);
      expect(json['memberUserIds'], [1, 2]);
    });
  });
}
