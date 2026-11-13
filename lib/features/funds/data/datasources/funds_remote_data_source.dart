import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/fund_enums.dart';
import '../models/fund_models.dart';

abstract class FundsRemoteDataSource {
  Future<GroupFundsOverviewModel> getGroupFundsOverview(
    int groupId, {
    String? search,
    FundTimeFilter? timeFilter,
    FundCollectionStatus? status,
  });

  Future<FundCollectionModel> createFundCollection(
    int groupId,
    CreateFundCollectionRequest request,
  );

  Future<FundCollectionModel> updateFundCollection(
    int fundId,
    UpdateFundCollectionRequest request,
  );

  Future<void> deleteFundCollection(int fundId);

  Future<FundCollectionModel> getFundCollectionDetails(int fundId);

  Future<FundCollectionModel> markMemberPaid(int fundId, int targetUserId);

  Future<void> sendFundReminder(int fundId);

  Future<List<int>> exportFundCsv(int fundId);
}

class FundsRemoteDataSourceImpl implements FundsRemoteDataSource {
  final ApiClient _apiClient;

  FundsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<GroupFundsOverviewModel> getGroupFundsOverview(
    int groupId, {
    String? search,
    FundTimeFilter? timeFilter,
    FundCollectionStatus? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (timeFilter != null && timeFilter != FundTimeFilter.all) {
      queryParams['timeFilter'] = timeFilter.value;
    }
    if (status != null) {
      queryParams['status'] = status.value;
    }

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/groups/$groupId/funds',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return GroupFundsOverviewModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw StateError('Dữ liệu tổng quan quỹ nhóm không hợp lệ.');
  }

  @override
  Future<FundCollectionModel> createFundCollection(
    int groupId,
    CreateFundCollectionRequest request,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/groups/$groupId/funds',
      data: request.toJson(),
    );

    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return FundCollectionModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw StateError('Không thể tạo đợt đóng quỹ mới.');
  }

  @override
  Future<FundCollectionModel> updateFundCollection(
    int fundId,
    UpdateFundCollectionRequest request,
  ) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/funds/$fundId',
      data: request.toJson(),
    );

    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return FundCollectionModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw StateError('Không thể cập nhật đợt đóng quỹ.');
  }

  @override
  Future<void> deleteFundCollection(int fundId) async {
    await _apiClient.delete<Map<String, dynamic>>('/funds/$fundId');
  }

  @override
  Future<FundCollectionModel> getFundCollectionDetails(int fundId) async {
    final response = await _apiClient.get<Map<String, dynamic>>('/funds/$fundId');

    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return FundCollectionModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw StateError('Không thể lấy thông tin chi tiết đợt đóng quỹ.');
  }

  @override
  Future<FundCollectionModel> markMemberPaid(int fundId, int targetUserId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/funds/$fundId/members/$targetUserId/paid',
    );

    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return FundCollectionModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw StateError('Không thể cập nhật trạng thái đóng quỹ.');
  }

  @override
  Future<void> sendFundReminder(int fundId) async {
    await _apiClient.post<Map<String, dynamic>>('/funds/$fundId/remind');
  }

  @override
  Future<List<int>> exportFundCsv(int fundId) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/funds/$fundId/export-csv',
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );

    if (response.data != null) {
      if (response.data is List<int>) {
        return response.data as List<int>;
      } else {
        return List<int>.from(response.data!);
      }
    }
    throw StateError('Không thể tải file báo cáo CSV.');
  }
}
