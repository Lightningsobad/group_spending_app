import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/funds/domain/entities/fund_entities.dart';
import 'package:group_spending_app/features/funds/domain/entities/fund_enums.dart';
import 'package:group_spending_app/features/funds/domain/repositories/funds_repository.dart';
import 'package:group_spending_app/features/funds/presentation/cubit/funds_cubit.dart';
import 'package:group_spending_app/features/funds/presentation/cubit/funds_state.dart';
import 'package:group_spending_app/features/funds/presentation/widgets/fund_card_widget.dart';
import 'package:group_spending_app/features/funds/presentation/widgets/fund_filter_bar.dart';
import 'package:group_spending_app/features/funds/presentation/widgets/fund_overview_card.dart';
import 'package:group_spending_app/features/funds/presentation/widgets/group_funds_tab_view.dart';
import 'package:group_spending_app/features/groups/data/models/group_model.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';
import 'package:group_spending_app/shared/widgets/app_shimmer.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MockFundsRepository implements FundsRepository {
  final GroupFundsOverviewEntity? overviewToReturn;
  final Duration delay;

  MockFundsRepository({
    this.overviewToReturn,
    this.delay = Duration.zero,
  });

  @override
  Future<GroupFundsOverviewEntity> getGroupFundsOverview(
    int groupId, {
    String? search,
    FundTimeFilter? timeFilter,
    FundCollectionStatus? status,
  }) async {
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }
    return overviewToReturn ??
        const GroupFundsOverviewEntity(
          groupId: 1,
          totalCollectedAmount: 13000,
          totalCollectedAmountVnd: 13000000,
          totalTargetAmount: 20000,
          totalTargetAmountVnd: 20000000,
          completionPercentage: 65.0,
          funds: [
            FundCollectionItemEntity(
              id: 101,
              name: 'Quỹ du lịch Hè',
              totalCollectedAmountVnd: 5000000,
              totalTargetAmountVnd: 10000000,
              status: FundCollectionStatus.collecting,
              statusText: 'Đang thu tiền',
            ),
            FundCollectionItemEntity(
              id: 102,
              name: 'Quỹ sinh nhật tháng 10',
              totalCollectedAmountVnd: 8000000,
              totalTargetAmountVnd: 8000000,
              status: FundCollectionStatus.completed,
              statusText: 'Hoàn thành',
            ),
          ],
        );
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
    throw UnimplementedError();
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
    throw UnimplementedError();
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

void main() {
  const testGroup = GroupModel(
    id: 1,
    name: 'Nhóm Bạn Thân',
    category: 'friends',
    ownerId: 1,
    role: 'ADMIN',
  );

  Widget createWidgetUnderTest({
    FundsRepository? repo,
    ThemeData? theme,
    TextScaler? textScaler,
    VoidCallback? onCreateFund,
  }) {
    final effectiveRepo = repo ?? MockFundsRepository();
    final effectiveTheme = theme ?? AppTheme.lightTheme;

    return MaterialApp(
      locale: const Locale('vi'),
      theme: effectiveTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(
            textScaler: textScaler ?? TextScaler.noScaling,
            padding: const EdgeInsets.only(top: 44, bottom: 34),
          ),
          child: BlocProvider<FundsCubit>(
            create: (_) => FundsCubit(effectiveRepo),
            child: SingleChildScrollView(
              child: GroupFundsTabView(
                group: testGroup,
                onCreateFund: onCreateFund,
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('GroupFundsTabView UI/UX Tests', () {
    testWidgets('renders full shimmer skeleton when loading initial data', (tester) async {
      final cubit = FundsCubit(MockFundsRepository());
      // Set to loading with null overview
      cubit.emit(const FundsState(status: FundsStatus.loading, overview: null));

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: BlocProvider<FundsCubit>.value(
              value: cubit,
              child: const SingleChildScrollView(
                child: GroupFundsTabView(group: testGroup),
              ),
            ),
          ),
        ),
      );

      // Shimmer skeletons should be visible across the whole page
      expect(find.byType(AppShimmer), findsWidgets);
      // Real Overview text shouldn't be rendered yet
      expect(find.textContaining('13.000.000 đ'), findsNothing);
    });

    testWidgets('renders full content, Text.rich amounts, and status badges after load', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Overview Card
      expect(find.byType(FundOverviewCard), findsOneWidget);
      expect(find.text('TỔNG TIỀN QUỸ CHUNG'), findsOneWidget);
      expect(find.textContaining('13.000.000 đ'), findsOneWidget);
      expect(find.textContaining('20.000.000 đ'), findsOneWidget);
      expect(find.text('Thu quỹ mới'), findsOneWidget);

      // Filter Bar
      expect(find.byType(FundFilterBar), findsOneWidget);
      expect(find.text('Tất cả 2'), findsOneWidget);
      expect(find.text('Đang thu 1'), findsOneWidget);
      expect(find.text('Hoàn thành 1'), findsOneWidget);

      // Fund Card Items
      expect(find.byType(FundCardWidget), findsNWidgets(2));
      expect(find.text('Quỹ du lịch Hè'), findsOneWidget);
      expect(find.text('Quỹ sinh nhật tháng 10'), findsOneWidget);
      expect(find.text('Đang thu tiền'), findsOneWidget);
      expect(find.text('Hoàn thành'), findsOneWidget);
    });

    testWidgets('touch targets meet minimum 48px height guidelines', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // 1. CTA Button "Thu quỹ mới" size check
      final ctaButtonFinder = find.widgetWithText(ElevatedButton, 'Thu quỹ mới');
      expect(ctaButtonFinder, findsOneWidget);
      final ctaSize = tester.getSize(ctaButtonFinder);
      expect(ctaSize.height, greaterThanOrEqualTo(48.0));

      // 2. Filter chip touch targets check
      final filterPills = find.byType(InkWell);
      expect(filterPills, findsWidgets);
      for (final pill in tester.widgetList<InkWell>(filterPills)) {
        expect(pill.onTap, isNotNull);
      }

      // Check first filter chip tap height
      final firstFilterPill = find.widgetWithText(AnimatedContainer, 'Tất cả 2');
      final pillSize = tester.getSize(firstFilterPill);
      expect(pillSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('renders properly in dark mode without throwing exceptions', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(theme: AppTheme.darkTheme));
      await tester.pumpAndSettle();

      expect(find.byType(GroupFundsTabView), findsOneWidget);
      expect(find.text('TỔNG TIỀN QUỸ CHUNG'), findsOneWidget);
      expect(find.text('Quỹ du lịch Hè'), findsOneWidget);
    });

    testWidgets('supports large non-linear TextScaler without overflow', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          textScaler: const TextScaler.linear(1.5),
        ),
      );
      await tester.pumpAndSettle();

      // Verify no RenderFlex overflow exception
      expect(tester.takeException(), isNull);
      expect(find.text('TỔNG TIỀN QUỸ CHUNG'), findsOneWidget);
      expect(find.text('Quỹ du lịch Hè'), findsOneWidget);
    });

    testWidgets('displays themed empty state when no funds exist', (tester) async {
      final emptyRepo = MockFundsRepository(
        overviewToReturn: const GroupFundsOverviewEntity(
          groupId: 1,
          totalCollectedAmount: 0,
          totalCollectedAmountVnd: 0,
          totalTargetAmount: 0,
          totalTargetAmountVnd: 0,
          completionPercentage: 0.0,
          funds: [],
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(repo: emptyRepo));
      await tester.pumpAndSettle();

      expect(find.byType(FundCardWidget), findsNothing);
      expect(find.byIcon(LucideIcons.piggyBank), findsOneWidget);
      expect(find.text('Chưa có đợt đóng quỹ nào'), findsOneWidget);
    });
  });
}
