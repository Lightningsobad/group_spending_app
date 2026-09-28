import '../entities/analytics_enums.dart';
import '../entities/expense_history_entity.dart';
import '../entities/expense_statistics_entity.dart';
import '../entities/leaderboard_entity.dart';
import '../entities/personal_overview_entity.dart';

abstract class AnalyticsRepository {
  Future<PersonalOverviewEntity> getPersonalOverview();

  Future<ExpenseStatisticsEntity> getPersonalDetails({
    StatisticsPeriod period = StatisticsPeriod.thisMonth,
    int? year,
  });

  Future<List<LeaderboardMemberEntity>> getGlobalLeaderboard({
    StatisticsPeriod period = StatisticsPeriod.thisMonth,
    int? year,
  });

  Future<ExpenseStatisticsEntity> getGroupStatistics(
    int groupId, {
    StatisticsPeriod period = StatisticsPeriod.thisMonth,
    int? year,
  });

  Future<List<LeaderboardMemberEntity>> getGroupLeaderboard(
    int groupId, {
    StatisticsPeriod period = StatisticsPeriod.thisMonth,
    int? year,
  });

  Future<List<ExpenseHistoryItemEntity>> getExpenseHistory({
    ExpenseTimeFilter timeFilter = ExpenseTimeFilter.all,
  });
}
