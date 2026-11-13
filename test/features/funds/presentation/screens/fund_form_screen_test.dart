import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/auth/domain/entities/user_entity.dart';
import 'package:group_spending_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:group_spending_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:group_spending_app/features/funds/domain/entities/fund_entities.dart';
import 'package:group_spending_app/features/funds/domain/entities/fund_enums.dart';
import 'package:group_spending_app/features/funds/domain/repositories/funds_repository.dart';
import 'package:group_spending_app/features/funds/presentation/screens/fund_form_screen.dart';
import 'package:group_spending_app/features/groups/data/models/group_member_models.dart';
import 'package:group_spending_app/features/groups/data/models/group_model.dart';
import 'package:group_spending_app/features/groups/domain/repositories/groups_repository.dart';
import 'package:group_spending_app/features/groups/presentation/cubit/groups_cubit.dart';
import 'package:group_spending_app/features/groups/presentation/cubit/groups_state.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';
import 'package:group_spending_app/shared/widgets/app_shimmer.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MockFundsRepository implements FundsRepository {
  bool createCalled = false;
  bool updateCalled = false;
  int? lastUpdatedFundId;
  FundCollectionEntity? fundDetailsToReturn;

  @override
  Future<GroupFundsOverviewEntity> getGroupFundsOverview(
    int groupId, {
    String? search,
    FundTimeFilter? timeFilter,
    FundCollectionStatus? status,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<FundCollectionEntity> createFundCollection(
    int groupId, {
    required String name,
    String? description,
    required num targetAmountPerPersonVnd,
    String? dueDate,
    List<int>? memberUserIds,
  }) async {
    createCalled = true;
    return const FundCollectionEntity(
      id: 999,
      groupId: 1,
      name: 'Quỹ test',
      targetAmountPerPerson: 200,
      targetAmountPerPersonVnd: 200000,
      totalTargetAmount: 400,
      totalTargetAmountVnd: 400000,
      totalCollectedAmount: 0,
      totalCollectedAmountVnd: 0,
      paidCount: 0,
      totalMemberCount: 2,
      status: FundCollectionStatus.collecting,
      members: [],
    );
  }

  @override
  Future<FundCollectionEntity> updateFundCollection(
    int fundId, {
    required String name,
    String? description,
    required num targetAmountPerPersonVnd,
    String? dueDate,
    List<int>? memberUserIds,
  }) async {
    updateCalled = true;
    lastUpdatedFundId = fundId;
    return FundCollectionEntity(
      id: fundId,
      groupId: 1,
      name: name,
      targetAmountPerPerson: (targetAmountPerPersonVnd / 1000).round(),
      targetAmountPerPersonVnd: targetAmountPerPersonVnd,
      totalTargetAmount: 400,
      totalTargetAmountVnd: 400000,
      totalCollectedAmount: 0,
      totalCollectedAmountVnd: 0,
      paidCount: 0,
      totalMemberCount: 2,
      status: FundCollectionStatus.collecting,
      members: const [],
    );
  }

  @override
  Future<FundCollectionEntity> getFundCollectionDetails(int fundId) async {
    if (fundDetailsToReturn != null) {
      return fundDetailsToReturn!;
    }
    return FundCollectionEntity(
      id: fundId,
      groupId: 1,
      name: 'Quỹ chi tiết $fundId',
      targetAmountPerPerson: 200,
      targetAmountPerPersonVnd: 200000,
      totalTargetAmount: 400,
      totalTargetAmountVnd: 400000,
      totalCollectedAmount: 0,
      totalCollectedAmountVnd: 0,
      paidCount: 0,
      totalMemberCount: 2,
      status: FundCollectionStatus.collecting,
      members: const [],
    );
  }

  @override
  Future<FundCollectionEntity> markMemberPaid(int fundId, int targetUserId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> sendFundReminder(int fundId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteFundCollection(int fundId) async {
    throw UnimplementedError();
  }

  @override
  Future<List<int>> exportFundCsv(int fundId) async {
    return [];
  }
}

class MockGroupsRepository implements GroupsRepository {
  final List<GroupMemberSummaryModel> membersToReturn;
  final Completer<List<GroupMemberSummaryModel>>? pendingCompleter;

  MockGroupsRepository({
    this.membersToReturn = const [],
    this.pendingCompleter,
  });

  @override
  Future<List<GroupMemberSummaryModel>> getGroupMembers(int groupId, {String? name}) {
    if (pendingCompleter != null) {
      return pendingCompleter!.future;
    }
    return Future.value(membersToReturn);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthCubit extends Cubit<AuthState> implements AuthCubit {
  FakeAuthCubit()
      : super(const AuthState(
          status: AuthStatus.authenticated,
          currentUser: UserEntity(
            id: 1,
            email: 'test@example.com',
            fullName: 'Nguyễn Văn A',
            role: 'ADMIN',
            isEmailVerified: true,
          ),
        ));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeGroupsCubit extends Cubit<GroupsState> implements GroupsCubit {
  FakeGroupsCubit() : super(const GroupsState());

  @override
  Future<GroupModel?> loadGroupDetails(int groupId) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const testMember1 = GroupMemberModel(
    id: 1,
    userId: 1,
    fullName: 'Nguyễn Văn A',
    role: 'ADMIN',
  );
  const testMember2 = GroupMemberModel(
    id: 2,
    userId: 2,
    fullName: 'Trần Thị B',
    role: 'MEMBER',
  );

  const testGroup = GroupModel(
    id: 1,
    name: 'Nhóm Quỹ Công Ty',
    category: 'work',
    ownerId: 1,
    role: 'ADMIN',
    members: [testMember1, testMember2],
  );

  Widget createWidgetUnderTest({
    FundsRepository? fundsRepo,
    GroupsRepository? groupsRepo,
    ThemeData? theme,
    GroupModel? group = testGroup,
    FundCollectionEntity? initialFund,
    int? fundId,
    int groupId = 1,
    bool isEdit = false,
    VoidCallback? onBack,
    TextScaler? textScaler,
  }) {
    final effectiveFundsRepo = fundsRepo ?? MockFundsRepository();
    final effectiveGroupsRepo = groupsRepo ?? MockGroupsRepository();
    final effectiveTheme = theme ?? AppTheme.lightTheme;

    return MaterialApp(
      locale: const Locale('vi'),
      theme: effectiveTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<FundsRepository>.value(value: effectiveFundsRepo),
          RepositoryProvider<GroupsRepository>.value(value: effectiveGroupsRepo),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(create: (_) => FakeAuthCubit()),
            BlocProvider<GroupsCubit>(create: (_) => FakeGroupsCubit()),
          ],
          child: MediaQuery(
            data: MediaQueryData(
              textScaler: textScaler ?? TextScaler.noScaling,
              padding: const EdgeInsets.only(top: 44, bottom: 34),
            ),
            child: FundFormScreen(
              groupId: groupId,
              fundId: fundId,
              group: group,
              initialFund: initialFund,
              isEdit: isEdit,
              onBack: onBack,
            ),
          ),
        ),
      ),
    );
  }

  group('FundFormScreen UI/UX & A11y Tests', () {
    testWidgets('renders FundFormScreen in Light theme with SafeArea and correct elements', (tester) async {
      tester.view.physicalSize = const Size(800 * 2.0, 1200 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest(theme: AppTheme.lightTheme));
      await tester.pumpAndSettle();

      // Check SafeArea exists
      expect(find.byType(SafeArea), findsWidgets);

      // Check Title
      expect(find.text('Thêm đợt thu quỹ'), findsOneWidget);
      expect(find.text('Nhóm Quỹ Công Ty'), findsOneWidget);

      // Check Section labels
      expect(find.text('TÊN ĐỢT THU QUỸ *'), findsOneWidget);
      expect(find.text('SỐ TIỀN THU QUỸ *'), findsOneWidget);
      expect(find.text('HẠN NỘP (HẠN CHÓT)'), findsOneWidget);
      expect(find.text('GHI CHÚ / MỤC ĐÍCH THU QUỸ'), findsOneWidget);

      // Check members rendered
      expect(find.text('Nguyễn Văn A (Bạn)'), findsOneWidget);
      expect(find.text('Trần Thị B'), findsOneWidget);
    });

    testWidgets('renders FundFormScreen in Dark theme without errors', (tester) async {
      tester.view.physicalSize = const Size(800 * 2.0, 1200 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest(theme: AppTheme.darkTheme));
      await tester.pumpAndSettle();

      expect(find.text('Thêm đợt thu quỹ'), findsOneWidget);
      expect(find.text('Tạo đợt thu quỹ'), findsOneWidget);
    });

    testWidgets('back button has touch target size of at least 48x48px', (tester) async {
      bool backTapped = false;
      await tester.pumpWidget(createWidgetUnderTest(onBack: () => backTapped = true));
      await tester.pumpAndSettle();

      // Find the back button SizedBox wrapper
      final backButtonFinder = find.ancestor(
        of: find.byIcon(LucideIcons.arrowLeft),
        matching: find.byType(SizedBox),
      );
      expect(backButtonFinder, findsWidgets);

      final Size size = tester.getSize(backButtonFinder.first);
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));

      await tester.tap(find.byIcon(LucideIcons.arrowLeft));
      await tester.pumpAndSettle();
      expect(backTapped, isTrue);
    });

    testWidgets('displays AppShimmer skeleton when loading members with empty initial list', (tester) async {
      tester.view.physicalSize = const Size(800 * 2.0, 1200 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Pending completer so loading doesn't finish immediately
      final pendingCompleter = Completer<List<GroupMemberSummaryModel>>();
      final mockGroupsRepo = MockGroupsRepository(pendingCompleter: pendingCompleter);

      const emptyGroup = GroupModel(id: 1, name: 'Nhóm Rỗng', category: 'work', ownerId: 1, role: 'ADMIN');
      await tester.pumpWidget(createWidgetUnderTest(
        group: emptyGroup,
        groupsRepo: mockGroupsRepo,
      ));

      await tester.pump();
      expect(find.byType(AppShimmer), findsWidgets);

      // Finish loading
      pendingCompleter.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('tapping member row toggles selection state', (tester) async {
      tester.view.physicalSize = const Size(800 * 2.0, 1200 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Both members initially selected in create mode
      final checkboxFinder = find.byType(Checkbox);
      expect(checkboxFinder, findsNWidgets(2));
      Checkbox cb2 = tester.widget(checkboxFinder.at(1));
      expect(cb2.value, isTrue);

      // Tap on member row text
      await tester.ensureVisible(find.text('Trần Thị B'));
      await tester.tap(find.text('Trần Thị B'));
      await tester.pumpAndSettle();

      // Checkbox for member 2 should now be false
      cb2 = tester.widget(find.byType(Checkbox).at(1));
      expect(cb2.value, isFalse);

      // Tap again to select
      await tester.tap(find.text('Trần Thị B'));
      await tester.pumpAndSettle();
      cb2 = tester.widget(find.byType(Checkbox).at(1));
      expect(cb2.value, isTrue);
    });

    testWidgets('switching between perPerson and totalFund modes functions properly', (tester) async {
      tester.view.physicalSize = const Size(800 * 2.0, 1200 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Initial mode: Mỗi người / Tổng quỹ
      expect(find.text('Mỗi người'), findsWidgets);
      expect(find.text('Tổng quỹ'), findsOneWidget);

      // Switch to totalFund mode
      await tester.tap(find.text('Tổng quỹ'));
      await tester.pumpAndSettle();

      // Switch back to perPerson mode
      await tester.tap(find.text('Mỗi người').first);
      await tester.pumpAndSettle();
    });

    testWidgets('renders without overflow on narrow device with large text scaler', (tester) async {
      tester.view.physicalSize = const Size(320 * 2.0, 600 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest(
        textScaler: const TextScaler.linear(1.5),
      ));
      await tester.pumpAndSettle();

      // Verify no RenderFlex overflow exception occurred
      expect(tester.takeException(), isNull);
    });

    testWidgets('FUND-01: route edit mode with fundId loads fund details and saves with updateFundCollection', (tester) async {
      tester.view.physicalSize = const Size(800 * 2.0, 1200 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockFundsRepo = MockFundsRepository();
      mockFundsRepo.fundDetailsToReturn = const FundCollectionEntity(
        id: 77,
        groupId: 1,
        name: 'Quỹ Route Edit',
        description: 'Chi tiết ban đầu',
        targetAmountPerPerson: 100,
        targetAmountPerPersonVnd: 100000,
        totalTargetAmount: 200,
        totalTargetAmountVnd: 200000,
        totalCollectedAmount: 0,
        totalCollectedAmountVnd: 0,
        paidCount: 0,
        totalMemberCount: 2,
        status: FundCollectionStatus.collecting,
        members: [
          FundMemberEntity(
            id: 1,
            userId: 1,
            fullName: 'Nguyễn Văn A',
            status: FundMemberStatus.pending,
          ),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(
        fundsRepo: mockFundsRepo,
        fundId: 77,
        initialFund: null,
        isEdit: true,
      ));
      await tester.pumpAndSettle();

      // Verify fund details loaded and populated
      expect(find.text('Quỹ Route Edit'), findsOneWidget);

      // Tap save
      final saveBtn = find.text('Lưu thay đổi');
      expect(saveBtn, findsOneWidget);
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Must call updateFundCollection on ID 77, NEVER createFundCollection
      expect(mockFundsRepo.updateCalled, isTrue);
      expect(mockFundsRepo.lastUpdatedFundId, 77);
      expect(mockFundsRepo.createCalled, isFalse);
    });

    testWidgets('FUND-01: mismatched groupId displays error and blocks saving', (tester) async {
      tester.view.physicalSize = const Size(800 * 2.0, 1200 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockFundsRepo = MockFundsRepository();
      mockFundsRepo.fundDetailsToReturn = const FundCollectionEntity(
        id: 77,
        groupId: 999, // Mismatched groupId
        name: 'Quỹ nhóm khác',
        targetAmountPerPerson: 100,
        targetAmountPerPersonVnd: 100000,
        totalTargetAmount: 200,
        totalTargetAmountVnd: 200000,
        totalCollectedAmount: 0,
        totalCollectedAmountVnd: 0,
        paidCount: 0,
        totalMemberCount: 1,
        status: FundCollectionStatus.collecting,
        members: [],
      );

      await tester.pumpWidget(createWidgetUnderTest(
        fundsRepo: mockFundsRepo,
        groupId: 1,
        fundId: 77,
        initialFund: null,
        isEdit: true,
      ));
      await tester.pumpAndSettle();

      // Error message displayed
      expect(find.text('Đợt thu quỹ không thuộc nhóm này'), findsOneWidget);
      // Save button not visible or blocked
      expect(find.text('Lưu thay đổi'), findsNothing);
      expect(mockFundsRepo.updateCalled, isFalse);
      expect(mockFundsRepo.createCalled, isFalse);
    });

    testWidgets('FUND-02: Total mode calculates ceiling per-person amount in thousand VND', (tester) async {
      tester.view.physicalSize = const Size(800 * 2.0, 1200 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Group with 3 members: 100,000 / 3 -> 34,000 / person, 102,000 total expected
      const member3 = GroupMemberModel(
        id: 3,
        userId: 3,
        fullName: 'Lê Văn C',
        role: 'MEMBER',
      );
      const threeMemberGroup = GroupModel(
        id: 1,
        name: 'Nhóm 3 người',
        category: 'work',
        ownerId: 1,
        role: 'ADMIN',
        members: [testMember1, testMember2, member3],
      );

      await tester.pumpWidget(createWidgetUnderTest(
        group: threeMemberGroup,
      ));
      await tester.pumpAndSettle();

      // Switch to totalFund mode
      await tester.tap(find.text('Tổng quỹ'));
      await tester.pumpAndSettle();

      // Enter 100000
      final amountField = find.byType(TextField).at(1);
      await tester.enterText(amountField, '100000');
      await tester.pumpAndSettle();

      // Check summary: per person should be 34.000 đ, expected total 102.000 đ
      expect(find.text('102.000 đ'), findsOneWidget);
      expect(find.text('100.000 đ'), findsNWidgets(2)); // Quick chip & Target total
      expect(find.textContaining('34.000 đ/người'), findsOneWidget);
    });

    testWidgets('FUND-04: Edit mode loads full group members and keeps PAID member locked', (tester) async {
      tester.view.physicalSize = const Size(800 * 2.0, 1200 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final groupsRepo = MockGroupsRepository(
        membersToReturn: [
          const GroupMemberSummaryModel(userId: 1, fullName: 'Nguyễn Văn A', role: 'ADMIN'),
          const GroupMemberSummaryModel(userId: 2, fullName: 'Trần Thị B', role: 'MEMBER'),
          const GroupMemberSummaryModel(userId: 3, fullName: 'Lê Văn C', role: 'MEMBER'),
        ],
      );

      // Initial fund only had member 1 who already paid
      const initialFund = FundCollectionEntity(
        id: 55,
        groupId: 1,
        name: 'Quỹ test',
        targetAmountPerPerson: 100,
        targetAmountPerPersonVnd: 100000,
        totalTargetAmount: 100,
        totalTargetAmountVnd: 100000,
        totalCollectedAmount: 100,
        totalCollectedAmountVnd: 100000,
        paidCount: 1,
        totalMemberCount: 1,
        status: FundCollectionStatus.collecting,
        members: [
          FundMemberEntity(
            id: 1,
            userId: 1,
            fullName: 'Nguyễn Văn A',
            status: FundMemberStatus.paid,
          ),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(
        groupsRepo: groupsRepo,
        initialFund: initialFund,
        isEdit: true,
      ));
      await tester.pumpAndSettle();

      // All 3 members should be rendered
      expect(find.text('Nguyễn Văn A (Bạn)'), findsOneWidget);
      expect(find.text('Trần Thị B'), findsOneWidget);
      expect(find.text('Lê Văn C'), findsOneWidget);

      // Member 1 (PAID) checkbox is disabled (onChanged is null)
      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsNWidgets(3));
      final cb1 = tester.widget<Checkbox>(checkboxes.at(0));
      expect(cb1.value, isTrue);
      expect(cb1.onChanged, isNull); // Locked!

      // Member 2 is unchecked initially and can be toggled
      final cb2 = tester.widget<Checkbox>(checkboxes.at(1));
      expect(cb2.value, isFalse);
      expect(cb2.onChanged, isNotNull);
    });

    testWidgets('FUND-05: Date picker opens without error when dueDate is older than 30 days', (tester) async {
      tester.view.physicalSize = const Size(800 * 2.0, 1200 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Due date 60 days in the past
      final pastDate = DateTime.now().subtract(const Duration(days: 60));
      final dueDateStr = '${pastDate.year}-${pastDate.month.toString().padLeft(2, '0')}-${pastDate.day.toString().padLeft(2, '0')}';

      final initialFund = FundCollectionEntity(
        id: 60,
        groupId: 1,
        name: 'Quỹ ngày cũ',
        targetAmountPerPerson: 100,
        targetAmountPerPersonVnd: 100000,
        totalTargetAmount: 100,
        totalTargetAmountVnd: 100000,
        totalCollectedAmount: 0,
        totalCollectedAmountVnd: 0,
        paidCount: 0,
        totalMemberCount: 1,
        dueDate: dueDateStr,
        status: FundCollectionStatus.collecting,
        members: const [],
      );

      await tester.pumpWidget(createWidgetUnderTest(
        initialFund: initialFund,
        isEdit: true,
      ));
      await tester.pumpAndSettle();

      // Tap on date picker trigger
      final dateFinder = find.byIcon(LucideIcons.calendar);
      await tester.ensureVisible(dateFinder.last);
      await tester.tap(dateFinder.last);
      await tester.pumpAndSettle();

      // DatePicker should be open without throwing an exception
      expect(tester.takeException(), isNull);
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });
  });
}
