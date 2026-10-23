import '../../domain/entities/analytics_enums.dart';
import '../../domain/entities/expense_history_entity.dart';
import '../../domain/entities/expense_statistics_entity.dart';
import '../../domain/entities/leaderboard_entity.dart';

enum GroupAnalyticsStatus { initial, loading, success, failure }

class GroupAnalyticsState {
  final int groupId;
  final GroupAnalyticsStatus status;
  final bool isRefreshing;
  final StatisticsPeriod period;
  final int? year;
  final ExpenseStatisticsEntity groupStatistics;
  final List<LeaderboardMemberEntity> leaderboard;
  final List<ExpenseHistoryItemEntity> recentExpenses;
  final String? groupName;
  final String? groupCategory;
  final int? memberCount;
  final String? errorMessage;

  const GroupAnalyticsState({
    required this.groupId,
    this.status = GroupAnalyticsStatus.initial,
    this.isRefreshing = false,
    this.period = StatisticsPeriod.thisMonth,
    this.year,
    this.groupStatistics = const ExpenseStatisticsEntity.empty(),
    this.leaderboard = const [],
    this.recentExpenses = const [],
    this.groupName,
    this.groupCategory,
    this.memberCount,
    this.errorMessage,
  });

  bool get isLoading => status == GroupAnalyticsStatus.loading;
  bool get isSuccess => status == GroupAnalyticsStatus.success;
  bool get isFailure => status == GroupAnalyticsStatus.failure;

  GroupAnalyticsState copyWith({
    int? groupId,
    GroupAnalyticsStatus? status,
    bool? isRefreshing,
    StatisticsPeriod? period,
    int? year,
    ExpenseStatisticsEntity? groupStatistics,
    List<LeaderboardMemberEntity>? leaderboard,
    List<ExpenseHistoryItemEntity>? recentExpenses,
    String? groupName,
    String? groupCategory,
    int? memberCount,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GroupAnalyticsState(
      groupId: groupId ?? this.groupId,
      status: status ?? this.status,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      period: period ?? this.period,
      year: year ?? this.year,
      groupStatistics: groupStatistics ?? this.groupStatistics,
      leaderboard: leaderboard ?? this.leaderboard,
      recentExpenses: recentExpenses ?? this.recentExpenses,
      groupName: groupName ?? this.groupName,
      groupCategory: groupCategory ?? this.groupCategory,
      memberCount: memberCount ?? this.memberCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
