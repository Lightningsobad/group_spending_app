import '../../data/models/group_member_models.dart';
import '../../data/models/group_model.dart';
import '../../data/models/group_summary_model.dart';

abstract class GroupsRepository {
  Future<List<GroupSummaryModel>> getGroupSummaries({
    String? search,
    String? status,
    String? category,
  });
  Future<List<GroupModel>> getMyGroups({
    String? filter,
    String? category,
    String? search,
  });
  Future<GroupModel> getGroupDetails(int groupId);
  Future<GroupModel> createGroup({
    required String name,
    String? description,
    String? category,
    String? defaultCurrency,
  });
  Future<GroupModel> updateGroup(
    int groupId, {
    required String name,
    String? description,
    String? category,
    String? defaultCurrency,
  });
  Future<void> archiveGroup(int groupId);
  Future<void> deleteGroup(int groupId);
  Future<void> joinGroup(String inviteCode);

  Future<List<GroupMemberSummaryModel>> getGroupMembers(
    int groupId, {
    String? name,
  });
  Future<GroupJoinRequestsResult> getPendingJoinRequests(int groupId);
  Future<void> reviewJoinRequest(
    int requestId, {
    required bool approved,
    bool includePastFundCollections = false,
  });
  Future<GroupMemberDetailModel> getMemberDetails(
    int groupId,
    int targetUserId,
  );
  Future<void> removeMember(int groupId, int targetUserId);
  Future<void> leaveGroup(int groupId);
  Future<void> transferOwnership(int groupId, int newOwnerId);
}
