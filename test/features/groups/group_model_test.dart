import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/features/groups/data/models/group_member_models.dart';
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

    test('GroupMemberModel.fromSummary converts summary correctly', () {
      const summary = GroupMemberSummaryModel(
        userId: 42,
        fullName: 'Lê Thị D',
        role: 'ADMIN',
        avatarUrl: 'https://example.com/avatar.png',
      );

      final model = GroupMemberModel.fromSummary(summary);

      expect(model.id, 42);
      expect(model.userId, 42);
      expect(model.fullName, 'Lê Thị D');
      expect(model.role, 'ADMIN');
      expect(model.isAdmin, isTrue);
      expect(model.avatarUrl, 'https://example.com/avatar.png');
    });

    test('copyWith clears description when clearDescription is true and preserves otherwise', () {
      const group = GroupModel(
        id: 1,
        name: 'Nhóm Test',
        description: 'Mô tả ban đầu',
        ownerId: 1,
      );

      final updatedName = group.copyWith(name: 'Nhóm Mới');
      expect(updatedName.name, 'Nhóm Mới');
      expect(updatedName.description, 'Mô tả ban đầu');

      final clearedDesc = group.copyWith(clearDescription: true);
      expect(clearedDesc.description, isNull);

      final newDesc = group.copyWith(description: 'Mô tả mới');
      expect(newDesc.description, 'Mô tả mới');
    });

    test('fromJson normalizes empty or whitespace description to null', () {
      final jsonEmpty = {
        'id': 1,
        'name': 'Nhóm Test',
        'description': '',
        'ownerId': 1,
      };
      final jsonWhitespace = {
        'id': 2,
        'name': 'Nhóm Test 2',
        'description': '   ',
        'ownerId': 1,
      };

      expect(GroupModel.fromJson(jsonEmpty).description, isNull);
      expect(GroupModel.fromJson(jsonWhitespace).description, isNull);
    });
  });
}
