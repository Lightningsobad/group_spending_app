import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/session/session_coordinator.dart';
import '../../../../core/sync/data_sync_coordinator.dart';
import '../../../debts/domain/repositories/debts_repository.dart';
import '../../../groups/domain/repositories/groups_repository.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DebtsRepository debtsRepository;
  final GroupsRepository groupsRepository;
  final SessionCoordinator? sessionCoordinator;
  final DataSyncCoordinator? dataSyncCoordinator;

  DashboardCubit({
    required this.debtsRepository,
    required this.groupsRepository,
    this.sessionCoordinator,
    this.dataSyncCoordinator,
  }) : super(const DashboardState()) {
    dataSyncCoordinator?.addListener(_onDataSync);
  }

  void _onDataSync() {
    if (!isClosed) {
      loadDashboard(isRefresh: true);
    }
  }

  void reset() {
    emit(const DashboardState());
  }

  Future<void> loadDashboard({bool isRefresh = false}) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;

    if (isRefresh) {
      emit(state.copyWith(isRefreshing: true, clearError: true));
    } else if (state.status != DashboardStatus.success) {
      emit(state.copyWith(status: DashboardStatus.loading, clearError: true));
    }

    try {
      final results = await Future.wait([
        debtsRepository.getDebtOverview(),
        groupsRepository.getMyGroups(filter: 'ALL'),
      ]);

      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }

      final debtOverview = results[0];
      final groups = results[1];

      emit(
        state.copyWith(
          status: DashboardStatus.success,
          debtOverview: debtOverview as dynamic,
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
          status: DashboardStatus.failure,
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
          status: DashboardStatus.failure,
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
