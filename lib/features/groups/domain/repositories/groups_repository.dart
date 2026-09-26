import '../../data/models/group_model.dart';

abstract class GroupsRepository {
  Future<List<GroupModel>> getMyGroups({String? filter, String? search});
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
}
