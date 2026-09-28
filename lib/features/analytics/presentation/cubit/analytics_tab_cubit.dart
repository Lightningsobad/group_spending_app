import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/session/session_coordinator.dart';
import '../../../../core/sync/data_sync_coordinator.dart';
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

  void setFilter(String filter) {
    emit(state.copyWith(filter: filter));
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
      final results = await Future.wait([
        analyticsRepository.getPersonalOverview(),
        groupsRepository.getMyGroups(filter: 'ALL'),
      ]);

      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }

      final overview = results[0];
      final groups = results[1];

      emit(
        state.copyWith(
          status: AnalyticsTabStatus.success,
          overview: overview as dynamic,
          groups: groups as dynamic,
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
