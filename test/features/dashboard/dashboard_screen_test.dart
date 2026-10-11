import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:group_spending_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:group_spending_app/features/debts/data/models/debt_overview_model.dart';
import 'package:group_spending_app/features/groups/presentation/cubit/groups_cubit.dart';
import 'package:group_spending_app/features/dashboard/presentation/widgets/dashboard_empty_groups_view.dart';
import 'package:group_spending_app/features/dashboard/presentation/widgets/financial_balance_card.dart';
import 'package:group_spending_app/features/dashboard/presentation/widgets/financial_balance_card_skeleton.dart';
import 'package:group_spending_app/features/groups/presentation/widgets/group_card_skeleton.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';
import 'dashboard_cubit_test.dart';
import '../groups/groups_cubit_test.dart';

void main() {
  group('DashboardScreen Widget Tests', () {
    late FakeDebtsRepository debtsRepo;
    late FakeGroupsRepo groupsRepo;
    late DashboardCubit dashboardCubit;
    late GroupsCubit groupsCubit;

    setUp(() {
      debtsRepo = FakeDebtsRepository();
      debtsRepo.response = const DebtOverviewModel(
        totalOwedVnd: 450000,
        totalReceivableVnd: 2450000,
      );
      groupsRepo = FakeGroupsRepo();
      dashboardCubit = DashboardCubit(
        debtsRepository: debtsRepo,
        groupsRepository: groupsRepo,
      );
      groupsCubit = GroupsCubit(groupsRepo);
    });

    Widget createWidgetUnderTest({
      VoidCallback? onNavigateToGroups,
      VoidCallback? onNavigateToJoinGroup,
      Locale locale = const Locale('vi'),
    }) {
      return MultiBlocProvider(
        providers: [
          BlocProvider<DashboardCubit>.value(value: dashboardCubit),
          BlocProvider<GroupsCubit>.value(value: groupsCubit),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: DashboardScreen(
              onNavigateToGroups: onNavigateToGroups,
              onNavigateToJoinGroup: onNavigateToJoinGroup,
            ),
          ),
        ),
      );
    }

    testWidgets('renders financial overview card and quick action buttons in Vietnamese', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(locale: const Locale('vi')));
      await tester.pumpAndSettle();

      // Financial overview card
      expect(find.text('TỔNG QUAN SỐ DƯ TÀI CHÍNH'), findsOneWidget);
      expect(find.text('Bạn đang nợ'), findsOneWidget);
      expect(find.text('450.000 đ'), findsOneWidget);
      expect(find.text('Bạn nhận'), findsOneWidget);
      expect(find.text('2.450.000 đ'), findsOneWidget);

      // Quick action buttons
      expect(find.text('Thêm chi tiêu'), findsOneWidget);
      expect(find.text('Tạo nhóm'), findsOneWidget);
      expect(find.text('Mã / QR'), findsOneWidget);

      // Groups section header
      expect(find.text('CÁC NHÓM CỦA BẠN'), findsOneWidget);
      expect(find.text('Xem tất cả (3)'), findsOneWidget);

      // Group cards
      expect(find.text('Chung cư Sunrise Room'), findsOneWidget);
      expect(find.text('+2.450.000 đ'), findsOneWidget);
      expect(find.text('Đội Cầu Lông Ba Đình'), findsOneWidget);
      expect(find.text('-450.000 đ'), findsOneWidget);
    });

    testWidgets('renders localized strings in English when locale is en', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(locale: const Locale('en')));
      await tester.pumpAndSettle();

      // Financial overview card in English
      expect(find.text('FINANCIAL BALANCE OVERVIEW'), findsOneWidget);
      expect(find.text('You owe'), findsOneWidget);
      expect(find.text('You receive'), findsOneWidget);

      // Quick action buttons in English
      expect(find.text('Add expense'), findsOneWidget);
      expect(find.text('Create group'), findsOneWidget);
      expect(find.text('Code / QR'), findsOneWidget);

      // Groups section header in English
      expect(find.text('YOUR GROUPS'), findsOneWidget);
      expect(find.text('See all (3)'), findsOneWidget);
    });

    testWidgets('tapping Xem tất cả invokes onNavigateToGroups callback', (tester) async {
      bool navigated = false;
      await tester.pumpWidget(createWidgetUnderTest(
        locale: const Locale('vi'),
        onNavigateToGroups: () {
          navigated = true;
        },
      ));
      await tester.pumpAndSettle();

      final seeAllBtn = find.text('Xem tất cả (3)');
      expect(seeAllBtn, findsOneWidget);
      await tester.tap(seeAllBtn);
      await tester.pump();

      expect(navigated, isTrue);
    });

    testWidgets('tapping Mã / QR invokes onNavigateToJoinGroup callback', (tester) async {
      bool joinNavigated = false;
      await tester.pumpWidget(createWidgetUnderTest(
        locale: const Locale('vi'),
        onNavigateToJoinGroup: () {
          joinNavigated = true;
        },
      ));
      await tester.pumpAndSettle();

      final qrBtn = find.text('Mã / QR');
      expect(qrBtn, findsOneWidget);
      await tester.tap(qrBtn);
      await tester.pump();

      expect(joinNavigated, isTrue);
    });

    testWidgets('renders shimmer skeletons immediately during initial loading without flashing 0 balance or empty state', (tester) async {
      final slowDebtsRepo = FakeDebtsRepository()..delay = const Duration(milliseconds: 500);
      final slowGroupsRepo = FakeGroupsRepo()..delay = const Duration(milliseconds: 500);
      final cubit = DashboardCubit(
        debtsRepository: slowDebtsRepo,
        groupsRepository: slowGroupsRepo,
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<DashboardCubit>.value(value: cubit),
            BlocProvider<GroupsCubit>.value(value: groupsCubit),
          ],
          child: const MaterialApp(
            locale: Locale('vi'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: DashboardScreen()),
          ),
        ),
      );

      // Only pump 1 frame before async repository completes
      await tester.pump();

      // Must show skeletons
      expect(find.byType(FinancialBalanceCardSkeleton), findsOneWidget);
      expect(find.byType(GroupCardSkeleton), findsNWidgets(2));

      // Must NOT show 0d financial balance card or empty groups view or "Xem tất cả (0)"
      expect(find.byType(FinancialBalanceCard), findsNothing);
      expect(find.byType(DashboardEmptyGroupsView), findsNothing);
      expect(find.text('Xem tất cả (0)'), findsNothing);

      // Complete async tasks
      await tester.pumpAndSettle();
    });

    testWidgets('tapping Thêm chi tiêu opens SelectGroupForExpenseView and back returns to dashboard', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(locale: const Locale('vi')));
      await tester.pumpAndSettle();

      // Tap 'Thêm chi tiêu'
      await tester.tap(find.text('Thêm chi tiêu'));
      await tester.pumpAndSettle();

      // Expect SelectGroupForExpenseView to be visible
      expect(find.text('Chọn nhóm muốn thêm khoản chi'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(LucideIcons.arrowLeft));
      await tester.pumpAndSettle();

      // Expect dashboard to be visible again
      expect(find.text('TỔNG QUAN SỐ DƯ TÀI CHÍNH'), findsOneWidget);
      expect(find.text('Chọn nhóm muốn thêm khoản chi'), findsNothing);
    });

    testWidgets('tapping eye icon on FinancialBalanceCard masks and unmasks balances', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(locale: const Locale('vi')));
      await tester.pumpAndSettle();

      // Initially shows numbers
      expect(find.text('450.000 đ'), findsOneWidget);
      expect(find.text('2.450.000 đ'), findsOneWidget);
      expect(find.text('••••••••'), findsNothing);

      // Tap Eye icon
      await tester.tap(find.byIcon(LucideIcons.eye));
      await tester.pumpAndSettle();

      // Now masked
      expect(find.text('450.000 đ'), findsNothing);
      expect(find.text('2.450.000 đ'), findsNothing);
      expect(find.text('••••••••'), findsNWidgets(2));
      expect(find.byIcon(LucideIcons.eyeOff), findsOneWidget);

      // Tap EyeOff icon to unmask
      await tester.tap(find.byIcon(LucideIcons.eyeOff));
      await tester.pumpAndSettle();

      // Numbers restored
      expect(find.text('450.000 đ'), findsOneWidget);
      expect(find.text('2.450.000 đ'), findsOneWidget);
      expect(find.text('••••••••'), findsNothing);
    });

    testWidgets('See all button in DashboardGroupsHeader has minimum 48px touch target height', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(locale: const Locale('vi')));
      await tester.pumpAndSettle();

      final seeAllTextFinder = find.text('Xem tất cả (3)');
      expect(seeAllTextFinder, findsOneWidget);

      final inkWellFinder = find.ancestor(
        of: seeAllTextFinder,
        matching: find.byType(InkWell),
      );
      expect(inkWellFinder, findsOneWidget);
      final size = tester.getSize(inkWellFinder);
      expect(size.height, greaterThanOrEqualTo(48.0));
      expect(size.width, greaterThanOrEqualTo(48.0));
    });

    testWidgets('renders cleanly without overflow under high text scale (1.5x)', (tester) async {
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<DashboardCubit>.value(value: dashboardCubit),
            BlocProvider<GroupsCubit>.value(value: groupsCubit),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            locale: const Locale('vi'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MediaQuery(
              data: const MediaQueryData(
                textScaler: TextScaler.linear(1.5),
              ),
              child: const Scaffold(body: DashboardScreen()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('CÁC NHÓM CỦA BẠN'), findsOneWidget);
    });
  });
}
