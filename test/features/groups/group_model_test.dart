import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/features/groups/data/models/group_model.dart';

void main() {
  group('GroupModel Tests', () {
    test('should parse list group item JSON accurately', () {
      final json = {
        'id': 10,
        'name': 'Nhóm bóng đá thứ 6',
        'description': 'Tiền sân, tiền nước hàng tuần',
        'defaultCurrency': 'VND',
        'category': 'Sport & Clubs',
        'inviteCode': 'E93KLA',
        'codeExpiredAt': '2026-10-26T08:30:00Z',
        'status': 'ACTIVE',
        'ownerId': 1,
        'ownerName': 'Nguyễn Văn A',
        'role': 'ADMIN',
        'userBalance': 150000,
        'totalSpending': null,
        'totalSpendingVnd': null,
        'totalFundCollected': null,
        'totalFundCollectedVnd': null,
        'memberCount': 6,
        'createdAt': '2026-09-01T08:30:00Z',
      };

      final group = GroupModel.fromJson(json);

      expect(group.id, 10);
      expect(group.name, 'Nhóm bóng đá thứ 6');
      expect(group.description, 'Tiền sân, tiền nước hàng tuần');
      expect(group.category, 'Sport & Clubs');
      expect(group.inviteCode, 'E93KLA');
      expect(group.isAdmin, isTrue);
      expect(group.isActive, isTrue);
      expect(group.isArchived, isFalse);
      expect(group.userBalance, 150000);
      expect(group.memberCount, 6);
    });

    test('should parse detail group JSON with members correctly', () {
      final json = {
        'id': 15,
        'name': 'Chuyến đi Đà Lạt',
        'category': 'Travel & Trip',
        'status': 'ARCHIVED',
        'ownerId': 2,
        'role': 'MEMBER',
        'userBalance': -85000,
        'totalSpendingVnd': 1500000,
        'totalFundCollectedVnd': 500000,
        'members': [
          {
            'id': 101,
            'userId': 1,
            'fullName': 'Nguyễn Văn A',
            'email': 'nguyenvana@gmail.com',
            'role': 'ADMIN',
            'isMuted': false,
            'joinedAt': '2026-09-01T08:30:00Z',
          },
          {
            'id': 102,
            'userId': 2,
            'fullName': 'Trần Thị B',
            'email': 'tranthib@gmail.com',
            'role': 'MEMBER',
            'isMuted': true,
          }
        ],
      };

      final group = GroupModel.fromJson(json);

      expect(group.id, 15);
      expect(group.isAdmin, isFalse);
      expect(group.isArchived, isTrue);
      expect(group.isActive, isFalse);
      expect(group.totalSpendingVnd, 1500000);
      expect(group.totalFundCollectedVnd, 500000);
      expect(group.members, hasLength(2));
      expect(group.members![0].isAdmin, isTrue);
      expect(group.members![1].isMuted, isTrue);
    });
  });
}
