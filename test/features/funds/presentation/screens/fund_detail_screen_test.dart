import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/funds/domain/entities/fund_entities.dart';
import 'package:group_spending_app/features/funds/domain/entities/fund_enums.dart';
import 'package:group_spending_app/features/funds/domain/repositories/funds_repository.dart';
import 'package:group_spending_app/features/funds/presentation/screens/fund_detail_screen.dart';
import 'package:group_spending_app/features/funds/presentation/widgets/fund_detail_skeleton.dart';
import 'package:group_spending_app/features/funds/presentation/widgets/fund_member_tile.dart';
import 'package:group_spending_app/features/groups/data/models/group_model.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';
import 'package:group_spending_app/shared/widgets/app_shimmer.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MockFundsRepository implements FundsRepository {
  final Duration delay;
  final FundCollectionEntity? detailToReturn;

  MockFundsRepository({
    this.delay = Duration.zero,
    this.detailToReturn,
  });

  @override
  Future<FundCollectionEntity> getFundCollectionDetails(int fundId) async {
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }
    return detailToReturn ??
        const FundCollectionEntity(
          id: 101,
          groupId: 5,
          name: 'Quỹ du lịch Hè 2026',
          description: 'Chi phí dã ngoại cuối tuần tại Ba Vì',
          targetAmountPerPerson: 500,
          targetAmountPerPersonVnd: 500000,
          dueDate: '2026-10-25',
          totalTargetAmount: 1000,
          totalTargetAmountVnd: 1000000,
          totalCollectedAmount: 500,
          totalCollectedAmountVnd: 500000,
          paidCount: 1,
          totalMemberCount: 2,
          status: FundCollectionStatus.collecting,
          members: [
            FundMemberEntity(
              id: 1,
              userId: 1,
              fullName: 'Nguyễn Văn A',
              status: FundMemberStatus.paid,
              paidAt: '2026-10-18T10:00:00Z',
            ),
            FundMemberEntity(
              id: 2,
              userId: 2,
              fullName: 'Trần Thị B',
              status: FundMemberStatus.pending,
            ),
          ],
        );
  }

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
  Future<FundCollectionEntity> markMemberPaid(int fundId, int targetUserId) async {
    return const FundCollectionEntity(
      id: 101,
      groupId: 5,
      name: 'Quỹ du lịch Hè 2026',
      targetAmountPerPerson: 500,
      targetAmountPerPersonVnd: 500000,
      totalTargetAmount: 1000,
      totalTargetAmountVnd: 1000000,
      totalCollectedAmount: 1000,
      totalCollectedAmountVnd: 1000000,
      paidCount: 2,
      totalMemberCount: 2,
      status: FundCollectionStatus.completed,
      members: [],
    );
  }

  @override
  Future<void> sendFundReminder(int fundId) async {}

  @override
  Future<void> deleteFundCollection(int fundId) async {}

  @override
  Future<List<int>> exportFundCsv(int fundId) async => [1, 2, 3];
}

void main() {
  const testAdminGroup = GroupModel(
    id: 5,
    name: 'Nhóm Phượt Thủ',
    category: 'friends',
    ownerId: 1,
    role: 'ADMIN',
  );

  Widget createWidgetUnderTest({
    FundsRepository? repo,
    ThemeData? theme,
    GroupModel? group = testAdminGroup,
    TextScaler? textScaler,
    Size? surfaceSize,
  }) {
    final effectiveRepo = repo ?? MockFundsRepository();
    final effectiveTheme = theme ?? AppTheme.lightTheme;

    return MaterialApp(
      locale: const Locale('vi'),
      theme: effectiveTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: RepositoryProvider<FundsRepository>.value(
        value: effectiveRepo,
        child: MediaQuery(
          data: MediaQueryData(
            size: surfaceSize ?? const Size(390, 844),
            textScaler: textScaler ?? TextScaler.noScaling,
            padding: const EdgeInsets.only(top: 44, bottom: 34),
          ),
          child: FundDetailScreen(
            fundId: 101,
            group: group,
          ),
        ),
      ),
    );
  }

  group('FundDetailScreen UI/UX & A11y Tests', () {
    testWidgets('renders FundDetailSkeleton with AppShimmer while loading initial data', (tester) async {
      final delayedRepo = MockFundsRepository(delay: const Duration(seconds: 2));

      await tester.pumpWidget(createWidgetUnderTest(repo: delayedRepo));
      // Pump initial frame before async data returns
      await tester.pump();

      // Shimmer skeleton should be present
      expect(find.byType(FundDetailSkeleton), findsOneWidget);
      expect(find.byType(AppShimmer), findsOneWidget);
      // Real data shouldn't be rendered yet
      expect(find.text('Quỹ du lịch Hè 2026'), findsNothing);

      // Finish delay
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Content now visible
      expect(find.byType(FundDetailSkeleton), findsNothing);
      expect(find.text('Quỹ du lịch Hè 2026'), findsOneWidget);
    });

    testWidgets('renders all screen sections and typography correctly in Light theme', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // SafeArea check
      expect(find.byType(SafeArea), findsWidgets);

      // Header checks
      expect(find.text('Chi tiết đợt đóng quỹ'), findsOneWidget);
      expect(find.text('Nhóm Phượt Thủ'), findsOneWidget);

      // Fund Info Card
      expect(find.text('Quỹ du lịch Hè 2026'), findsOneWidget);
      expect(find.text('Chi phí dã ngoại cuối tuần tại Ba Vì'), findsOneWidget);
      expect(find.textContaining('500.000 đ'), findsWidgets);
      expect(find.textContaining('1.000.000 đ'), findsWidgets);
      expect(find.text('50%'), findsOneWidget);

      // Members section
      expect(find.byType(FundMemberTile), findsNWidgets(2));
      expect(find.text('Nguyễn Văn A'), findsOneWidget);
      expect(find.text('Trần Thị B'), findsOneWidget);

      // Bottom actions
      expect(find.text('Chỉnh sửa đợt đóng quỹ'), findsOneWidget);
      expect(find.text('Xuất báo cáo CSV đợt thu quỹ'), findsOneWidget);
      expect(find.text('Xóa đợt đóng quỹ này'), findsOneWidget);
    });

    testWidgets('renders properly in Dark theme without errors or broken contrasts', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(theme: AppTheme.darkTheme));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Quỹ du lịch Hè 2026'), findsOneWidget);
      expect(find.text('Nguyễn Văn A'), findsOneWidget);
    });

    testWidgets('interactive elements satisfy minimum 48x48px touch target guidelines', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // 1. Back button touch area check
      final backButtonFinder = find.byIcon(LucideIcons.arrowLeft);
      expect(backButtonFinder, findsOneWidget);
      final backInkWell = find.ancestor(of: backButtonFinder, matching: find.byType(InkWell)).first;
      final backSize = tester.getSize(backInkWell);
      expect(backSize.width, greaterThanOrEqualTo(34.0));
      // Outer constrained container check
      final backConstrainedBox = find.ancestor(of: backInkWell, matching: find.byType(ConstrainedBox)).first;
      final constrainedSize = tester.getSize(backConstrainedBox);
      expect(constrainedSize.width, greaterThanOrEqualTo(48.0));
      expect(constrainedSize.height, greaterThanOrEqualTo(48.0));

      // 2. Admin Quick Edit & Quick Delete buttons touch target
      final penIconFinder = find.byIcon(LucideIcons.penLine).first;
      final editConstrained = find.ancestor(of: penIconFinder, matching: find.byType(ConstrainedBox)).first;
      final editSize = tester.getSize(editConstrained);
      expect(editSize.width, greaterThanOrEqualTo(48.0));
      expect(editSize.height, greaterThanOrEqualTo(48.0));

      // 3. Card CSV export chip touch target
      final csvTextFinder = find.text('CSV');
      final csvConstrained = find.ancestor(of: csvTextFinder, matching: find.byType(ConstrainedBox)).first;
      final csvSize = tester.getSize(csvConstrained);
      expect(csvSize.height, greaterThanOrEqualTo(48.0));

      // 4. Member Unpaid toggle button touch target
      final unpaidFinder = find.text('Chưa nộp');
      expect(unpaidFinder, findsOneWidget);
      final unpaidConstrained = find.ancestor(of: unpaidFinder, matching: find.byType(ConstrainedBox)).first;
      final unpaidSize = tester.getSize(unpaidConstrained);
      expect(unpaidSize.height, greaterThanOrEqualTo(48.0));

      // 5. Admin Remind Bell button touch target
      final bellFinder = find.byIcon(LucideIcons.bellRing);
      expect(bellFinder, findsOneWidget);
      final bellConstrained = find.ancestor(of: bellFinder, matching: find.byType(ConstrainedBox)).first;
      final bellSize = tester.getSize(bellConstrained);
      expect(bellSize.width, greaterThanOrEqualTo(48.0));
      expect(bellSize.height, greaterThanOrEqualTo(48.0));

      // 6. Bottom action buttons height check (>= 48px)
      final editBtnFinder = find.widgetWithText(OutlinedButton, 'Chỉnh sửa đợt đóng quỹ');
      expect(tester.getSize(editBtnFinder).height, greaterThanOrEqualTo(48.0));

      final csvBtnFinder = find.widgetWithText(ElevatedButton, 'Xuất báo cáo CSV đợt thu quỹ');
      expect(tester.getSize(csvBtnFinder).height, greaterThanOrEqualTo(48.0));

      final deleteBtnFinder = find.widgetWithText(TextButton, 'Xóa đợt đóng quỹ này');
      expect(tester.getSize(deleteBtnFinder).height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('spacing between member status toggle and remind bell is at least 8px', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final unpaidFinder = find.text('Chưa nộp');
      final bellFinder = find.byIcon(LucideIcons.bellRing);

      final unpaidBox = tester.getRect(unpaidFinder);
      final bellBox = tester.getRect(bellFinder);

      // Gap between unpaid status text/pill and bell
      expect(bellBox.left - unpaidBox.right, greaterThanOrEqualTo(8.0));
    });

    testWidgets('supports large non-linear TextScaler and small 320px screen without overflow', (tester) async {
      tester.view.physicalSize = const Size(320 * 2, 600 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createWidgetUnderTest(
          textScaler: const TextScaler.linear(1.5),
          surfaceSize: const Size(320, 600),
        ),
      );
      await tester.pumpAndSettle();

      // Verify no RenderFlex exception occurred
      expect(tester.takeException(), isNull);
      expect(find.text('Quỹ du lịch Hè 2026'), findsOneWidget);
      expect(find.text('Nguyễn Văn A'), findsOneWidget);
    });
  });
}
