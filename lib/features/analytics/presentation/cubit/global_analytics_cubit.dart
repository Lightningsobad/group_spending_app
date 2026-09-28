import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/session/session_coordinator.dart';
import '../../../../core/sync/data_sync_coordinator.dart';
import '../../domain/entities/analytics_enums.dart';
import '../../domain/repositories/analytics_repository.dart';
import 'global_analytics_state.dart';

class GlobalAnalyticsCubit extends Cubit<GlobalAnalyticsState> {
  final AnalyticsRepository analyticsRepository;
  final SessionCoordinator? sessionCoordinator;
  final DataSyncCoordinator? dataSyncCoordinator;

  int _requestId = 0;

  GlobalAnalyticsCubit({
    required this.analyticsRepository,
    this.sessionCoordinator,
    this.dataSyncCoordinator,
  }) : super(const GlobalAnalyticsState()) {
    dataSyncCoordinator?.addListener(_onDataSync);
  }

  void _onDataSync() {
    if (!isClosed) {
      loadAnalytics(isRefresh: true);
    }
  }

  void setPeriod(StatisticsPeriod period, {int? year}) {
    if (state.period == period && state.year == year) return;
    emit(state.copyWith(period: period, year: year));
    loadAnalytics();
  }

  Future<void> loadAnalytics({bool isRefresh = false}) async {
    final currentRequestId = ++_requestId;
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;

    if (isRefresh) {
      emit(state.copyWith(isRefreshing: true, clearError: true));
    } else {
      emit(state.copyWith(status: GlobalAnalyticsStatus.loading, clearError: true));
    }

    try {
      final period = state.period;
      final year = state.year;

      final results = await Future.wait([
        analyticsRepository.getPersonalDetails(period: period, year: year),
        analyticsRepository.getGlobalLeaderboard(period: period, year: year),
        analyticsRepository.getExpenseHistory(
          timeFilter: _mapPeriodToHistoryTimeFilter(period),
        ),
      ]);

      if (isClosed ||
          currentRequestId != _requestId ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }

      final details = results[0];
      final leaderboard = results[1];
      final recentExpenses = results[2];

      emit(
        state.copyWith(
          status: GlobalAnalyticsStatus.success,
          details: details as dynamic,
          leaderboard: leaderboard as dynamic,
          recentExpenses: recentExpenses as dynamic,
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
          status: GlobalAnalyticsStatus.failure,
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
          status: GlobalAnalyticsStatus.failure,
          errorMessage: e.toString(),
          isRefreshing: false,
        ),
      );
    }
  }

  ExpenseTimeFilter _mapPeriodToHistoryTimeFilter(StatisticsPeriod period) {
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

  @override
  Future<void> close() {
    dataSyncCoordinator?.removeListener(_onDataSync);
    return super.close();
  }
}
