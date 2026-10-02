import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/expense_enums.dart';
import '../models/expense_models.dart';

abstract class ExpensesRemoteDataSource {
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
}

class ExpensesRemoteDataSourceImpl implements ExpensesRemoteDataSource {
  final ApiClient _apiClient;

  ExpensesRemoteDataSourceImpl(this._apiClient);

  @override
  Future<GroupExpensesResponseModel> getGroupExpenses(
    int groupId, {
    ExpenseTimeFilter? timeFilter,
    ExpensePayerFilter? payerFilter,
    ExpenseCategoryFilter? categoryFilter,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (timeFilter != null && timeFilter != ExpenseTimeFilter.all) {
      queryParams['timeFilter'] = timeFilter.key;
    }
    if (payerFilter != null && payerFilter != ExpensePayerFilter.all) {
      queryParams['payerFilter'] = payerFilter.key;
    }
    if (categoryFilter != null && categoryFilter != ExpenseCategoryFilter.all) {
      queryParams['categoryFilter'] = categoryFilter.key;
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/groups/$groupId/expenses',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return GroupExpensesResponseModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    return const GroupExpensesResponseModel(
      totalSpending: 0,
      totalSpendingVnd: 0,
      expenseCount: 0,
      expenses: [],
    );
  }

  @override
  Future<ExpenseDetailModel> createExpense(
    int groupId,
    CreateExpenseRequest request, {
    File? receiptFile,
  }) async {
    final formData = FormData();

    formData.files.add(
      MapEntry(
        'data',
        MultipartFile.fromString(
          jsonEncode(request.toJson()),
          contentType: DioMediaType('application', 'json'),
        ),
      ),
    );

    if (receiptFile != null && await receiptFile.exists()) {
      final fileName = receiptFile.path.split(Platform.pathSeparator).last;
      final ext = fileName.split('.').last.toLowerCase();
      final subType = (ext == 'png') ? 'png' : 'jpeg';

      formData.files.add(
        MapEntry(
          'receipt',
          await MultipartFile.fromFile(
            receiptFile.path,
            filename: fileName,
            contentType: DioMediaType('image', subType),
          ),
        ),
      );
    }

    final response = await _apiClient.post<Map<String, dynamic>>(
      '/groups/$groupId/expenses',
      data: formData,
    );

    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return ExpenseDetailModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception('Phản hồi không đúng định dạng');
  }

  @override
  Future<ExpenseDetailModel> updateExpense(
    int expenseId,
    UpdateExpenseRequest request, {
    File? receiptFile,
  }) async {
    final formData = FormData();

    formData.files.add(
      MapEntry(
        'data',
        MultipartFile.fromString(
          jsonEncode(request.toJson()),
          contentType: DioMediaType('application', 'json'),
        ),
      ),
    );

    if (receiptFile != null && await receiptFile.exists()) {
      final fileName = receiptFile.path.split(Platform.pathSeparator).last;
      final ext = fileName.split('.').last.toLowerCase();
      final subType = (ext == 'png') ? 'png' : 'jpeg';

      formData.files.add(
        MapEntry(
          'receipt',
          await MultipartFile.fromFile(
            receiptFile.path,
            filename: fileName,
            contentType: DioMediaType('image', subType),
          ),
        ),
      );
    }

    final response = await _apiClient.put<Map<String, dynamic>>(
      '/expenses/$expenseId',
      data: formData,
    );

    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return ExpenseDetailModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception('Phản hồi không đúng định dạng');
  }

  @override
  Future<void> deleteExpense(int expenseId) async {
    await _apiClient.delete<Map<String, dynamic>>('/expenses/$expenseId');
  }

  @override
  Future<ExpenseDetailModel> getExpenseDetail(int expenseId) async {
    final response = await _apiClient.get<Map<String, dynamic>>('/expenses/$expenseId');
    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return ExpenseDetailModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception('Không tìm thấy thông tin khoản chi');
  }

  @override
  Future<List<String>> getCategories() async {
    final response = await _apiClient.get<Map<String, dynamic>>('/expenses/categories');
    final data = response.data;
    if (data != null && data['data'] is List) {
      return (data['data'] as List).map((e) => e.toString()).toList();
    }
    return [];
  }
}
