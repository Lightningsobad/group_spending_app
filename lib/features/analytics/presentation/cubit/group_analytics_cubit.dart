import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/session/session_coordinator.dart';
import '../../../../core/sync/data_sync_coordinator.dart';
import '../../../expenses/data/models/expense_enums.dart';
import '../../../expenses/data/models/expense_models.dart';
import '../../../expenses/domain/repositories/expenses_repository.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/domain/repositories/groups_repository.dart';
import '../../domain/entities/analytics_enums.dart' hide ExpenseTimeFilter;
import '../../domain/entities/expense_history_entity.dart';
import '../../domain/entities/expense_statistics_entity.dart';
import '../../domain/entities/leaderboard_entity.dart';
import '../../domain/repositories/analytics_repository.dart';
import 'group_analytics_state.dart';

class GroupAnalyticsCubit extends Cubit<GroupAnalyticsState> {
  final int groupId;
  final AnalyticsRepository analyticsRepository;
  final ExpensesRepository? expensesRepository;
  final GroupsRepository? groupsRepository;
  final SessionCoordinator? sessionCoordinator;
  final DataSyncCoordinator? dataSyncCoordinator;

  int _requestId = 0;

  GroupAnalyticsCubit({
    required this.groupId,
    required this.analyticsRepository,
    this.expensesRepository,
    this.groupsRepository,
    this.sessionCoordinator,
    this.dataSyncCoordinator,
    String? initialGroupName,
    String? initialGroupCategory,
    int? initialMemberCount,
  }) : super(
          GroupAnalyticsState(
            groupId: groupId,
            groupName: initialGroupName,
            groupCategory: initialGroupCategory,
            memberCount: initialMemberCount,
          ),
        ) {
    dataSyncCoordinator?.addListener(_onDataSync);
  }

  void _onDataSync() {
    if (!isClosed) {
      loadGroupAnalytics(isRefresh: true);
    }
  }

  void setPeriod(StatisticsPeriod period, {int? year}) {
    if (state.period == period && state.year == year) return;
    emit(state.copyWith(period: period, year: year));
    loadGroupAnalytics();
  }

  ExpenseTimeFilter _mapPeriodToExpenseTimeFilter(StatisticsPeriod period) {
    switch (period) {
      case StatisticsPeriod.thisMonth:
        return ExpenseTimeFilter.thisMonth;
      case StatisticsPeriod.lastMonth:
        return ExpenseTimeFilter.lastMonth;
      case StatisticsPeriod.currentQuarter:
        return ExpenseTimeFilter.thisQuarter;
      case StatisticsPeriod.byYear:
        return ExpenseTimeFilter.thisYear;
    }
  }

  Future<void> loadGroupAnalytics({bool isRefresh = false}) async {
    final currentRequestId = ++_requestId;
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;

    if (isRefresh) {
      emit(state.copyWith(isRefreshing: true, clearError: true));
    } else {
      emit(state.copyWith(status: GroupAnalyticsStatus.loading, clearError: true));
    }

    try {
      final period = state.period;
      final year = state.year;

      final groupStatsFuture = analyticsRepository.getGroupStatistics(
        groupId,
        period: period,
        year: year,
      );
      final leaderboardFuture = analyticsRepository.getGroupLeaderboard(
        groupId,
        period: period,
        year: year,
      );
      final expensesFuture = expensesRepository?.getGroupExpenses(
        groupId,
        timeFilter: _mapPeriodToExpenseTimeFilter(period),
      );
      final groupDetailsFuture = (state.groupName == null || state.groupCategory == null || state.memberCount == null) &&
              groupsRepository != null
          ? groupsRepository!.getGroupDetails(groupId).then<GroupModel?>((g) => g).catchError((_) => null)
          : Future<GroupModel?>.value(null);

      final results = await Future.wait<dynamic>([
        groupStatsFuture,
        leaderboardFuture,
        if (expensesFuture != null) expensesFuture else Future.value(null),
        groupDetailsFuture,
      ]);

      if (isClosed ||
          currentRequestId != _requestId ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }

      final groupStats = results[0] as ExpenseStatisticsEntity;
      final leaderboard = results[1] as List<LeaderboardMemberEntity>;
      final expensesResponse = results[2] as GroupExpensesResponseModel?;
      final groupDetails = results[3] as GroupModel?;

      final resolvedGroupName = (groupStats.groupName != null && groupStats.groupName!.trim().isNotEmpty)
          ? groupStats.groupName
          : (state.groupName ?? groupDetails?.name);
      final resolvedCategory = state.groupCategory ?? groupDetails?.category;
      final resolvedMemberCount = state.memberCount ?? groupDetails?.memberCount;

      final recentExpenses = expensesResponse?.expenses.map((item) {
        return ExpenseHistoryItemEntity(
          id: item.id,
          groupId: groupId,
          groupName: resolvedGroupName ?? groupStats.groupName ?? state.groupStatistics.groupName ?? '',
          title: item.title,
          expenseDate: item.expenseDate ?? '',
          totalAmountVnd: item.amountVnd,
          categoryName: item.categoryName,
          paidByUserName: item.paidBy,
        );
      }).toList() ?? const [];

      emit(
        state.copyWith(
          status: GroupAnalyticsStatus.success,
          groupStatistics: groupStats,
          leaderboard: leaderboard,
          recentExpenses: recentExpenses,
          groupName: resolvedGroupName,
          groupCategory: resolvedCategory,
          memberCount: resolvedMemberCount,
          loadedPeriod: period,
          isRefreshing: false,
          clearError: true,
        ),
      );
    } on AppException catch (e) {
      if (isClosed ||
          currentRequestId != _requestId ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }
      emit(
        state.copyWith(
          status: GroupAnalyticsStatus.failure,
          errorMessage: e.message,
          isRefreshing: false,
        ),
      );
    } catch (e) {
      if (isClosed ||
          currentRequestId != _requestId ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }
      emit(
        state.copyWith(
          status: GroupAnalyticsStatus.failure,
          errorMessage: e.toString(),
          isRefreshing: false,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    dataSyncCoordinator?.removeListener(_onDataSync);
    return super.close();
  }
}
