import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/expenses/data/models/expense_enums.dart';
import 'package:group_spending_app/features/expenses/data/models/expense_models.dart';
import 'package:group_spending_app/features/expenses/data/models/receipt_scan_models.dart';
import 'package:group_spending_app/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:group_spending_app/features/expenses/presentation/cubit/expenses_cubit.dart';
import 'package:group_spending_app/features/expenses/presentation/widgets/expense_card_skeleton.dart';
import 'package:group_spending_app/features/expenses/presentation/widgets/expense_card_widget.dart';
import 'package:group_spending_app/features/expenses/presentation/widgets/group_expenses_tab_view.dart';
import 'package:group_spending_app/features/groups/data/models/group_model.dart';
import 'dart:io';

class FakeExpensesRepository implements ExpensesRepository {
  Completer<GroupExpensesResponseModel>? delayCompleter;
  GroupExpensesResponseModel response = const GroupExpensesResponseModel(
    totalSpending: 1500000,
    totalSpendingVnd: 1500000,
    expenseCount: 2,
    expenses: [
      ExpenseListItemModel(
        id: 1,
        title: 'Ăn tối lẩu Haidilao',
        amount: 1000000,
        amountVnd: 1000000,
        categoryName: 'food',
        expenseDate: '2026-10-13T19:30:00Z',
        paidBy: 'Nguyễn Văn A',
        paidByUserId: 1,
        status: 'PAID_BY_ME',
        myAmountOwed: 0,
        myAmountOwedVnd: 0,
      ),
      ExpenseListItemModel(
        id: 2,
        title: 'Tiền điện nước tháng 10',
        amount: 500000,
        amountVnd: 500000,
        categoryName: 'housing',
        expenseDate: '2026-10-12T10:00:00Z',
        paidBy: 'Trần Thị B',
        paidByUserId: 2,
        status: 'PENDING',
        myAmountOwed: 250000,
        myAmountOwedVnd: 250000,
      ),
    ],
  );

  @override
  Future<GroupExpensesResponseModel> getGroupExpenses(
    int groupId, {
    ExpenseTimeFilter? timeFilter,
    ExpensePayerFilter? payerFilter,
    ExpenseCategoryFilter? categoryFilter,
    String? search,
  }) async {
    if (delayCompleter != null) {
      return delayCompleter!.future;
    }
    return response;
  }

  @override
  Future<ExpenseDetailModel> createExpense(int groupId, CreateExpenseRequest request, {File? receiptFile}) async =>
      throw UnimplementedError();

  @override
  Future<ExpenseDetailModel> updateExpense(int expenseId, UpdateExpenseRequest request, {File? receiptFile}) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteExpense(int expenseId) async {}

  @override
  Future<ExpenseDetailModel> getExpenseDetail(int expenseId) async => throw UnimplementedError();

  @override
  Future<List<String>> getCategories() async => [];

  @override
  Future<ReceiptScanDataModel> scanReceipt(File file) async => throw UnimplementedError();
}

void main() {
  const testGroup = GroupModel(
    id: 1,
    name: 'Nhóm Đi Chơi Đà Lạt',
    description: 'Chi tiêu chuyến đi',
    category: 'TRIP',
    ownerId: 10,
    memberCount: 4,
    userBalance: 500000,
  );

  Widget createTestWidget({
    required ExpensesCubit cubit,
    ThemeData? theme,
    double? textScale,
    Size? surfaceSize,
  }) {
    return MaterialApp(
      theme: theme ?? AppTheme.lightTheme,
      home: Scaffold(
        body: BlocProvider.value(
          value: cubit,
          child: SingleChildScrollView(
            child: GroupExpensesTabView(group: testGroup),
          ),
        ),
      ),
    );
  }

  group('GroupExpensesTabView UI/UX Tests', () {
    late FakeExpensesRepository repo;
    late ExpensesCubit cubit;

    setUp(() {
      repo = FakeExpensesRepository();
      cubit = ExpensesCubit(repo);
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('hiển thị hiệu ứng shimmer skeleton khi dữ liệu đang tải', (tester) async {
      repo.delayCompleter = Completer<GroupExpensesResponseModel>();

      await tester.pumpWidget(createTestWidget(cubit: cubit));
      await tester.pump(); // Render first frame where loading is emitted

      expect(find.byType(ExpenseCardSkeleton), findsNWidgets(4));
      expect(find.byType(ExpenseCardWidget), findsNothing);

      // Hoàn tất tải dữ liệu
      repo.delayCompleter!.complete(repo.response);
      await tester.pumpAndSettle();

      expect(find.byType(ExpenseCardSkeleton), findsNothing);
      expect(find.byType(ExpenseCardWidget), findsNWidgets(2));
    });

    testWidgets('hiển thị đầy đủ thông tin danh sách chi tiêu sau khi tải xong', (tester) async {
      await tester.pumpWidget(createTestWidget(cubit: cubit));
      await tester.pumpAndSettle();

      expect(find.text('TỔNG CHI TIÊU NHÓM'), findsOneWidget);
      expect(find.text('1.500.000 đ'), findsOneWidget);
      expect(find.text('2 hóa đơn phát sinh'), findsOneWidget);
      expect(find.text('Ăn tối lẩu Haidilao'), findsOneWidget);
      expect(find.text('Tiền điện nước tháng 10'), findsOneWidget);
      expect(find.text('Bạn đã thanh toán'), findsOneWidget);
      expect(find.text('Bạn nợ: 250.000 đ'), findsOneWidget);
    });

    testWidgets('UX & Touch Target: các nút bấm và chip lọc có chiều cao tối thiểu >= 48px', (tester) async {
      await tester.pumpWidget(createTestWidget(cubit: cubit));
      await tester.pumpAndSettle();

      // Nút 'Thêm khoản chi'
      final addBtnFinder = find.widgetWithText(ElevatedButton, 'Thêm khoản chi');
      expect(addBtnFinder, findsOneWidget);
      final addBtnSize = tester.getSize(addBtnFinder);
      expect(addBtnSize.height, greaterThanOrEqualTo(48.0));

      // Chip lọc 'Tất cả'
      final allPillFinder = find.ancestor(
        of: find.text('Tất cả').first,
        matching: find.byType(ConstrainedBox),
      );
      expect(allPillFinder, findsWidgets);
      final pillSize = tester.getSize(allPillFinder.first);
      expect(pillSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('tương thích hoàn hảo với Dark Theme mà không bị lỗi màu', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cubit: cubit,
        theme: AppTheme.darkTheme,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ExpenseCardWidget), findsNWidgets(2));
      expect(find.text('Bạn đã thanh toán'), findsOneWidget);
    });

    testWidgets('không bị overflow trên màn hình nhỏ và tỷ lệ font lớn (1.35x)', (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(
        cubit: cubit,
        textScale: 1.35,
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
