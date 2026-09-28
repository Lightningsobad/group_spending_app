import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/session/session_coordinator.dart';
import '../../../../core/sync/data_sync_coordinator.dart';
import '../../domain/entities/debt_enums.dart';
import '../../domain/repositories/debts_repository.dart';
import 'debts_state.dart';

class DebtsCubit extends Cubit<DebtsState> {
  final DebtsRepository _repository;
  final SessionCoordinator? sessionCoordinator;
  final DataSyncCoordinator? dataSyncCoordinator;

  DebtsCubit(
    this._repository, {
    this.sessionCoordinator,
    this.dataSyncCoordinator,
  }) : super(const DebtsState()) {
    dataSyncCoordinator?.addListener(_onDataSync);
  }

  void _onDataSync() {
    final scope = dataSyncCoordinator?.lastScope;
    if (scope == DataSyncScope.debts || scope == DataSyncScope.all) {
      loadOverview(silent: true);
      if (state.selectedGroupId != null) {
        loadGroupDebts(state.selectedGroupId!, silent: true);
      }
    }
  }

  @override
  Future<void> close() {
    dataSyncCoordinator?.removeListener(_onDataSync);
    return super.close();
  }

  void reset() {
    emit(const DebtsState());
  }

  Future<void> loadOverview({bool silent = false}) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    if (!silent) {
      emit(state.copyWith(status: DebtsStatus.loading, clearMessages: true));
    }

    try {
      final overview = await _repository.getDebtOverview();
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }
      emit(
        state.copyWith(
          status: DebtsStatus.success,
          overview: overview,
          clearMessages: !silent,
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
          status: DebtsStatus.failure,
          errorMessage: e.message,
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
          status: DebtsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void selectGroup(int? groupId, {String? groupName}) {
    if (groupId == null) {
      emit(state.copyWith(clearSelectedGroup: true));
      return;
    }

    emit(
      state.copyWith(
        selectedGroupId: groupId,
        selectedGroupName: groupName,
        isDetailLoading: true,
        clearMessages: true,
      ),
    );
    loadGroupDebts(groupId);
  }

  Future<void> loadGroupDebts(int groupId, {bool silent = false}) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    if (!silent) {
      emit(state.copyWith(isDetailLoading: true, clearMessages: true));
    }

    try {
      final simplified = await _repository.getGroupSimplifiedDebts(groupId);
      final actual = await _repository.getGroupActualDebts(
        groupId,
        status: state.actualDebtStatusFilter,
      );

      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }

      emit(
        state.copyWith(
          isDetailLoading: false,
          simplifiedDebts: simplified,
          actualDebts: actual,
          clearMessages: !silent,
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
          isDetailLoading: false,
          errorMessage: e.message,
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
          isDetailLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void setDetailTab(int tabIndex) {
    emit(state.copyWith(activeDetailTab: tabIndex));
  }

  void setFilter(DebtOverviewFilter filter) {
    emit(state.copyWith(activeFilter: filter));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<void> setActualDebtStatusFilter(String? status) async {
    emit(state.copyWith(actualDebtStatusFilter: status));
    if (state.selectedGroupId != null) {
      await loadGroupDebts(state.selectedGroupId!, silent: true);
    }
  }

  Future<bool> markDebtAsPaid(int debtId) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    emit(state.copyWith(isActionSubmitting: true, clearMessages: true));

    try {
      await _repository.markDebtAsPaid(debtId);
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }

      emit(
        state.copyWith(
          isActionSubmitting: false,
          successMessage: 'Đã gửi yêu cầu xác nhận trả nợ!',
        ),
      );

      dataSyncCoordinator?.notifyDataChanged(DataSyncScope.debts);
      if (state.selectedGroupId != null) {
        await loadGroupDebts(state.selectedGroupId!, silent: true);
      }
      await loadOverview(silent: true);
      return true;
    } on AppException catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionSubmitting: false,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionSubmitting: false,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  Future<bool> confirmDebtSettled(
    int debtId, {
    required bool confirmed,
  }) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    emit(state.copyWith(isActionSubmitting: true, clearMessages: true));

    try {
      await _repository.confirmDebtSettled(debtId, confirmed: confirmed);
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }

      emit(
        state.copyWith(
          isActionSubmitting: false,
          successMessage: confirmed
              ? 'Đã xác nhận nhận tiền thành công!'
              : 'Đã từ chối xác nhận nhận tiền.',
        ),
      );

      dataSyncCoordinator?.notifyDataChanged(DataSyncScope.debts);
      if (state.selectedGroupId != null) {
        await loadGroupDebts(state.selectedGroupId!, silent: true);
      }
      await loadOverview(silent: true);
      return true;
    } on AppException catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionSubmitting: false,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionSubmitting: false,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  Future<bool> sendDebtReminder(int debtId) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    emit(state.copyWith(isActionSubmitting: true, clearMessages: true));

    try {
      await _repository.sendDebtReminder(debtId);
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }

      emit(
        state.copyWith(
          isActionSubmitting: false,
          successMessage: 'Đã gửi thông báo nhắc nợ thành công!',
        ),
      );
      return true;
    } on AppException catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionSubmitting: false,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionSubmitting: false,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }
}
