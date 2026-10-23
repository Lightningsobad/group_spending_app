import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/session/session_coordinator.dart';
import '../../../../core/sync/data_sync_coordinator.dart';
import '../../../groups/data/models/group_summary_model.dart';
import '../../../groups/domain/repositories/groups_repository.dart';
import '../../domain/repositories/analytics_repository.dart';
import 'analytics_tab_state.dart';

class AnalyticsTabCubit extends Cubit<AnalyticsTabState> {
  final AnalyticsRepository analyticsRepository;
  final GroupsRepository groupsRepository;
  final SessionCoordinator? sessionCoordinator;
  final DataSyncCoordinator? dataSyncCoordinator;

  AnalyticsTabCubit({
    required this.analyticsRepository,
    required this.groupsRepository,
    this.sessionCoordinator,
    this.dataSyncCoordinator,
  }) : super(const AnalyticsTabState()) {
    dataSyncCoordinator?.addListener(_onDataSync);
  }

  void _onDataSync() {
    if (!isClosed) {
      loadOverview(isRefresh: true);
    }
  }

  void reset() {
    emit(const AnalyticsTabState());
  }

  Future<void> setFilter(String filter) async {
    if (state.filter == filter) return;
    emit(state.copyWith(filter: filter));

    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    try {
      final statusParam = filter == 'ALL' ? null : filter;
      final groups = await groupsRepository.getGroupSummaries(status: statusParam);

      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }

      emit(
        state.copyWith(
          groups: groups,
          totalAllCount: filter == 'ALL' ? groups.length : state.totalAllCount,
        ),
      );
    } catch (_) {
      // Keep existing groups if network filter fails
    }
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<void> loadOverview({bool isRefresh = false}) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;

    if (isRefresh) {
      emit(state.copyWith(isRefreshing: true, clearError: true));
    } else if (state.status != AnalyticsTabStatus.success) {
      emit(state.copyWith(status: AnalyticsTabStatus.loading, clearError: true));
    }

    try {
      final statusParam = state.filter == 'ALL' ? null : state.filter;
      final results = await Future.wait([
        analyticsRepository.getPersonalOverview(),
        groupsRepository.getGroupSummaries(status: statusParam),
      ]);

      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }

      final overview = results[0];
      final groups = results[1] as List<GroupSummaryModel>;

      emit(
        state.copyWith(
          status: AnalyticsTabStatus.success,
          overview: overview as dynamic,
          groups: groups,
          totalAllCount: state.filter == 'ALL' ? groups.length : state.totalAllCount,
          isRefreshing: false,
          clearError: true,
        ),
      );
    } on AppException catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }
      emit(
        state.copyWith(
          status: AnalyticsTabStatus.failure,
          errorMessage: e.message,
          isRefreshing: false,
        ),
      );
    } catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }
      emit(
        state.copyWith(
          status: AnalyticsTabStatus.failure,
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
