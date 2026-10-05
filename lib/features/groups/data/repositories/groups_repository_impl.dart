import '../../domain/repositories/groups_repository.dart';
import '../datasources/groups_remote_data_source.dart';
import '../models/group_member_models.dart';
import '../models/group_model.dart';

class GroupsRepositoryImpl implements GroupsRepository {
  final GroupsRemoteDataSource remoteDataSource;

  GroupsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<GroupModel>> getMyGroups({
    String? filter,
    String? category,
    String? search,
  }) {
    return remoteDataSource.getMyGroups(
      filter: filter,
      category: category,
      search: search,
    );
  }

  @override
  Future<GroupModel> getGroupDetails(int groupId) async {
    final group = await remoteDataSource.getGroupDetails(groupId);
    if (group.members != null && group.members!.isNotEmpty) {
      return group;
    }
    try {
      final membersSummary = await remoteDataSource.getGroupMembers(groupId);
      if (membersSummary.isNotEmpty) {
        final members = membersSummary
            .map((m) => GroupMemberModel.fromSummary(m))
            .toList();
        return group.copyWith(
          members: members,
          memberCount: members.length,
        );
      }
    } catch (_) {}
    return group;
  }

  @override
  Future<GroupModel> createGroup({
    required String name,
    String? description,
    String? category,
    String? defaultCurrency,
  }) {
    return remoteDataSource.createGroup(
      name: name,
      description: description,
      category: category,
      defaultCurrency: defaultCurrency,
    );
  }

  @override
  Future<GroupModel> updateGroup(
    int groupId, {
    required String name,
    String? description,
    String? category,
    String? defaultCurrency,
  }) {
    return remoteDataSource.updateGroup(
      groupId,
      name: name,
      description: description,
      category: category,
      defaultCurrency: defaultCurrency,
    );
  }

  @override
  Future<void> archiveGroup(int groupId) {
    return remoteDataSource.archiveGroup(groupId);
  }

  @override
  Future<void> deleteGroup(int groupId) {
    return remoteDataSource.deleteGroup(groupId);
  }

  @override
  Future<void> joinGroup(String inviteCode) {
    return remoteDataSource.joinGroup(inviteCode);
  }

  @override
  Future<List<GroupMemberSummaryModel>> getGroupMembers(
    int groupId, {
    String? name,
  }) {
    return remoteDataSource.getGroupMembers(groupId, name: name);
  }

  @override
  Future<GroupJoinRequestsResult> getPendingJoinRequests(int groupId) {
    return remoteDataSource.getPendingJoinRequests(groupId);
  }

  @override
  Future<void> reviewJoinRequest(
    int requestId, {
    required bool approved,
    bool includePastFundCollections = false,
  }) {
    return remoteDataSource.reviewJoinRequest(
      requestId,
      approved: approved,
      includePastFundCollections: includePastFundCollections,
    );
  }

  @override
  Future<GroupMemberDetailModel> getMemberDetails(
    int groupId,
    int targetUserId,
  ) {
    return remoteDataSource.getMemberDetails(groupId, targetUserId);
  }

  @override
  Future<void> removeMember(int groupId, int targetUserId) {
    return remoteDataSource.removeMember(groupId, targetUserId);
  }

  @override
  Future<void> leaveGroup(int groupId) {
    return remoteDataSource.leaveGroup(groupId);
  }

  @override
  Future<void> transferOwnership(int groupId, int newOwnerId) {
    return remoteDataSource.transferOwnership(groupId, newOwnerId);
  }
}
