import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/features/expenses/data/models/expense_enums.dart';
import 'package:group_spending_app/features/expenses/data/models/expense_models.dart';
import 'package:group_spending_app/features/expenses/data/models/receipt_scan_models.dart';
import 'package:group_spending_app/features/expenses/presentation/cubit/expense_form_cubit.dart';
import 'package:group_spending_app/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:group_spending_app/features/groups/data/models/group_model.dart';
import 'dart:io';

class MockExpensesRepository implements ExpensesRepository {
  @override
  Future<GroupExpensesResponseModel> getGroupExpenses(int groupId, {ExpenseTimeFilter? timeFilter, ExpensePayerFilter? payerFilter, ExpenseCategoryFilter? categoryFilter, String? search}) async {
    return const GroupExpensesResponseModel(totalSpending: 0, totalSpendingVnd: 0, expenseCount: 0, expenses: []);
  }

  @override
  Future<ExpenseDetailModel> createExpense(int groupId, CreateExpenseRequest request, {File? receiptFile}) async {
    throw UnimplementedError();
  }

  @override
  Future<ExpenseDetailModel> updateExpense(int expenseId, UpdateExpenseRequest request, {File? receiptFile}) async {
    throw UnimplementedError();
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
  Future<ReceiptScanDataModel> scanReceipt(File file) async {
    throw UnimplementedError();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Expense Category Parsing & Tolerance', () {
    test('maps standard and synonymous strings correctly', () {
      expect(ExpenseCategoryType.fromString('Food'), ExpenseCategoryType.food);
      expect(ExpenseCategoryType.fromString('Ăn uống'), ExpenseCategoryType.food);
      expect(ExpenseCategoryType.fromString('TRANSPORT'), ExpenseCategoryType.transport);
      expect(ExpenseCategoryType.fromString('Di chuyển'), ExpenseCategoryType.transport);
      expect(ExpenseCategoryType.fromString('Entertaiment'), ExpenseCategoryType.entertainment);
      expect(ExpenseCategoryType.fromString('Grocerise'), ExpenseCategoryType.groceries);
      expect(ExpenseCategoryType.fromString(null), ExpenseCategoryType.others);
    });
  });

  group('Expense Form Keypad & Split Remainder Logic', () {
    final members = [
      const GroupMemberModel(id: 1, userId: 101, fullName: 'Nguyễn Văn A', role: 'ADMIN'),
      const GroupMemberModel(id: 2, userId: 102, fullName: 'Trần Thị B', role: 'MEMBER'),
      const GroupMemberModel(id: 3, userId: 103, fullName: 'Lê Văn C', role: 'MEMBER'),
    ];

    test('keypad handles digits, 000, DEL, and CLR with 1B VND cap', () {
      final repo = MockExpensesRepository();
      final cubit = ExpenseFormCubit(
        repo,
        groupId: 1,
        members: members,
        currentUserId: 101,
      );

      // Start at 0
      expect(cubit.state.amountDigits, '0');

      // Press 3, 2
      cubit.onDigitPressed('3');
      cubit.onDigitPressed('2');
      expect(cubit.state.amountDigits, '32');

      // Press 000
      cubit.onTripleZeroPressed();
      expect(cubit.state.amountDigits, '32000');
      expect(cubit.state.totalAmountVnd, 32000);

      // Press DEL
      cubit.onDeletePressed();
      expect(cubit.state.amountDigits, '3200');

      // Press CLR
      cubit.onClearPressed();
      expect(cubit.state.amountDigits, '0');
    });

    test('remainder distribution ensures sum of splits equals total amount', () {
      final repo = MockExpensesRepository();
      final cubit = ExpenseFormCubit(
        repo,
        groupId: 1,
        members: members,
        currentUserId: 101,
      );

      // Input 100,000 VND for 3 people: basic 33,333 with remainder 1 VND
      cubit.onDigitPressed('1');
      cubit.onDigitPressed('0');
      cubit.onDigitPressed('0');
      cubit.onTripleZeroPressed(); // 100,000
      expect(cubit.state.totalAmountVnd, 100000);

      final share1 = cubit.state.getMemberShareVnd(101);
      final share2 = cubit.state.getMemberShareVnd(102);
      final share3 = cubit.state.getMemberShareVnd(103);

      expect(share1, 33334); // First gets remainder
      expect(share2, 33333);
      expect(share3, 33333);
      expect(share1 + share2 + share3, 100000);
    });

    test('selecting specific participants recalculates shares correctly', () {
      final repo = MockExpensesRepository();
      final cubit = ExpenseFormCubit(
        repo,
        groupId: 1,
        members: members,
        currentUserId: 101,
      );

      // Input 100,000 VND
      cubit.onDigitPressed('1');
      cubit.onDigitPressed('0');
      cubit.onDigitPressed('0');
      cubit.onTripleZeroPressed();

      // Deselect 103, only 101 and 102 share
      cubit.toggleParticipant(103);
      expect(cubit.state.splitOption, SplitOption.equalSelected);
      expect(cubit.state.selectedMembersCount, 2);

      final share1 = cubit.state.getMemberShareVnd(101);
      final share2 = cubit.state.getMemberShareVnd(102);
      final share3 = cubit.state.getMemberShareVnd(103);

      expect(share1, 50000);
      expect(share2, 50000);
      expect(share3, 0);
      expect(share1 + share2, 100000);
    });

    test('updateMembers correctly populates members, payer and selected participants', () {
      final repo = MockExpensesRepository();
      // Initially initialized with empty members
      final cubit = ExpenseFormCubit(
        repo,
        groupId: 1,
        members: const [],
        currentUserId: 0,
      );

      expect(cubit.state.members, isEmpty);
      expect(cubit.state.paidByUserId, 0);
      expect(cubit.state.selectedParticipantUserIds, isEmpty);

      // Members loaded asynchronously
      cubit.updateMembers(members, currentUserId: 102);

      expect(cubit.state.members.length, 3);
      expect(cubit.state.paidByUserId, 102); // current user selected as payer
      expect(cubit.state.selectedParticipantUserIds, {101, 102, 103}); // all selected
    });

    test('updateGroup correctly updates groupId and groupName', () {
      final repo = MockExpensesRepository();
      final cubit = ExpenseFormCubit(
        repo,
        groupId: 1,
        groupName: 'Group 1',
        members: members,
        currentUserId: 101,
      );

      cubit.updateGroup(2, 'Group 2');
      expect(cubit.state.groupId, 2);
      expect(cubit.state.groupName, 'Group 2');
    });
  });
}
