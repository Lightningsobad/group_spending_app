import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/errors/app_exception.dart';
import 'package:group_spending_app/features/expenses/data/models/expense_enums.dart';
import 'package:group_spending_app/features/expenses/data/models/expense_models.dart';
import 'package:group_spending_app/features/expenses/data/models/receipt_scan_models.dart';
import 'package:group_spending_app/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:group_spending_app/features/expenses/presentation/cubit/expense_form_cubit.dart';
import 'package:group_spending_app/features/groups/data/models/group_model.dart';

class MockExpensesRepository implements ExpensesRepository {
  ReceiptScanDataModel? scanResultToReturn;
  Exception? scanErrorToThrow;
  CreateExpenseRequest? lastCreateRequest;
  File? lastCreateReceiptFile;
  UpdateExpenseRequest? lastUpdateRequest;
  File? lastUpdateReceiptFile;

  @override
  Future<ReceiptScanDataModel> scanReceipt(File file) async {
    if (scanErrorToThrow != null) throw scanErrorToThrow!;
    if (scanResultToReturn != null) return scanResultToReturn!;
    throw const AppException(message: 'No scan result configured');
  }

  @override
  Future<ExpenseDetailModel> createExpense(
    int groupId,
    CreateExpenseRequest request, {
    File? receiptFile,
  }) async {
    lastCreateRequest = request;
    lastCreateReceiptFile = receiptFile;
    return ExpenseDetailModel(
      id: 99,
      groupId: groupId,
      title: request.title,
      totalAmount: request.totalAmount,
      totalAmountVnd: request.totalAmount * 1000,
      paidByUserId: request.paidByUserId,
      paidByUserName: 'Nguyễn Văn A',
      status: 'ACTIVE',
      createdByUserId: 1,
      categoryName: request.category,
      receiptUrl: request.receiptUrl,
      splits: const [],
    );
  }

  @override
  Future<ExpenseDetailModel> updateExpense(
    int expenseId,
    UpdateExpenseRequest request, {
    File? receiptFile,
  }) async {
    lastUpdateRequest = request;
    lastUpdateReceiptFile = receiptFile;
    return ExpenseDetailModel(
      id: expenseId,
      groupId: 1,
      title: request.title,
      totalAmount: request.totalAmount,
      totalAmountVnd: request.totalAmount * 1000,
      paidByUserId: request.paidByUserId,
      paidByUserName: 'Nguyễn Văn A',
      status: 'ACTIVE',
      createdByUserId: 1,
      categoryName: request.category,
      receiptUrl: request.receiptUrl,
      splits: const [],
    );
  }

  @override
  Future<void> deleteExpense(int expenseId) async {}

  @override
  Future<ExpenseDetailModel> getExpenseDetail(int expenseId) async {
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getCategories() async => [];

  @override
  Future<GroupExpensesResponseModel> getGroupExpenses(
    int groupId, {
    ExpenseTimeFilter? timeFilter,
    ExpensePayerFilter? payerFilter,
    ExpenseCategoryFilter? categoryFilter,
    String? search,
  }) async {
    return const GroupExpensesResponseModel(
      totalSpending: 0,
      totalSpendingVnd: 0,
      expenseCount: 0,
      expenses: [],
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final members = [
    const GroupMemberModel(id: 1, userId: 101, fullName: 'Nguyễn Văn A', role: 'ADMIN'),
    const GroupMemberModel(id: 2, userId: 102, fullName: 'Trần Thị B', role: 'MEMBER'),
  ];

  group('ExpenseFormCubit - Receipt Scanning & Auto-fill', () {
    test('scanAndPrefillReceipt pre-fills all fields accurately on success', () async {
      final repo = MockExpensesRepository();
      repo.scanResultToReturn = const ReceiptScanDataModel(
        merchantName: 'Highlands Coffee',
        suggestedTitle: 'Ăn uống Highlands Coffee',
        totalAmount: 155,
        totalAmountVnd: 154500,
        category: 'Food',
        expenseDate: '2026-10-09',
        confidence: 'HIGH',
        generatedNotes: '[Highlands Coffee]\n- 2x Trà sen vàng: 110.000đ',
        receiptUrl: 'https://res.cloudinary.com/demo/receipt.jpg',
      );

      final cubit = ExpenseFormCubit(
        repo,
        groupId: 1,
        members: members,
        currentUserId: 101,
      );

      final dummyFile = File('dummy_receipt.jpg');
      final result = await cubit.scanAndPrefillReceipt(dummyFile);

      expect(result, isNotNull);
      expect(cubit.state.isScanningReceipt, false);
      expect(cubit.state.amountDigits, '154500');
      expect(cubit.state.totalAmountVnd, 154500);
      expect(cubit.state.title, 'Ăn uống Highlands Coffee');
      expect(cubit.state.notes, contains('Trà sen vàng'));
      expect(cubit.state.category, ExpenseCategoryType.food);
      expect(cubit.state.expenseDate, '2026-10-09');
      expect(cubit.state.receiptUrl, 'https://res.cloudinary.com/demo/receipt.jpg');
      expect(cubit.state.scanConfidence, 'HIGH');
      expect(cubit.state.receiptFile, dummyFile);
    });

    test('scanAndPrefillReceipt handles low confidence without wiping existing data', () async {
      final repo = MockExpensesRepository();
      repo.scanResultToReturn = const ReceiptScanDataModel(
        merchantName: null,
        suggestedTitle: null,
        totalAmount: null,
        totalAmountVnd: null,
        category: 'Others',
        confidence: 'LOW',
        receiptUrl: 'https://res.cloudinary.com/demo/blurred.jpg',
      );

      final cubit = ExpenseFormCubit(
        repo,
        groupId: 1,
        members: members,
        currentUserId: 101,
      );

      cubit.setTitle('Đã gõ trước');
      final dummyFile = File('dummy_blurred.jpg');
      final result = await cubit.scanAndPrefillReceipt(dummyFile);

      expect(result, isNotNull);
      expect(result!.isLowConfidence, true);
      expect(cubit.state.title, 'Đã gõ trước'); // Untouched
      expect(cubit.state.amountDigits, '0'); // Untouched
      expect(cubit.state.receiptUrl, 'https://res.cloudinary.com/demo/blurred.jpg');
      expect(cubit.state.scanConfidence, 'LOW');
    });

    test('scanAndPrefillReceipt emits errorMessage on scan failure', () async {
      final repo = MockExpensesRepository();
      repo.scanErrorToThrow = const AppException(
        message: 'Không thể nhận diện nội dung hóa đơn',
        errorCode: 'RECEIPT_OCR_FAILED',
      );

      final cubit = ExpenseFormCubit(
        repo,
        groupId: 1,
        members: members,
        currentUserId: 101,
      );

      final dummyFile = File('bad_receipt.jpg');
      final result = await cubit.scanAndPrefillReceipt(dummyFile);

      expect(result, isNull);
      expect(cubit.state.isScanningReceipt, false);
      expect(cubit.state.errorMessage, 'Không thể nhận diện nội dung hóa đơn');
      expect(cubit.state.receiptFile, dummyFile); // File preserved
    });

    test('submitExpense passes receiptUrl in request and sets receiptFile null if receiptUrl present', () async {
      final repo = MockExpensesRepository();
      final cubit = ExpenseFormCubit(
        repo,
        groupId: 1,
        members: members,
        currentUserId: 101,
      );

      cubit.setTitle('Ăn uống Highlands Coffee');
      cubit.onDigitPressed('1');
      cubit.onDigitPressed('5');
      cubit.onDigitPressed('0');
      cubit.onTripleZeroPressed(); // 150.000 VNĐ
      cubit.setReceiptFile(File('local_path.jpg'));
      cubit.setReceiptUrl('https://res.cloudinary.com/demo/receipt.jpg');
      cubit.setExpenseDate('2026-10-09');

      final success = await cubit.submitExpense();
      expect(success, true);
      expect(repo.lastCreateRequest, isNotNull);
      expect(repo.lastCreateRequest!.title, 'Ăn uống Highlands Coffee');
      expect(repo.lastCreateRequest!.receiptUrl, 'https://res.cloudinary.com/demo/receipt.jpg');
      expect(repo.lastCreateRequest!.expenseDate, '2026-10-09');
      // Should NOT re-upload file when receiptUrl is already present
      expect(repo.lastCreateReceiptFile, isNull);
    });

    test('removeReceipt clears both receiptFile and receiptUrl', () {
      final repo = MockExpensesRepository();
      final cubit = ExpenseFormCubit(
        repo,
        groupId: 1,
        members: members,
        currentUserId: 101,
      );

      cubit.setReceiptFile(File('local.jpg'));
      cubit.setReceiptUrl('https://url.com');
      expect(cubit.state.receiptFile, isNotNull);
      expect(cubit.state.receiptUrl, isNotNull);

      cubit.removeReceipt();
      expect(cubit.state.receiptFile, isNull);
      expect(cubit.state.receiptUrl, isNull);
    });

    test('EXP-03: removeReceipt in edit mode sets removeReceipt=true and passes to UpdateExpenseRequest', () async {
      final repo = MockExpensesRepository();
      const expenseToEdit = ExpenseDetailModel(
        id: 77,
        groupId: 1,
        title: 'Bữa trưa',
        totalAmount: 120,
        totalAmountVnd: 120000,
        paidByUserId: 101,
        paidByUserName: 'Alice',
        status: 'ACTIVE',
        createdByUserId: 101,
        categoryName: 'Food',
        receiptUrl: 'https://cloudinary.com/bill.jpg',
        splits: [
          ExpenseSplitModel(id: 1, userId: 101, fullName: 'Alice', amountOwed: 60, amountOwedVnd: 60000),
          ExpenseSplitModel(id: 2, userId: 102, fullName: 'Bob', amountOwed: 60, amountOwedVnd: 60000),
        ],
      );

      final cubit = ExpenseFormCubit(
        repo,
        groupId: 1,
        members: members,
        currentUserId: 101,
        expenseToEdit: expenseToEdit,
      );

      expect(cubit.state.receiptUrl, 'https://cloudinary.com/bill.jpg');
      expect(cubit.state.removeReceipt, false);

      // User removes receipt
      cubit.removeReceipt();
      expect(cubit.state.receiptUrl, isNull);
      expect(cubit.state.removeReceipt, true);

      final success = await cubit.submitExpense();
      expect(success, true);
      expect(repo.lastUpdateRequest, isNotNull);
      expect(repo.lastUpdateRequest!.removeReceipt, true);
      expect(repo.lastUpdateRequest!.receiptUrl, isNull);
      expect(repo.lastUpdateReceiptFile, isNull);
    });

    test('EXP-03: picking a new file after removeReceipt resets removeReceipt to false', () {
      final repo = MockExpensesRepository();
      const expenseToEdit = ExpenseDetailModel(
        id: 77,
        groupId: 1,
        title: 'Bữa trưa',
        totalAmount: 120,
        totalAmountVnd: 120000,
        paidByUserId: 101,
        paidByUserName: 'Alice',
        status: 'ACTIVE',
        createdByUserId: 101,
        categoryName: 'Food',
        receiptUrl: 'https://cloudinary.com/bill.jpg',
        splits: [],
      );

      final cubit = ExpenseFormCubit(
        repo,
        groupId: 1,
        members: members,
        currentUserId: 101,
        expenseToEdit: expenseToEdit,
      );

      cubit.removeReceipt();
      expect(cubit.state.removeReceipt, true);

      cubit.setReceiptFile(File('new_receipt.jpg'));
      expect(cubit.state.removeReceipt, false);
      expect(cubit.state.receiptFile, isNotNull);
    });

    test('EXP-04: submitExpense is blocked when isScanningReceipt is true', () async {
      final repo = MockExpensesRepository();
      final cubit = ExpenseFormCubit(
        repo,
        groupId: 1,
        members: members,
        currentUserId: 101,
      );
      cubit.setTitle('Test Expense');
      cubit.onDigitPressed('5');
      cubit.onTripleZeroPressed();

      // Simulate scanning in progress
      cubit.emit(cubit.state.copyWith(isScanningReceipt: true));
      expect(cubit.state.canSubmit, false);

      final success = await cubit.submitExpense();
      expect(success, false);
      expect(repo.lastCreateRequest, isNull);
    });

    test('EXP-04: submitExpense is blocked when members is empty', () async {
      final repo = MockExpensesRepository();
      final cubit = ExpenseFormCubit(
        repo,
        groupId: 1,
        members: const [],
        currentUserId: 101,
      );
      cubit.setTitle('Test Expense');
      cubit.onDigitPressed('5');
      cubit.onTripleZeroPressed();

      final success = await cubit.submitExpense();
      expect(success, false);
      expect(cubit.state.errorMessage, contains('Đang tải danh sách thành viên'));
      expect(repo.lastCreateRequest, isNull);
    });
  });
}
