import '../../domain/entities/analytics_enums.dart';
import '../../domain/entities/expense_history_entity.dart';
import '../../domain/entities/expense_statistics_entity.dart';
import '../../domain/entities/leaderboard_entity.dart';

enum GlobalAnalyticsStatus { initial, loading, success, failure }

class GlobalAnalyticsState {
  final GlobalAnalyticsStatus status;
  final bool isRefreshing;
  final StatisticsPeriod period;
  final int? year;
  final ExpenseStatisticsEntity details;
  final List<LeaderboardMemberEntity> leaderboard;
  final List<ExpenseHistoryItemEntity> recentExpenses;
  final String? errorMessage;

  const GlobalAnalyticsState({
    this.status = GlobalAnalyticsStatus.initial,
    this.isRefreshing = false,
    this.period = StatisticsPeriod.thisMonth,
    this.year,
    this.details = const ExpenseStatisticsEntity.empty(),
    this.leaderboard = const [],
    this.recentExpenses = const [],
    this.errorMessage,
  });

  bool get isLoading => status == GlobalAnalyticsStatus.loading;
  bool get isSuccess => status == GlobalAnalyticsStatus.success;
  bool get isFailure => status == GlobalAnalyticsStatus.failure;

  GlobalAnalyticsState copyWith({
    GlobalAnalyticsStatus? status,
    bool? isRefreshing,
    StatisticsPeriod? period,
    int? year,
    ExpenseStatisticsEntity? details,
    List<LeaderboardMemberEntity>? leaderboard,
    List<ExpenseHistoryItemEntity>? recentExpenses,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GlobalAnalyticsState(
      status: status ?? this.status,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      period: period ?? this.period,
      year: year ?? this.year,
      details: details ?? this.details,
      leaderboard: leaderboard ?? this.leaderboard,
      recentExpenses: recentExpenses ?? this.recentExpenses,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
