import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/errors/app_exception.dart';
import 'package:group_spending_app/core/session/session_coordinator.dart';
import 'package:group_spending_app/core/storage/token_storage.dart';
import 'package:group_spending_app/features/expenses/data/models/expense_enums.dart';
import 'package:group_spending_app/features/expenses/data/models/expense_models.dart';
import 'package:group_spending_app/features/expenses/data/models/receipt_scan_models.dart';
import 'package:group_spending_app/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:group_spending_app/features/expenses/presentation/cubit/expenses_cubit.dart';
import 'package:group_spending_app/features/expenses/presentation/cubit/expenses_state.dart';

class ControllableExpensesRepository implements ExpensesRepository {
  final Map<int, Completer<GroupExpensesResponseModel>> completers = {};

  void completeRequest(int groupId, GroupExpensesResponseModel data) {
    completers[groupId]?.complete(data);
  }

  void failRequest(int groupId, Exception error) {
    completers[groupId]?.completeError(error);
  }

  @override
  Future<GroupExpensesResponseModel> getGroupExpenses(
    int groupId, {
    ExpenseTimeFilter? timeFilter,
    ExpensePayerFilter? payerFilter,
    ExpenseCategoryFilter? categoryFilter,
    String? search,
  }) {
    final completer = Completer<GroupExpensesResponseModel>();
    completers[groupId] = completer;
    return completer.future;
  }

  @override
  Future<ExpenseDetailModel> createExpense(int groupId, CreateExpenseRequest request, {File? receiptFile}) {
    throw UnimplementedError();
  }

  @override
  Future<ExpenseDetailModel> updateExpense(int expenseId, UpdateExpenseRequest request, {File? receiptFile}) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteExpense(int expenseId) async {}

  @override
  Future<List<String>> getCategories() async => [];

  @override
  Future<ExpenseDetailModel> getExpenseDetail(int expenseId) {
    throw UnimplementedError();
  }

  @override
  Future<ReceiptScanDataModel> scanReceipt(File file) {
    throw UnimplementedError();
  }
}

class FakeSessionCoordinator extends ChangeNotifier implements SessionCoordinator {
  int _epoch = 1;

  @override
  int get sessionEpoch => _epoch;

  @override
  bool get isAuthenticated => true;

  @override
  SessionStatus get status => SessionStatus.authenticated;

  @override
  TokenStorage get tokenStorage => throw UnimplementedError();

  void bumpEpoch() {
    _epoch++;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ExpensesCubit - EXP-02 Stale Responses & Race Condition', () {
    late ControllableExpensesRepository repository;
    late FakeSessionCoordinator sessionCoordinator;
    late ExpensesCubit cubit;

    final dataGroupA = GroupExpensesResponseModel(
      totalSpending: 100,
      totalSpendingVnd: 100000,
      expenseCount: 1,
      expenses: [
        const ExpenseListItemModel(
          id: 1,
          title: 'Chi tiêu Nhóm A',
          amount: 100,
          amountVnd: 100000,
          paidBy: 'A',
          paidByUserId: 1,
          status: 'PAID_BY_ME',
          myAmountOwed: 0,
          myAmountOwedVnd: 0,
          categoryName: 'Food',
        ),
      ],
    );

    final dataGroupB = GroupExpensesResponseModel(
      totalSpending: 200,
      totalSpendingVnd: 200000,
      expenseCount: 1,
      expenses: [
        const ExpenseListItemModel(
          id: 2,
          title: 'Chi tiêu Nhóm B',
          amount: 200,
          amountVnd: 200000,
          paidBy: 'B',
          paidByUserId: 2,
          status: 'PAID_BY_ME',
          myAmountOwed: 0,
          myAmountOwedVnd: 0,
          categoryName: 'Transport',
        ),
      ],
    );

    setUp(() {
      repository = ControllableExpensesRepository();
      sessionCoordinator = FakeSessionCoordinator();
      cubit = ExpensesCubit(repository, sessionCoordinator: sessionCoordinator);
    });

    tearDown(() {
      cubit.close();
    });

    test('stale response from Group A does not overwrite newer Group B data', () async {
      // 1. User loads Group 10 (A)
      final futureA = cubit.loadGroupExpenses(10);
      expect(cubit.state.status, ExpensesStatus.loading);
      expect(cubit.state.activeGroupId, 10);

      // 2. User quickly switches to Group 20 (B) before Group A finishes
      final futureB = cubit.loadGroupExpenses(20);
      expect(cubit.state.activeGroupId, 20);

      // 3. Group B finishes first
      repository.completeRequest(20, dataGroupB);
      await futureB;

      expect(cubit.state.status, ExpensesStatus.success);
      expect(cubit.state.activeGroupId, 20);
      expect(cubit.state.expenses.first.title, 'Chi tiêu Nhóm B');

      // 4. Group A finishes later
      repository.completeRequest(10, dataGroupA);
      await futureA;

      // Group A must be discarded, state remains Group B
      expect(cubit.state.status, ExpensesStatus.success);
      expect(cubit.state.activeGroupId, 20);
      expect(cubit.state.expenses.first.title, 'Chi tiêu Nhóm B');
    });

    test('stale error from old request does not overwrite fresh success state', () async {
      final futureA = cubit.loadGroupExpenses(10);
      final futureB = cubit.loadGroupExpenses(20);

      // Group B succeeds
      repository.completeRequest(20, dataGroupB);
      await futureB;
      expect(cubit.state.status, ExpensesStatus.success);

      // Group A fails
      repository.failRequest(10, const AppException(message: 'Lỗi mạng nhóm A'));
      await futureA;

      // Must NOT become failure
      expect(cubit.state.status, ExpensesStatus.success);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.activeGroupId, 20);
    });

    test('clearActiveGroup clears activeGroupId to null and discards in-flight request', () async {
      final future = cubit.loadGroupExpenses(10);
      expect(cubit.state.activeGroupId, 10);

      cubit.clearActiveGroup();
      expect(cubit.state.activeGroupId, isNull);
      expect(cubit.state.status, ExpensesStatus.initial);

      // In-flight request finishes
      repository.completeRequest(10, dataGroupA);
      await future;

      // Remains null and initial
      expect(cubit.state.activeGroupId, isNull);
      expect(cubit.state.expensesData, isNull);
      expect(cubit.state.status, ExpensesStatus.initial);
    });

    test('sessionEpoch bump invalidates in-flight requests', () async {
      final future = cubit.loadGroupExpenses(10);
      expect(cubit.state.status, ExpensesStatus.loading);

      // Session changes (e.g. logout / account switch)
      sessionCoordinator.bumpEpoch();

      repository.completeRequest(10, dataGroupA);
      await future;

      // Ignored because request epoch changed
      expect(cubit.state.status, ExpensesStatus.loading);
      expect(cubit.state.expensesData, isNull);
    });
  });
}
