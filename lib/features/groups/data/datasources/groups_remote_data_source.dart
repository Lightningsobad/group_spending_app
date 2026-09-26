import '../../../../core/network/api_client.dart';
import '../models/group_model.dart';

abstract class GroupsRemoteDataSource {
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

class GroupsRemoteDataSourceImpl implements GroupsRemoteDataSource {
  final ApiClient _apiClient;

  GroupsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<GroupModel>> getMyGroups({String? filter, String? search}) async {
    final queryParams = <String, dynamic>{};
    if (filter != null && filter.isNotEmpty && filter != 'ALL') {
      queryParams['filter'] = filter;
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
}
