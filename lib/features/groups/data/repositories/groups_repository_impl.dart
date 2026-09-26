import '../../domain/repositories/groups_repository.dart';
import '../datasources/groups_remote_data_source.dart';
import '../models/group_model.dart';

class GroupsRepositoryImpl implements GroupsRepository {
  final GroupsRemoteDataSource remoteDataSource;

  GroupsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<GroupModel>> getMyGroups({String? filter, String? search}) {
    return remoteDataSource.getMyGroups(filter: filter, search: search);
  }

  @override
  Future<GroupModel> getGroupDetails(int groupId) {
    return remoteDataSource.getGroupDetails(groupId);
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
}
