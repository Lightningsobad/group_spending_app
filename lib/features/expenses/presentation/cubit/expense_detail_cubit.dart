import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/sync/data_sync_coordinator.dart';
import '../../domain/repositories/expenses_repository.dart';
import 'expense_detail_state.dart';

class ExpenseDetailCubit extends Cubit<ExpenseDetailState> {
  final ExpensesRepository _repository;
  final DataSyncCoordinator? dataSyncCoordinator;

  ExpenseDetailCubit(
    this._repository, {
    this.dataSyncCoordinator,
  }) : super(const ExpenseDetailState());

  Future<void> loadExpenseDetail(int expenseId) async {
    emit(state.copyWith(status: ExpenseDetailStatus.loading, clearMessages: true));
    try {
      final expense = await _repository.getExpenseDetail(expenseId);
      if (isClosed) return;
      emit(state.copyWith(
        status: ExpenseDetailStatus.success,
        expense: expense,
      ));
    } on AppException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: ExpenseDetailStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: ExpenseDetailStatus.failure,
        errorMessage: 'Lỗi tải chi tiết: $e',
      ));
    }
  }

  Future<bool> deleteExpense() async {
    final expense = state.expense;
    if (expense == null) return false;

    emit(state.copyWith(isDeleting: true, clearMessages: true));
    try {
      await _repository.deleteExpense(expense.id);
      dataSyncCoordinator?.notifyDataChanged(DataSyncScope.all);
      if (isClosed) return true;
      emit(state.copyWith(
        isDeleting: false,
        deleteSuccess: true,
        successMessage: 'Xóa khoản chi thành công',
      ));
      return true;
    } on AppException catch (e) {
      if (isClosed) return false;
      emit(state.copyWith(
        isDeleting: false,
        errorMessage: e.message,
      ));
      return false;
    } catch (e) {
      if (isClosed) return false;
      emit(state.copyWith(
        isDeleting: false,
        errorMessage: 'Lỗi khi xóa: $e',
      ));
      return false;
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }
}
