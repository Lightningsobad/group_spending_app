import '../../data/models/expense_enums.dart';
import '../../data/models/expense_models.dart';

enum ExpensesStatus { initial, loading, success, failure }

class ExpensesState {
  final ExpensesStatus status;
  final GroupExpensesResponseModel? expensesData;
  final ExpenseTimeFilter timeFilter;
  final ExpenseCategoryFilter categoryFilter;
  final ExpensePayerFilter payerFilter;
  final String searchQuery;
  final String? errorMessage;
  final String? successMessage;
  final int? activeGroupId;

  const ExpensesState({
    this.status = ExpensesStatus.initial,
    this.expensesData,
    this.timeFilter = ExpenseTimeFilter.all,
    this.categoryFilter = ExpenseCategoryFilter.all,
    this.payerFilter = ExpensePayerFilter.all,
    this.searchQuery = '',
    this.errorMessage,
    this.successMessage,
    this.activeGroupId,
  });

  bool get isLoading => status == ExpensesStatus.loading;

  num get totalSpendingVnd => expensesData?.totalSpendingVnd ?? 0;
  int get expenseCount => expensesData?.expenseCount ?? 0;
  List<ExpenseListItemModel> get expenses => expensesData?.expenses ?? const [];

  ExpensesState copyWith({
    ExpensesStatus? status,
    GroupExpensesResponseModel? expensesData,
    bool clearExpensesData = false,
    ExpenseTimeFilter? timeFilter,
    ExpenseCategoryFilter? categoryFilter,
    ExpensePayerFilter? payerFilter,
    String? searchQuery,
    String? errorMessage,
    String? successMessage,
    int? activeGroupId,
    bool clearActiveGroupId = false,
    bool clearMessages = false,
  }) {
    return ExpensesState(
      status: status ?? this.status,
      expensesData: clearExpensesData ? null : (expensesData ?? this.expensesData),
      timeFilter: timeFilter ?? this.timeFilter,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      payerFilter: payerFilter ?? this.payerFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
      activeGroupId: clearActiveGroupId ? null : (activeGroupId ?? this.activeGroupId),
    );
  }
}
