import '../../domain/entities/analytics_enums.dart';
import '../../domain/entities/expense_history_entity.dart';
import '../../domain/entities/expense_statistics_entity.dart';
import '../../domain/entities/leaderboard_entity.dart';
import '../../domain/entities/personal_overview_entity.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_data_source.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PersonalOverviewEntity> getPersonalOverview() async {
    final model = await remoteDataSource.getPersonalOverview();
    return model.toEntity();
  }

  @override
  Future<ExpenseStatisticsEntity> getPersonalDetails({
    StatisticsPeriod period = StatisticsPeriod.thisMonth,
    int? year,
  }) async {
    final model = await remoteDataSource.getPersonalDetails(
      period: period,
      year: year,
    );
    return model.toEntity();
  }

  @override
  Future<List<LeaderboardMemberEntity>> getGlobalLeaderboard({
    StatisticsPeriod period = StatisticsPeriod.thisMonth,
    int? year,
  }) async {
    final models = await remoteDataSource.getGlobalLeaderboard(
      period: period,
      year: year,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ExpenseStatisticsEntity> getGroupStatistics(
    int groupId, {
    StatisticsPeriod period = StatisticsPeriod.thisMonth,
    int? year,
  }) async {
    final model = await remoteDataSource.getGroupStatistics(
      groupId,
      period: period,
      year: year,
    );
    return model.toEntity();
  }

  @override
  Future<List<LeaderboardMemberEntity>> getGroupLeaderboard(
    int groupId, {
    StatisticsPeriod period = StatisticsPeriod.thisMonth,
    int? year,
  }) async {
    final models = await remoteDataSource.getGroupLeaderboard(
      groupId,
      period: period,
      year: year,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ExpenseHistoryItemEntity>> getExpenseHistory({
    ExpenseTimeFilter timeFilter = ExpenseTimeFilter.all,
  }) async {
    final models = await remoteDataSource.getExpenseHistory(
      timeFilter: timeFilter,
    );
    return models.map((m) => m.toEntity()).toList();
  }
}
