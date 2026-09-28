import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/session/session_coordinator.dart';
import '../../../../core/sync/data_sync_coordinator.dart';
import '../../domain/entities/analytics_enums.dart';
import '../../domain/repositories/analytics_repository.dart';
import 'group_analytics_state.dart';

class GroupAnalyticsCubit extends Cubit<GroupAnalyticsState> {
  final int groupId;
  final AnalyticsRepository analyticsRepository;
  final SessionCoordinator? sessionCoordinator;
  final DataSyncCoordinator? dataSyncCoordinator;

  int _requestId = 0;

  GroupAnalyticsCubit({
    required this.groupId,
    required this.analyticsRepository,
    this.sessionCoordinator,
    this.dataSyncCoordinator,
  }) : super(GroupAnalyticsState(groupId: groupId)) {
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

      final results = await Future.wait([
        analyticsRepository.getGroupStatistics(groupId, period: period, year: year),
        analyticsRepository.getGroupLeaderboard(groupId, period: period, year: year),
      ]);

      if (isClosed ||
          currentRequestId != _requestId ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }

      final groupStats = results[0];
      final leaderboard = results[1];

      emit(
        state.copyWith(
          status: GroupAnalyticsStatus.success,
          groupStatistics: groupStats as dynamic,
          leaderboard: leaderboard as dynamic,
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
