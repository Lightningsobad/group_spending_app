import '../../data/models/expense_models.dart';

enum ExpenseDetailStatus { initial, loading, success, failure }

class ExpenseDetailState {
  final ExpenseDetailStatus status;
  final ExpenseDetailModel? expense;
  final bool isDeleting;
  final bool deleteSuccess;
  final String? errorMessage;
  final String? successMessage;

  const ExpenseDetailState({
    this.status = ExpenseDetailStatus.initial,
    this.expense,
    this.isDeleting = false,
    this.deleteSuccess = false,
    this.errorMessage,
    this.successMessage,
  });

  ExpenseDetailState copyWith({
    ExpenseDetailStatus? status,
    ExpenseDetailModel? expense,
    bool? isDeleting,
    bool? deleteSuccess,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return ExpenseDetailState(
      status: status ?? this.status,
      expense: expense ?? this.expense,
      isDeleting: isDeleting ?? this.isDeleting,
      deleteSuccess: deleteSuccess ?? this.deleteSuccess,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}
