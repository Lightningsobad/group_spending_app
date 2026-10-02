import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/session/session_coordinator.dart';
import '../../../../core/sync/data_sync_coordinator.dart';
import '../../data/models/expense_enums.dart';
import '../../domain/repositories/expenses_repository.dart';
import 'expenses_state.dart';

class ExpensesCubit extends Cubit<ExpensesState> {
  final ExpensesRepository _repository;
  final SessionCoordinator? sessionCoordinator;
  final DataSyncCoordinator? dataSyncCoordinator;
  Timer? _searchDebounce;

  ExpensesCubit(
    this._repository, {
    this.sessionCoordinator,
    this.dataSyncCoordinator,
  }) : super(const ExpensesState()) {
    dataSyncCoordinator?.addListener(_onDataSync);
  }

  void _onDataSync() {
    final scope = dataSyncCoordinator?.lastScope;
    if (scope == DataSyncScope.expenses || scope == DataSyncScope.all) {
      if (state.activeGroupId != null) {
        loadGroupExpenses(state.activeGroupId!, silent: true);
      }
    }
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    dataSyncCoordinator?.removeListener(_onDataSync);
    return super.close();
  }

  Future<void> loadGroupExpenses(
    int groupId, {
    bool silent = false,
  }) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    if (!silent) {
      emit(state.copyWith(
        status: ExpensesStatus.loading,
        activeGroupId: groupId,
        clearMessages: true,
      ));
    } else {
      emit(state.copyWith(activeGroupId: groupId));
    }

    try {
      final data = await _repository.getGroupExpenses(
        groupId,
        timeFilter: state.timeFilter,
        payerFilter: state.payerFilter,
        categoryFilter: state.categoryFilter,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );

      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }

      emit(state.copyWith(
        status: ExpensesStatus.success,
        expensesData: data,
        clearMessages: !silent,
      ));
    } on AppException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: ExpensesStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: ExpensesStatus.failure,
        errorMessage: 'Không thể tải danh sách chi tiêu: $e',
      ));
    }
  }

  void setTimeFilter(ExpenseTimeFilter filter) {
    if (state.timeFilter == filter) return;
    emit(state.copyWith(timeFilter: filter));
    if (state.activeGroupId != null) {
      loadGroupExpenses(state.activeGroupId!);
    }
  }

  void setCategoryFilter(ExpenseCategoryFilter filter) {
    if (state.categoryFilter == filter) return;
    emit(state.copyWith(categoryFilter: filter));
    if (state.activeGroupId != null) {
      loadGroupExpenses(state.activeGroupId!);
    }
  }

  void setPayerFilter(ExpensePayerFilter filter) {
    if (state.payerFilter == filter) return;
    emit(state.copyWith(payerFilter: filter));
    if (state.activeGroupId != null) {
      loadGroupExpenses(state.activeGroupId!);
    }
  }

  void onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (isClosed) return;
      emit(state.copyWith(searchQuery: query.trim()));
      if (state.activeGroupId != null) {
        loadGroupExpenses(state.activeGroupId!, silent: true);
      }
    });
  }

  Future<bool> deleteExpense(int expenseId, int groupId) async {
    try {
      await _repository.deleteExpense(expenseId);
      dataSyncCoordinator?.notifyDataChanged(DataSyncScope.all);
      emit(state.copyWith(
        successMessage: 'Xóa khoản chi thành công',
      ));
      return true;
    } on AppException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
      return false;
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Lỗi khi xóa khoản chi: $e'));
      return false;
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }
}
