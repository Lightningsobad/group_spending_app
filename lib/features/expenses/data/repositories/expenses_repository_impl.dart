import 'dart:io';
import '../../../../core/errors/app_exception.dart';
import '../../domain/repositories/expenses_repository.dart';
import '../datasources/expenses_remote_data_source.dart';
import '../models/expense_enums.dart';
import '../models/expense_models.dart';

class ExpensesRepositoryImpl implements ExpensesRepository {
  final ExpensesRemoteDataSource remoteDataSource;

  ExpensesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<GroupExpensesResponseModel> getGroupExpenses(
    int groupId, {
    ExpenseTimeFilter? timeFilter,
    ExpensePayerFilter? payerFilter,
    ExpenseCategoryFilter? categoryFilter,
    String? search,
  }) async {
    try {
      return await remoteDataSource.getGroupExpenses(
        groupId,
        timeFilter: timeFilter,
        payerFilter: payerFilter,
        categoryFilter: categoryFilter,
        search: search,
      );
    } on AppException catch (e) {
      throw _mapAppException(e);
    }
  }

  @override
  Future<ExpenseDetailModel> createExpense(
    int groupId,
    CreateExpenseRequest request, {
    File? receiptFile,
  }) async {
    try {
      return await remoteDataSource.createExpense(
        groupId,
        request,
        receiptFile: receiptFile,
      );
    } on AppException catch (e) {
      throw _mapAppException(e);
    }
  }

  @override
  Future<ExpenseDetailModel> updateExpense(
    int expenseId,
    UpdateExpenseRequest request, {
    File? receiptFile,
  }) async {
    try {
      return await remoteDataSource.updateExpense(
        expenseId,
        request,
        receiptFile: receiptFile,
      );
    } on AppException catch (e) {
      throw _mapAppException(e);
    }
  }

  @override
  Future<void> deleteExpense(int expenseId) async {
    try {
      await remoteDataSource.deleteExpense(expenseId);
    } on AppException catch (e) {
      throw _mapAppException(e);
    }
  }

  @override
  Future<ExpenseDetailModel> getExpenseDetail(int expenseId) async {
    try {
      return await remoteDataSource.getExpenseDetail(expenseId);
    } on AppException catch (e) {
      throw _mapAppException(e);
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      return await remoteDataSource.getCategories();
    } on AppException catch (e) {
      throw _mapAppException(e);
    }
  }

  AppException _mapAppException(AppException error) {
    final code = error.errorCode?.toUpperCase() ?? '';
    final message = error.message;

    if (code == 'EXPENSE_LIMIT_EXCEEDED' || message.contains('1.000.000k') || message.contains('1 tỷ')) {
      return AppException(
        message: 'Số tiền chi tiêu tối đa cho một khoản là 1 tỷ VNĐ. Vui lòng kiểm tra lại.',
        errorCode: code,
        statusCode: error.statusCode,
      );
    }
    if (code == 'MONTHLY_EXPENSE_LIMIT_EXCEEDED' || message.contains('5.000')) {
      return AppException(
        message: 'Nhóm đã vượt hạn mức 5.000 khoản chi trong tháng này để đảm bảo an toàn hệ thống.',
        errorCode: code,
        statusCode: error.statusCode,
      );
    }
    if (code == 'INVALID_EXPENSE_SPLIT') {
      return AppException(
        message: 'Tổng tiền chia cho các thành viên chưa bằng tổng tiền khoản chi.',
        errorCode: code,
        statusCode: error.statusCode,
      );
    }
    if (code == 'GROUP_ARCHIVED' || message.contains('lưu trữ')) {
      return AppException(
        message: 'Nhóm này đã được lưu trữ, không thể chỉnh sửa chi tiêu.',
        errorCode: code,
        statusCode: error.statusCode,
      );
    }
    if (code == 'UNAUTHORIZED' || error.statusCode == 403) {
      return AppException(
        message: 'Chỉ người tạo khoản chi hoặc Admin nhóm mới có quyền thao tác.',
        errorCode: code,
        statusCode: error.statusCode,
      );
    }
    if (code == 'EXPENSE_NOT_FOUND' || (error.statusCode == 404 && message.contains('khoản chi'))) {
      return AppException(
        message: 'Khoản chi không tồn tại hoặc đã bị xóa.',
        errorCode: code,
        statusCode: error.statusCode,
      );
    }

    return error;
  }
}
