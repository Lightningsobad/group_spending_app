import 'dart:io';
import '../../data/models/expense_enums.dart';
import '../../data/models/expense_models.dart';
import '../../data/models/receipt_scan_models.dart';

abstract class ExpensesRepository {
  Future<GroupExpensesResponseModel> getGroupExpenses(
    int groupId, {
    ExpenseTimeFilter? timeFilter,
    ExpensePayerFilter? payerFilter,
    ExpenseCategoryFilter? categoryFilter,
    String? search,
  });

  Future<ExpenseDetailModel> createExpense(
    int groupId,
    CreateExpenseRequest request, {
    File? receiptFile,
  });

  Future<ExpenseDetailModel> updateExpense(
    int expenseId,
    UpdateExpenseRequest request, {
    File? receiptFile,
  });

  Future<void> deleteExpense(int expenseId);

  Future<ExpenseDetailModel> getExpenseDetail(int expenseId);

  Future<List<String>> getCategories();

  Future<ReceiptScanDataModel> scanReceipt(File file);
}
