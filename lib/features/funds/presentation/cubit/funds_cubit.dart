import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/session/session_coordinator.dart';
import '../../../../core/sync/data_sync_coordinator.dart';
import '../../domain/entities/fund_enums.dart';
import '../../domain/repositories/funds_repository.dart';
import 'funds_state.dart';

class FundsCubit extends Cubit<FundsState> {
  final FundsRepository _repository;
  final SessionCoordinator? sessionCoordinator;
  final DataSyncCoordinator? dataSyncCoordinator;

  Timer? _searchDebounceTimer;
  int _requestId = 0;

  FundsCubit(
    this._repository, {
    this.sessionCoordinator,
    this.dataSyncCoordinator,
  }) : super(const FundsState()) {
    dataSyncCoordinator?.addListener(_onDataSync);
  }

  void _onDataSync() {
    final scope = dataSyncCoordinator?.lastScope;
    if (scope == DataSyncScope.funds ||
        scope == DataSyncScope.groups ||
        scope == DataSyncScope.all) {
      if (state.currentGroupId != null) {
        loadGroupFunds(state.currentGroupId!, silent: true);
      }
    }
  }

  @override
  Future<void> close() {
    _requestId++;
    _searchDebounceTimer?.cancel();
    dataSyncCoordinator?.removeListener(_onDataSync);
    return super.close();
  }

  void reset() {
    _requestId++;
    _searchDebounceTimer?.cancel();
    emit(const FundsState());
  }

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }

  Future<void> loadGroupFunds(
    int groupId, {
    bool silent = false,
  }) async {
    final currentReqId = ++_requestId;
    final isDifferentGroup = state.currentGroupId != groupId;
    if (isDifferentGroup) {
      _searchDebounceTimer?.cancel();
    }
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    final capturedGroupId = groupId;

    if (!silent) {
      emit(
        state.copyWith(
          status: FundsStatus.loading,
          currentGroupId: groupId,
          clearOverview: isDifferentGroup,
          clearMessages: true,
          searchQuery: isDifferentGroup ? '' : state.searchQuery,
          clearStatusFilter: isDifferentGroup,
          selectedTimeFilter: isDifferentGroup ? FundTimeFilter.all : state.selectedTimeFilter,
        ),
      );
    } else {
      if (isDifferentGroup) {
        emit(
          state.copyWith(
            currentGroupId: groupId,
            clearOverview: true,
            searchQuery: '',
            clearStatusFilter: true,
            selectedTimeFilter: FundTimeFilter.all,
          ),
        );
      } else {
        emit(state.copyWith(currentGroupId: groupId));
      }
    }

    try {
      final effectiveSearch = isDifferentGroup ? null : (state.searchQuery.trim().isNotEmpty ? state.searchQuery : null);
      final effectiveTime = isDifferentGroup ? FundTimeFilter.all : state.selectedTimeFilter;
      final effectiveStatus = isDifferentGroup ? null : state.selectedStatusFilter;

      final overview = await _repository.getGroupFundsOverview(
        groupId,
        search: effectiveSearch,
        timeFilter: effectiveTime,
        status: effectiveStatus,
      );

      if (isClosed ||
          currentReqId != _requestId ||
          state.currentGroupId != capturedGroupId ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }

      emit(
        state.copyWith(
          status: FundsStatus.success,
          overview: overview,
          clearMessages: !silent,
        ),
      );
    } on AppException catch (e) {
      if (isClosed ||
          currentReqId != _requestId ||
          state.currentGroupId != capturedGroupId ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }
      emit(
        state.copyWith(
          status: FundsStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      if (isClosed ||
          currentReqId != _requestId ||
          state.currentGroupId != capturedGroupId ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }
      emit(
        state.copyWith(
          status: FundsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void setSearchQuery(String query) {
    if (query == state.searchQuery) return;

    emit(state.copyWith(searchQuery: query));

    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (state.currentGroupId != null && !isClosed) {
        loadGroupFunds(state.currentGroupId!, silent: true);
      }
    });
  }

  void setStatusFilter(FundCollectionStatus? status) {
    if (status == state.selectedStatusFilter) return;

    if (status == null) {
      emit(state.copyWith(clearStatusFilter: true));
    } else {
      emit(state.copyWith(selectedStatusFilter: status));
    }

    if (state.currentGroupId != null) {
      loadGroupFunds(state.currentGroupId!, silent: true);
    }
  }

  void setTimeFilter(FundTimeFilter filter) {
    if (filter == state.selectedTimeFilter) return;

    emit(state.copyWith(selectedTimeFilter: filter));

    if (state.currentGroupId != null) {
      loadGroupFunds(state.currentGroupId!, silent: true);
    }
  }
}
