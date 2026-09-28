import '../../../../core/network/api_client.dart';
import '../../domain/entities/analytics_enums.dart';
import '../models/expense_history_item_model.dart';
import '../models/expense_statistics_details_model.dart';
import '../models/leaderboard_member_model.dart';
import '../models/personal_overview_model.dart';

abstract class AnalyticsRemoteDataSource {
  Future<PersonalOverviewModel> getPersonalOverview();

  Future<ExpenseStatisticsDetailsModel> getPersonalDetails({
    StatisticsPeriod period = StatisticsPeriod.thisMonth,
    int? year,
  });

  Future<List<LeaderboardMemberModel>> getGlobalLeaderboard({
    StatisticsPeriod period = StatisticsPeriod.thisMonth,
    int? year,
  });

  Future<ExpenseStatisticsDetailsModel> getGroupStatistics(
    int groupId, {
    StatisticsPeriod period = StatisticsPeriod.thisMonth,
    int? year,
  });

  Future<List<LeaderboardMemberModel>> getGroupLeaderboard(
    int groupId, {
    StatisticsPeriod period = StatisticsPeriod.thisMonth,
    int? year,
  });

  Future<List<ExpenseHistoryItemModel>> getExpenseHistory({
    ExpenseTimeFilter timeFilter = ExpenseTimeFilter.all,
  });
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final ApiClient _apiClient;

  AnalyticsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<PersonalOverviewModel> getPersonalOverview() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/expenses/statistics/overview',
    );
    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return PersonalOverviewModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw StateError('Dữ liệu thống kê tổng quan không hợp lệ.');
  }

  @override
  Future<ExpenseStatisticsDetailsModel> getPersonalDetails({
    StatisticsPeriod period = StatisticsPeriod.thisMonth,
    int? year,
  }) async {
    final queryParams = <String, dynamic>{
      'period': period.key,
      if (period == StatisticsPeriod.byYear && year != null) 'year': year,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/expenses/statistics/details',
      queryParameters: queryParams,
    );
    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return ExpenseStatisticsDetailsModel.fromJson(
        data['data'] as Map<String, dynamic>,
      );
    }
    throw StateError('Dữ liệu phân tích chi tiêu cá nhân không hợp lệ.');
  }

  @override
  Future<List<LeaderboardMemberModel>> getGlobalLeaderboard({
    StatisticsPeriod period = StatisticsPeriod.thisMonth,
    int? year,
  }) async {
    final queryParams = <String, dynamic>{
      'period': period.key,
      if (period == StatisticsPeriod.byYear && year != null) 'year': year,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/expenses/statistics/leaderboard',
      queryParameters: queryParams,
    );
    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      final innerData = data['data'] as Map<String, dynamic>;
      if (innerData['leaderboard'] is List) {
        return (innerData['leaderboard'] as List)
            .whereType<Map<String, dynamic>>()
            .map((item) => LeaderboardMemberModel.fromJson(item))
            .toList();
      }
    }
    return [];
  }

  @override
  Future<ExpenseStatisticsDetailsModel> getGroupStatistics(
    int groupId, {
    StatisticsPeriod period = StatisticsPeriod.thisMonth,
    int? year,
  }) async {
    final queryParams = <String, dynamic>{
      'period': period.key,
      if (period == StatisticsPeriod.byYear && year != null) 'year': year,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/expenses/statistics/groups/$groupId',
      queryParameters: queryParams,
    );
    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return ExpenseStatisticsDetailsModel.fromJson(
        data['data'] as Map<String, dynamic>,
      );
    }
    throw StateError('Dữ liệu thống kê nhóm không hợp lệ.');
  }

  @override
  Future<List<LeaderboardMemberModel>> getGroupLeaderboard(
    int groupId, {
    StatisticsPeriod period = StatisticsPeriod.thisMonth,
    int? year,
  }) async {
    final queryParams = <String, dynamic>{
      'period': period.key,
      if (period == StatisticsPeriod.byYear && year != null) 'year': year,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/expenses/statistics/groups/$groupId/leaderboard',
      queryParameters: queryParams,
    );
    final data = response.data;
    if (data != null && data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => LeaderboardMemberModel.fromJson(item))
          .toList();
    }
    return [];
  }

  @override
  Future<List<ExpenseHistoryItemModel>> getExpenseHistory({
    ExpenseTimeFilter timeFilter = ExpenseTimeFilter.all,
  }) async {
    final queryParams = <String, dynamic>{
      if (timeFilter != ExpenseTimeFilter.all) 'timeFilter': timeFilter.key,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/expenses/history',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final data = response.data;
    if (data != null && data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => ExpenseHistoryItemModel.fromJson(item))
          .toList();
    }
    return [];
  }
}
