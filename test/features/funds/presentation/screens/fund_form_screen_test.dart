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
    return const FundCollectionEntity(
      id: 999,
      groupId: 1,
      name: 'Quỹ update',
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
  Future<FundCollectionEntity> getFundCollectionDetails(int fundId) async {
    throw UnimplementedError();
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
              groupId: 1,
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
      expect(find.text('Mỗi người'), findsOneWidget);
      expect(find.text('Tổng quỹ'), findsOneWidget);

      // Switch to totalFund mode
      await tester.tap(find.text('Tổng quỹ'));
      await tester.pumpAndSettle();

      // Switch back to perPerson mode
      await tester.tap(find.text('Mỗi người'));
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
  });
}
