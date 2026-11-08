import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:group_spending_app/core/sync/data_sync_coordinator.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/auth/domain/entities/user_entity.dart';
import 'package:group_spending_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:group_spending_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:group_spending_app/features/expenses/data/models/expense_enums.dart';
import 'package:group_spending_app/features/expenses/data/models/expense_models.dart';
import 'package:group_spending_app/features/expenses/data/models/receipt_scan_models.dart';
import 'package:group_spending_app/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:group_spending_app/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:group_spending_app/features/expenses/presentation/widgets/add_expense_skeleton.dart';
import 'package:group_spending_app/features/expenses/presentation/widgets/ai_receipt_scanner_card.dart';
import 'package:group_spending_app/features/groups/data/models/group_member_models.dart';
import 'package:group_spending_app/features/groups/data/models/group_model.dart';
import 'package:group_spending_app/features/groups/domain/repositories/groups_repository.dart';
import 'package:group_spending_app/features/groups/presentation/cubit/groups_cubit.dart';
import 'package:group_spending_app/l10n/l10n.dart';

class FakeAuthCubit extends Cubit<AuthState> implements AuthCubit {
  FakeAuthCubit()
      : super(
          const AuthState(
            status: AuthStatus.authenticated,
            currentUser: UserEntity(
              id: 1,
              email: 'user1@example.com',
              fullName: 'Nguyễn Văn A',
              role: 'MEMBER',
              isEmailVerified: true,
            ),
          ),
        );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeExpensesRepository implements ExpensesRepository {
  @override
  Future<ExpenseDetailModel> createExpense(int groupId, CreateExpenseRequest request, {File? receiptFile}) async {
    return ExpenseDetailModel(
      id: 10,
      groupId: groupId,
      title: request.title,
      totalAmount: request.totalAmount,
      totalAmountVnd: request.totalAmount,
      paidByUserId: request.paidByUserId,
      paidByUserName: 'Nguyễn Văn A',
      status: 'ACTIVE',
      createdByUserId: 1,
      categoryName: request.category,
      splits: const [],
    );
  }

  @override
  Future<ExpenseDetailModel> updateExpense(int expenseId, UpdateExpenseRequest request, {File? receiptFile}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteExpense(int expenseId) async {}

  @override
  Future<List<String>> getCategories() async => [];

  @override
  Future<ExpenseDetailModel> getExpenseDetail(int expenseId) async => throw UnimplementedError();

  @override
  Future<GroupExpensesResponseModel> getGroupExpenses(int groupId, {ExpenseTimeFilter? timeFilter, ExpensePayerFilter? payerFilter, ExpenseCategoryFilter? categoryFilter, String? search}) async =>
      throw UnimplementedError();

  @override
  Future<ReceiptScanDataModel> scanReceipt(File file) async => throw UnimplementedError();
}

class FakeGroupsRepository implements GroupsRepository {
  Completer<GroupModel>? delayDetailsCompleter;

  final defaultGroup = const GroupModel(
    id: 1,
    name: 'Nhóm Đi Chơi Đà Lạt',
    description: 'Chuyến đi',
    category: 'TRIP',
    ownerId: 1,
    memberCount: 3,
    members: [
      GroupMemberModel(id: 1, userId: 1, fullName: 'Nguyễn Văn A', email: 'a@example.com', role: 'ADMIN'),
      GroupMemberModel(id: 2, userId: 2, fullName: 'Trần Thị B', email: 'b@example.com', role: 'MEMBER'),
      GroupMemberModel(id: 3, userId: 3, fullName: 'Lê Văn C', email: 'c@example.com', role: 'MEMBER'),
    ],
  );

  @override
  Future<GroupModel> getGroupDetails(int groupId) async {
    if (delayDetailsCompleter != null) {
      return delayDetailsCompleter!.future;
    }
    return defaultGroup;
  }

  @override
  Future<List<GroupMemberSummaryModel>> getGroupMembers(int groupId, {String? name}) async => const [
    GroupMemberSummaryModel(userId: 1, fullName: 'Nguyễn Văn A', role: 'ADMIN'),
    GroupMemberSummaryModel(userId: 2, fullName: 'Trần Thị B', role: 'MEMBER'),
    GroupMemberSummaryModel(userId: 3, fullName: 'Lê Văn C', role: 'MEMBER'),
  ];

  @override
  Future<List<GroupModel>> getMyGroups({String? filter, String? category, String? search}) async => [defaultGroup];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeAuthCubit authCubit;
  late FakeExpensesRepository expensesRepo;
  late FakeGroupsRepository groupsRepo;
  late GroupsCubit groupsCubit;
  late DataSyncCoordinator syncCoordinator;

  final sampleGroupWithMembers = const GroupModel(
    id: 1,
    name: 'Nhóm Đi Chơi Đà Lạt',
    description: 'Chuyến đi',
    category: 'TRIP',
    ownerId: 1,
    memberCount: 3,
    members: [
      GroupMemberModel(id: 1, userId: 1, fullName: 'Nguyễn Văn A', email: 'a@example.com', role: 'ADMIN'),
      GroupMemberModel(id: 2, userId: 2, fullName: 'Trần Thị B', email: 'b@example.com', role: 'MEMBER'),
      GroupMemberModel(id: 3, userId: 3, fullName: 'Lê Văn C', email: 'c@example.com', role: 'MEMBER'),
    ],
  );

  setUp(() {
    authCubit = FakeAuthCubit();
    expensesRepo = FakeExpensesRepository();
    groupsRepo = FakeGroupsRepository();
    syncCoordinator = DataSyncCoordinator();
    groupsCubit = GroupsCubit(groupsRepo, dataSyncCoordinator: syncCoordinator);
  });

  tearDown(() {
    authCubit.close();
    groupsCubit.close();
    syncCoordinator.dispose();
  });

  Widget buildTestScreen({
    GroupModel? group,
    ExpenseDetailModel? expenseToEdit,
    ThemeData? theme,
    double? textScale,
    Locale? locale,
    bool includeGroupsCubit = true,
  }) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ExpensesRepository>.value(value: expensesRepo),
        RepositoryProvider<GroupsRepository>.value(value: groupsRepo),
      ],
      child: ChangeNotifierProvider<DataSyncCoordinator>.value(
        value: syncCoordinator,
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            if (includeGroupsCubit)
              BlocProvider<GroupsCubit>.value(value: groupsCubit),
          ],
          child: MaterialApp(
            theme: theme ?? AppTheme.lightTheme,
            locale: locale ?? const Locale('vi'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MediaQuery(
              data: MediaQueryData(
                textScaler: TextScaler.linear(textScale ?? 1.0),
              ),
              child: AddExpenseScreen(
                group: group ?? sampleGroupWithMembers,
                expenseToEdit: expenseToEdit,
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('AddExpenseScreen UI/UX & Quality Tests', () {
    testWidgets('hiển thị hiệu ứng shimmer skeleton khi danh sách thành viên nhóm đang tải', (tester) async {
      final completer = Completer<GroupModel>();
      groupsRepo.delayDetailsCompleter = completer;

      const groupWithoutMembers = GroupModel(
        id: 1,
        name: 'Nhóm Đi Chơi Đà Lạt',
        description: 'Chuyến đi',
        category: 'TRIP',
        ownerId: 1,
        memberCount: 3,
        members: null,
      );

      await tester.pumpWidget(buildTestScreen(group: groupWithoutMembers));
      await tester.pump(); // Render first loading frame

      // Skeleton placeholder phải xuất hiện ở 2 vị trí (Người trả & Khung chia tiền)
      expect(find.byType(AddExpensePayerSkeleton), findsOneWidget);
      expect(find.byType(AddExpenseSplitSkeleton), findsOneWidget);

      // Hoàn tất tải dữ liệu
      completer.complete(groupsRepo.defaultGroup);
      await tester.pumpAndSettle();

      // Skeletons biến mất, nội dung thật xuất hiện
      expect(find.byType(AddExpensePayerSkeleton), findsNothing);
      expect(find.byType(AddExpenseSplitSkeleton), findsNothing);
      expect(find.text('Trần Thị B'), findsWidgets);
    });

    testWidgets('UX & Touch Target: các nút bấm có chiều cao tối thiểu >= 48px và khoảng cách >= 8px', (tester) async {
      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      // 1. Nút "Đổi nhóm"
      final changeGroupBtnFinder = find.widgetWithText(OutlinedButton, 'Đổi nhóm');
      expect(changeGroupBtnFinder, findsOneWidget);
      final changeGroupSize = tester.getSize(changeGroupBtnFinder);
      expect(changeGroupSize.height, greaterThanOrEqualTo(48.0));

      // 2. Nút "Chụp ảnh" & "Tải ảnh lên"
      final captureBtnFinder = find.widgetWithText(InkWell, 'Chụp ảnh');
      expect(captureBtnFinder, findsOneWidget);
      final captureSize = tester.getSize(captureBtnFinder);
      expect(captureSize.height, greaterThanOrEqualTo(48.0));

      final uploadBtnFinder = find.widgetWithText(InkWell, 'Tải ảnh lên');
      expect(uploadBtnFinder, findsOneWidget);
      final uploadSize = tester.getSize(uploadBtnFinder);
      expect(uploadSize.height, greaterThanOrEqualTo(48.0));

      // 3. Phím bấm số CustomNumericKeypad (chiều cao >= 48px)
      final digitBtnFinder = find.widgetWithText(InkWell, '1');
      expect(digitBtnFinder, findsOneWidget);
      final digitSize = tester.getSize(digitBtnFinder);
      expect(digitSize.height, greaterThanOrEqualTo(48.0));

      // 4. Nút "Tất cả" & "Bỏ chọn" (chiều cao >= 48px và khoảng cách >= 8px)
      final allBtnFinder = find.widgetWithText(OutlinedButton, 'Tất cả');
      final deselectBtnFinder = find.widgetWithText(OutlinedButton, 'Bỏ chọn');
      expect(allBtnFinder, findsOneWidget);
      expect(deselectBtnFinder, findsOneWidget);

      expect(tester.getSize(allBtnFinder).height, greaterThanOrEqualTo(48.0));
      expect(tester.getSize(deselectBtnFinder).height, greaterThanOrEqualTo(48.0));

      final allRight = tester.getTopRight(allBtnFinder).dx;
      final deselectLeft = tester.getTopLeft(deselectBtnFinder).dx;
      expect(deselectLeft - allRight, greaterThanOrEqualTo(8.0));

      // 5. Nút "Hủy bỏ" & "Lưu khoản chi mới"
      final cancelBtnFinder = find.widgetWithText(OutlinedButton, 'Hủy bỏ');
      final submitBtnFinder = find.widgetWithText(ElevatedButton, 'Lưu khoản chi mới');
      expect(cancelBtnFinder, findsOneWidget);
      expect(submitBtnFinder, findsOneWidget);

      expect(tester.getSize(cancelBtnFinder).height, greaterThanOrEqualTo(48.0));
      expect(tester.getSize(submitBtnFinder).height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('tương thích hoàn hảo với Dark Theme mà không có mã màu hardcoded bị lỗi', (tester) async {
      await tester.pumpWidget(buildTestScreen(theme: AppTheme.darkTheme));
      await tester.pumpAndSettle();

      expect(find.text('NHÓM NHẬN CHI TIÊU'), findsOneWidget);
      expect(find.text('SỐ TIỀN CHI TIÊU (VNĐ)'), findsOneWidget);
      expect(find.text('₫'), findsOneWidget);
      expect(find.text('Lưu khoản chi mới'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('không bị overflow trên màn hình nhỏ (320px) và tỷ lệ font lớn (1.35x)', (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestScreen(textScale: 1.35));
      await tester.pumpAndSettle();

      // Bấm các phím số trên bàn phím số
      await tester.tap(find.widgetWithText(InkWell, '5'));
      await tester.pump();
      await tester.tap(find.widgetWithText(InkWell, '2'));
      await tester.pump();
      await tester.tap(find.widgetWithText(InkWell, '3'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Typography & Localization chuẩn hóa: tiêu đề mục >= 12px và hiển thị ký hiệu ₫', (tester) async {
      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      // Tiêu đề overline viết hoa
      expect(find.text('NHÓM NHẬN CHI TIÊU'), findsOneWidget);
      expect(find.text('SỐ TIỀN CHI TIÊU (VNĐ)'), findsOneWidget);
      expect(find.text('TÊN KHOẢN CHI'), findsOneWidget);
      expect(find.text('DANH MỤC CHI TIÊU'), findsOneWidget);
      expect(find.text('NGƯỜI ĐÃ TRẢ TIỀN (DUY NHẤT 1 NGƯỜI)'), findsOneWidget);
      expect(find.text('KHUNG PHÂN CHIA CHI PHÍ'), findsOneWidget);

      // Ký hiệu tiền tệ hiển thị ₫ thay vì $
      expect(find.text('₫'), findsOneWidget);
      expect(find.text('\$'), findsNothing);
    });

    testWidgets('load dữ liệu thành viên thành công qua GroupsRepository ngay cả khi không có GroupsCubit trong context', (tester) async {
      const groupWithoutMembers = GroupModel(
        id: 1,
        name: 'Nhóm Đi Chơi Đà Lạt',
        description: 'Chuyến đi',
        category: 'TRIP',
        ownerId: 1,
        memberCount: 3,
        members: null,
      );

      await tester.pumpWidget(buildTestScreen(
        group: groupWithoutMembers,
        includeGroupsCubit: false,
      ));
      await tester.pumpAndSettle();

      // Skeletons phải biến mất và dữ liệu thành viên phải xuất hiện
      expect(find.byType(AddExpensePayerSkeleton), findsNothing);
      expect(find.byType(AddExpenseSplitSkeleton), findsNothing);
      expect(find.text('Trần Thị B'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('nút Đổi nhóm mở danh sách nhóm thành công qua GroupsRepository khi không có GroupsCubit', (tester) async {
      await tester.pumpWidget(buildTestScreen(includeGroupsCubit: false));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(OutlinedButton, 'Đổi nhóm'));
      await tester.pumpAndSettle();

      expect(find.text('Chọn nhóm nhận chi tiêu'), findsOneWidget);
      expect(find.text('Nhóm Đi Chơi Đà Lạt'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('thẻ quét hóa đơn khi đã có ảnh (hasReceipt: true) không bị overflow trên màn hình 320px và 1.35x font', (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final expenseWithReceipt = ExpenseDetailModel(
        id: 101,
        groupId: 1,
        title: 'Ăn tối nhóm',
        totalAmount: 300,
        totalAmountVnd: 300000,
        paidByUserId: 1,
        paidByUserName: 'Nguyễn Văn A',
        createdByUserId: 1,
        receiptUrl: 'https://example.com/receipt.jpg',
        categoryName: 'FOOD',
        status: 'ACTIVE',
        splits: const [],
      );

      await tester.pumpWidget(buildTestScreen(
        expenseToEdit: expenseWithReceipt,
        textScale: 1.35,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(AiReceiptScannerCard), findsOneWidget);
      expect(find.text('Đã quét & đính kèm hóa đơn'), findsOneWidget);
      expect(find.text('Xem ảnh'), findsOneWidget);
      expect(find.text('Chụp lại'), findsOneWidget);
      expect(find.text('Đổi ảnh'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('hỗ trợ đa ngôn ngữ chuyển đổi chuẩn xác sang tiếng Anh (en)', (tester) async {
      await tester.pumpWidget(buildTestScreen(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('EXPENSE RECEIVING GROUP'), findsOneWidget);
      expect(find.text('EXPENSE AMOUNT (VND)'), findsOneWidget);
      expect(find.text('EXPENSE TITLE'), findsOneWidget);
      expect(find.text('EXPENSE CATEGORY'), findsOneWidget);
      expect(find.text('PAID BY (SINGLE PAYER)'), findsOneWidget);
      expect(find.text('EXPENSE SPLIT BREAKDOWN'), findsOneWidget);
      expect(find.text('Change Group'), findsOneWidget);
      expect(find.text('Save New Expense'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('EXP-04: nút Lưu bị vô hiệu hóa khi danh sách thành viên nhóm đang tải', (tester) async {
      groupsRepo.delayDetailsCompleter = Completer<GroupModel>();

      await tester.pumpWidget(buildTestScreen(group: const GroupModel(id: 1, name: 'Nhóm Chưa Load', ownerId: 1)));
      await tester.pump();

      final saveBtn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(saveBtn.onPressed, isNull);
      expect(find.text('Đang tải...'), findsOneWidget);

      groupsRepo.delayDetailsCompleter!.complete(groupsRepo.defaultGroup);
      await tester.pumpAndSettle();

      final activeSaveBtn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(activeSaveBtn.onPressed, isNotNull);
    });
  });
}
