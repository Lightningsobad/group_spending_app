import '../../../../core/network/api_client.dart';
import '../models/group_member_models.dart';
import '../models/group_model.dart';

abstract class GroupsRemoteDataSource {
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

class GroupsRemoteDataSourceImpl implements GroupsRemoteDataSource {
  final ApiClient _apiClient;

  GroupsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<GroupModel>> getMyGroups({
    String? filter,
    String? category,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (filter != null && filter.isNotEmpty && filter != 'ALL') {
      queryParams['filter'] = filter;
    }
    if (category != null && category.isNotEmpty && category != 'ALL') {
      queryParams['category'] = category;
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/groups',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final data = response.data;
    if (data != null && data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => GroupModel.fromJson(item))
          .toList();
    }
    return [];
  }

  @override
  Future<GroupModel> getGroupDetails(int groupId) async {
    final response = await _apiClient.get<Map<String, dynamic>>('/groups/$groupId');
    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return GroupModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw StateError('Dữ liệu nhóm không hợp lệ.');
  }

  @override
  Future<GroupModel> createGroup({
    required String name,
    String? description,
    String? category,
    String? defaultCurrency,
  }) async {
    final payload = {
      'name': name.trim(),
      if (description != null && description.trim().isNotEmpty)
        'description': description.trim(),
      'category': category ?? 'Other',
      'defaultCurrency': defaultCurrency ?? 'VND',
    };

    final response = await _apiClient.post<Map<String, dynamic>>(
      '/groups',
      data: payload,
    );

    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return GroupModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw StateError('Không thể tạo nhóm mới.');
  }

  @override
  Future<GroupModel> updateGroup(
    int groupId, {
    required String name,
    String? description,
    String? category,
    String? defaultCurrency,
  }) async {
    final payload = <String, dynamic>{
      'name': name.trim(),
    };
    if (description != null && description.trim().isNotEmpty) {
      payload['description'] = description.trim();
    }
    if (category != null) {
      payload['category'] = category;
    }
    if (defaultCurrency != null) {
      payload['defaultCurrency'] = defaultCurrency;
    }

    final response = await _apiClient.put<Map<String, dynamic>>(
      '/groups/$groupId',
      data: payload,
    );

    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return GroupModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw StateError('Không thể cập nhật thông tin nhóm.');
  }

  @override
  Future<void> archiveGroup(int groupId) async {
    await _apiClient.post<Map<String, dynamic>>('/groups/$groupId/archive');
  }

  @override
  Future<void> deleteGroup(int groupId) async {
    await _apiClient.delete<Map<String, dynamic>>('/groups/$groupId');
  }

  @override
  Future<void> joinGroup(String inviteCode) async {
    await _apiClient.post<Map<String, dynamic>>(
      '/groups/join',
      queryParameters: {'inviteCode': inviteCode.trim()},
    );
  }

  @override
  Future<List<GroupMemberSummaryModel>> getGroupMembers(
    int groupId, {
    String? name,
  }) async {
    final queryParams = <String, dynamic>{};
    if (name != null && name.trim().isNotEmpty) {
      queryParams['name'] = name.trim();
    }

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/groups/$groupId/members',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final data = response.data;
    if (data != null && data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => GroupMemberSummaryModel.fromJson(item))
          .toList();
    }
    return [];
  }

  @override
  Future<GroupJoinRequestsResult> getPendingJoinRequests(int groupId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/groups/$groupId/join-requests',
    );

    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return GroupJoinRequestsResult.fromJson(
        data['data'] as Map<String, dynamic>,
      );
    }
    return GroupJoinRequestsResult(
      groupId: groupId,
      totalRequests: 0,
      requests: const [],
    );
  }

  @override
  Future<void> reviewJoinRequest(
    int requestId, {
    required bool approved,
    bool includePastFundCollections = false,
  }) async {
    final payload = <String, dynamic>{
      'approved': approved,
    };
    if (approved) {
      payload['includePastFundCollections'] = includePastFundCollections;
    }

    await _apiClient.post<Map<String, dynamic>>(
      '/groups/join-requests/$requestId/review',
      data: payload,
    );
  }

  @override
  Future<GroupMemberDetailModel> getMemberDetails(
    int groupId,
    int targetUserId,
  ) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/groups/$groupId/members/$targetUserId',
    );

    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return GroupMemberDetailModel.fromJson(
        data['data'] as Map<String, dynamic>,
      );
    }
    throw StateError('Không tìm thấy thông tin thành viên.');
  }

  @override
  Future<void> removeMember(int groupId, int targetUserId) async {
    await _apiClient.delete<Map<String, dynamic>>(
      '/groups/$groupId/members/$targetUserId',
    );
  }

  @override
  Future<void> leaveGroup(int groupId) async {
    await _apiClient.post<Map<String, dynamic>>('/groups/$groupId/leave');
  }

  @override
  Future<void> transferOwnership(int groupId, int newOwnerId) async {
    await _apiClient.post<Map<String, dynamic>>(
      '/groups/$groupId/transfer-ownership',
      data: {'newOwnerId': newOwnerId},
    );
  }
}
