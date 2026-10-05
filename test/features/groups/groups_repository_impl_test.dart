import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/features/groups/data/datasources/groups_remote_data_source.dart';
import 'package:group_spending_app/features/groups/data/models/group_member_models.dart';
import 'package:group_spending_app/features/groups/data/models/group_model.dart';
import 'package:group_spending_app/features/groups/data/repositories/groups_repository_impl.dart';

class FakeGroupsRemoteDataSource implements GroupsRemoteDataSource {
  GroupModel groupDetail;
  List<GroupMemberSummaryModel> members;
  bool shouldThrowMembersError;

  FakeGroupsRemoteDataSource({
    required this.groupDetail,
    required this.members,
    this.shouldThrowMembersError = false,
  });

  @override
  Future<GroupModel> getGroupDetails(int groupId) async => groupDetail;

  @override
  Future<List<GroupMemberSummaryModel>> getGroupMembers(int groupId, {String? name}) async {
    if (shouldThrowMembersError) {
      throw Exception('Network error');
    }
    return members;
  }

  @override
  Future<List<GroupModel>> getMyGroups({
    String? filter,
    String? category,
    String? search,
  }) async =>
      [groupDetail];

  @override
  Future<GroupModel> createGroup({required String name, String? description, String? category, String? defaultCurrency}) => throw UnimplementedError();

  @override
  Future<GroupModel> updateGroup(int groupId, {required String name, String? description, String? category, String? defaultCurrency}) => throw UnimplementedError();

  @override
  Future<void> archiveGroup(int groupId) async {}

  @override
  Future<void> deleteGroup(int groupId) async {}

  @override
  Future<void> joinGroup(String inviteCode) async {}

  @override
  Future<GroupJoinRequestsResult> getPendingJoinRequests(int groupId) async => throw UnimplementedError();

  @override
  Future<void> reviewJoinRequest(int requestId, {required bool approved, bool includePastFundCollections = false}) async {}

  @override
  Future<GroupMemberDetailModel> getMemberDetails(int groupId, int targetUserId) async => throw UnimplementedError();

  @override
  Future<void> removeMember(int groupId, int targetUserId) async {}

  @override
  Future<void> leaveGroup(int groupId) async {}

  @override
  Future<void> transferOwnership(int groupId, int newOwnerId) async {}
}

void main() {
  group('GroupsRepositoryImpl getGroupDetails with members population', () {
    test('populates members when group.members from remote is null', () async {
      final fakeDataSource = FakeGroupsRemoteDataSource(
        groupDetail: const GroupModel(
          id: 10,
          name: 'Nhóm du lịch',
          ownerId: 1,
          memberCount: 0,
          members: null,
        ),
        members: const [
          GroupMemberSummaryModel(
            userId: 1,
            fullName: 'Nguyễn Văn A',
            role: 'ADMIN',
            avatarUrl: 'https://example.com/a.jpg',
          ),
          GroupMemberSummaryModel(
            userId: 2,
            fullName: 'Trần Thị B',
            role: 'MEMBER',
          ),
        ],
      );

      final repo = GroupsRepositoryImpl(remoteDataSource: fakeDataSource);
      final group = await repo.getGroupDetails(10);

      expect(group.id, 10);
      expect(group.name, 'Nhóm du lịch');
      expect(group.members, isNotNull);
      expect(group.members!.length, 2);
      expect(group.members![0].userId, 1);
      expect(group.members![0].fullName, 'Nguyễn Văn A');
      expect(group.members![0].isAdmin, isTrue);
      expect(group.members![0].avatarUrl, 'https://example.com/a.jpg');
      expect(group.members![1].userId, 2);
      expect(group.members![1].fullName, 'Trần Thị B');
      expect(group.members![1].isAdmin, isFalse);
      expect(group.memberCount, 2);
    });

    test('gracefully returns group if getGroupMembers throws error', () async {
      final fakeDataSource = FakeGroupsRemoteDataSource(
        groupDetail: const GroupModel(
          id: 10,
          name: 'Nhóm du lịch',
          ownerId: 1,
          memberCount: 2,
          members: null,
        ),
        members: const [],
        shouldThrowMembersError: true,
      );

      final repo = GroupsRepositoryImpl(remoteDataSource: fakeDataSource);
      final group = await repo.getGroupDetails(10);

      expect(group.id, 10);
      expect(group.members, isNull);
      expect(group.memberCount, 2);
    });
  });
}
