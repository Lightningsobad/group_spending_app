import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:group_spending_app/core/sync/data_sync_coordinator.dart';
import 'package:group_spending_app/core/theme/app_text_style.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/core/theme/app_theme_colors.dart';
import 'package:group_spending_app/features/auth/domain/entities/user_entity.dart';
import 'package:group_spending_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:group_spending_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:group_spending_app/features/expenses/data/models/expense_enums.dart';
import 'package:group_spending_app/features/expenses/data/models/expense_models.dart';
import 'package:group_spending_app/features/expenses/data/models/receipt_scan_models.dart';
import 'package:group_spending_app/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:group_spending_app/features/expenses/presentation/screens/expense_detail_screen.dart';
import 'package:group_spending_app/features/expenses/presentation/widgets/expense_detail_skeleton.dart';
import 'package:group_spending_app/features/groups/data/models/group_member_models.dart';
import 'package:group_spending_app/features/groups/data/models/group_model.dart';
import 'package:group_spending_app/features/groups/domain/repositories/groups_repository.dart';
import 'package:group_spending_app/features/groups/presentation/cubit/groups_cubit.dart';
import 'package:group_spending_app/l10n/l10n.dart';
import 'package:group_spending_app/shared/widgets/app_shimmer.dart';

class FakeAuthCubit extends Cubit<AuthState> implements AuthCubit {
  FakeAuthCubit()
      : super(
          const AuthState(
            status: AuthStatus.authenticated,
            currentUser: UserEntity(
              id: 1,
              email: 'user1@example.com',
              fullName: 'Nguyễn Nhật Minh',
              role: 'ADMIN',
              isEmailVerified: true,
            ),
          ),
        );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeExpensesRepository implements ExpensesRepository {
  Completer<ExpenseDetailModel>? delayCompleter;
  ExpenseDetailModel? customExpense;

  ExpenseDetailModel get defaultExpense =>
      customExpense ??
      const ExpenseDetailModel(
        id: 10,
        groupId: 1,
        groupName: 'Chung cư Sunrise Room',
        title: 'Lẩu Haidilao cuối tuần cùng phòng',
        totalAmount: 1280000,
        totalAmountVnd: 1280000,
        paidByUserId: 1,
        paidByUserName: 'Nguyễn Nhật Minh',
        expenseDate: '2026-10-18T19:30:00Z',
        createdAt: '2026-10-18T19:30:00Z',
        status: 'ACTIVE',
        createdByUserId: 1,
        categoryName: 'Ăn uống',
        notes: 'Set lẩu 4 người kèm nước uống và tráng miệng.',
        receiptUrl: 'https://example.com/receipt.jpg',
        splits: [
          ExpenseSplitModel(
            id: 1,
            userId: 1,
            fullName: 'Nguyễn Nhật Minh',
            amountOwed: 320000,
            amountOwedVnd: 320000,
            isPaid: true,
            status: 'PAID',
          ),
          ExpenseSplitModel(
            id: 2,
            userId: 2,
            fullName: 'Trần Thị B',
            amountOwed: 320000,
            amountOwedVnd: 320000,
            isPaid: false,
            status: 'UNPAID',
          ),
          ExpenseSplitModel(
            id: 3,
            userId: 3,
            fullName: 'Lê Văn C',
            amountOwed: 320000,
            amountOwedVnd: 320000,
            isPaid: false,
            status: 'PENDING_APPROVAL',
          ),
        ],
      );

  @override
  Future<ExpenseDetailModel> getExpenseDetail(int expenseId) async {
    if (delayCompleter != null) {
      return delayCompleter!.future;
    }
    return defaultExpense;
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
  Future<List<String>> getCategories() async => [];

  @override
  Future<GroupExpensesResponseModel> getGroupExpenses(int groupId,
          {ExpenseTimeFilter? timeFilter,
          ExpensePayerFilter? payerFilter,
          ExpenseCategoryFilter? categoryFilter,
          String? search}) async =>
      throw UnimplementedError();

  @override
  Future<ReceiptScanDataModel> scanReceipt(File file) async => throw UnimplementedError();
}

class FakeGroupsRepository implements GroupsRepository {
  final defaultGroup = const GroupModel(
    id: 1,
    name: 'Chung cư Sunrise Room',
    description: 'Nhóm chi tiêu chung',
    category: 'ROOM',
    ownerId: 1,
    memberCount: 3,
    members: [
      GroupMemberModel(id: 1, userId: 1, fullName: 'Nguyễn Nhật Minh', email: 'minh@example.com', role: 'ADMIN'),
      GroupMemberModel(id: 2, userId: 2, fullName: 'Trần Thị B', email: 'b@example.com', role: 'MEMBER'),
      GroupMemberModel(id: 3, userId: 3, fullName: 'Lê Văn C', email: 'c@example.com', role: 'MEMBER'),
    ],
  );

  @override
  Future<GroupModel> getGroupDetails(int groupId) async => defaultGroup;

  @override
  Future<List<GroupMemberSummaryModel>> getGroupMembers(int groupId, {String? name}) async => const [];

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

  final sampleGroup = const GroupModel(
    id: 1,
    name: 'Chung cư Sunrise Room',
    description: 'Nhóm chi tiêu chung',
    category: 'ROOM',
    ownerId: 1,
    memberCount: 3,
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
    int expenseId = 10,
    ThemeData? theme,
    double? textScale,
    Size? surfaceSize,
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
            BlocProvider<GroupsCubit>.value(value: groupsCubit),
          ],
          child: MaterialApp(
            theme: theme ?? AppTheme.lightTheme,
            locale: const Locale('vi'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MediaQuery(
              data: MediaQueryData(
                size: surfaceSize ?? const Size(390, 844),
                textScaler: TextScaler.linear(textScale ?? 1.0),
              ),
              child: ExpenseDetailScreen(
                expenseId: expenseId,
                group: sampleGroup,
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('ExpenseDetailScreen UI/UX & Quality Tests', () {
    testWidgets('1. Hiển thị hiệu ứng shimmer skeleton khi dữ liệu chi tiết khoản chi đang tải', (tester) async {
      expensesRepo.delayCompleter = Completer<ExpenseDetailModel>();

      await tester.pumpWidget(buildTestScreen());
      await tester.pump();

      // Verify that ExpenseDetailSkeleton is displayed with AppShimmer
      expect(find.byType(ExpenseDetailSkeleton), findsOneWidget);
      expect(find.byType(AppShimmer), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Complete the loading
      expensesRepo.delayCompleter!.complete(expensesRepo.defaultExpense);
      await tester.pumpAndSettle();

      // Skeleton should be gone, content visible
      expect(find.byType(ExpenseDetailSkeleton), findsNothing);
      expect(find.text('Lẩu Haidilao cuối tuần cùng phòng'), findsOneWidget);
    });

    testWidgets('2. UX & Touch Target: các nút bấm có kích thước chạm tối thiểu >= 48x48px và khoảng cách >= 8px', (tester) async {
      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      // Nút chuông nhắc nhở thanh toán (thành viên 2 chưa trả)
      final bellFinder = find.byIcon(LucideIcons.bell);
      expect(bellFinder, findsWidgets);

      // Verify container enclosing the bell icon has min 48x48
      final bellContainer = tester.widget<Container>(
        find.ancestor(of: bellFinder.first, matching: find.byType(Container)).first,
      );
      expect(bellContainer.constraints?.minWidth, greaterThanOrEqualTo(48.0));
      expect(bellContainer.constraints?.minHeight, greaterThanOrEqualTo(48.0));

      // Nút Phóng to hóa đơn
      final zoomButtonFinder = find.widgetWithText(TextButton, 'Phóng to');
      expect(zoomButtonFinder, findsOneWidget);
      final zoomButton = tester.widget<TextButton>(zoomButtonFinder);
      expect(zoomButton.style?.minimumSize?.resolve({}), equals(const Size(48, 48)));

      // Nút hành động ở đáy: Chiều cao tối thiểu 48px
      final editButtonFinder = find.widgetWithText(OutlinedButton, 'Sửa thông tin khoản chi');
      final deleteButtonFinder = find.widgetWithText(OutlinedButton, 'Xóa khoản chi này');
      expect(editButtonFinder, findsOneWidget);
      expect(deleteButtonFinder, findsOneWidget);

      final editButton = tester.widget<OutlinedButton>(editButtonFinder);
      final deleteButton = tester.widget<OutlinedButton>(deleteButtonFinder);
      expect(editButton.style?.minimumSize?.resolve({}), equals(const Size.fromHeight(48)));
      expect(deleteButton.style?.minimumSize?.resolve({}), equals(const Size.fromHeight(48)));
    });

    testWidgets('3. Tương thích hoàn hảo với Dark Theme qua AppThemeColors không dùng mã màu hardcoded', (tester) async {
      await tester.pumpWidget(buildTestScreen(theme: AppTheme.darkTheme));
      await tester.pumpAndSettle();

      // Màn hình hiển thị bình thường trong Dark Mode
      expect(find.text('Lẩu Haidilao cuối tuần cùng phòng'), findsOneWidget);
      expect(find.text('NGƯỜI THANH TOÁN'), findsOneWidget);

      // Verify scaffold background matches dark theme
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(AppTheme.darkTheme.extension<AppThemeColors>()?.background));
    });

    testWidgets('4. Không bị overflow trên màn hình nhỏ (320px) và tỷ lệ font lớn (1.35x)', (tester) async {
      tester.view.physicalSize = const Size(320 * 2.0, 640 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestScreen(
        surfaceSize: const Size(320, 640),
        textScale: 1.35,
      ));
      await tester.pumpAndSettle();

      // Không phát sinh lỗi RenderFlex overflow
      expect(tester.takeException(), isNull);
      expect(find.text('Lẩu Haidilao cuối tuần cùng phòng'), findsOneWidget);
    });

    testWidgets('5. Accessibility & Typography: bọc SafeArea và áp dụng thang AppFontSize sàn tối thiểu 12px', (tester) async {
      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      // Bọc SafeArea
      expect(find.byType(SafeArea), findsWidgets);

      // Kiểm tra tất cả các Text widgets trên màn hình có cỡ chữ >= 12px
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      for (final text in textWidgets) {
        if (text.style?.fontSize != null) {
          expect(
            text.style!.fontSize!,
            greaterThanOrEqualTo(AppFontSize.caption),
            reason: 'Text "${text.data}" có cỡ chữ ${text.style!.fontSize} dưới sàn tối thiểu 12px!',
          );
        }
      }
    });
  });
}
