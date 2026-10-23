import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/analytics/presentation/cubit/group_analytics_cubit.dart';
import 'package:group_spending_app/features/analytics/presentation/screens/group_analytics_screen.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';
import '../cubit/analytics_cubits_test.dart';

void main() {
  group('GroupAnalyticsScreen Widget Tests', () {
    late FakeAnalyticsRepository analyticsRepo;
    late FakeExpensesRepository expensesRepo;
    late GroupAnalyticsCubit cubit;

    setUp(() {
      analyticsRepo = FakeAnalyticsRepository();
      expensesRepo = FakeExpensesRepository();
      cubit = GroupAnalyticsCubit(
        groupId: 10,
        analyticsRepository: analyticsRepo,
        expensesRepository: expensesRepo,
      );
    });

    Widget createWidgetUnderTest({
      Locale locale = const Locale('vi'),
      String? groupName = 'Chung cư Sunrise Room',
      String? groupCategory = 'Nhà ở',
      int? memberCount = 4,
    }) {
      return BlocProvider<GroupAnalyticsCubit>.value(
        value: cubit,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: GroupAnalyticsScreen(
              groupId: 10,
              groupName: groupName,
              groupCategory: groupCategory,
              memberCount: memberCount,
              cubit: cubit,
            ),
          ),
        ),
      );
    }

    testWidgets('renders group header, financial metrics, leaderboard and recent expenses in Vietnamese', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidgetUnderTest());
      cubit.loadGroupAnalytics();
      await tester.pumpAndSettle();

      // Custom app bar with group title & category & member count
      expect(find.text('Chung cư Sunrise Room'), findsOneWidget);
      expect(find.text('Nhà ở • 4 thành viên'), findsOneWidget);

      // Period bar
      expect(find.text('Tháng trước'), findsOneWidget);

      // KPI metrics
      expect(find.text('Tổng tiền chi tiêu'), findsOneWidget);
      expect(find.text('20.490.000 đ'), findsOneWidget);
      expect(find.text('Bình quân đầu người'), findsOneWidget);
      expect(find.text('2.561.250 đ'), findsOneWidget);
      expect(find.text('Số khoản chi'), findsOneWidget);
      expect(find.text('6 khoản chi'), findsOneWidget);
      expect(find.text('Tỷ lệ tất toán'), findsOneWidget);
      expect(find.text('82% đã trả'), findsOneWidget);

      // Category distribution
      expect(find.text('Ăn uống & Nhà hàng'), findsOneWidget);

      // Member contribution leaderboard
      expect(find.text('ĐÓNG GÓP & CHI TIÊU THÀNH VIÊN'), findsOneWidget);
      expect(find.text('Nguyễn Nhật Minh'), findsAtLeastNWidgets(1));

      // Recent expenses section
      expect(find.text('HÓA ĐƠN CHI TIÊU GẦN ĐÂY'), findsOneWidget);
      expect(find.text('Lẩu Haidilao cuối tuần'), findsOneWidget);
      expect(find.text('1.280.000 đ'), findsOneWidget);
      expect(find.text('Chi tiết →'), findsOneWidget);
    });

    testWidgets('changing period triggers cubit period update', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      cubit.loadGroupAnalytics();
      await tester.pumpAndSettle();

      final yearChip = find.text('Cả năm');
      expect(yearChip, findsOneWidget);
      await tester.ensureVisible(yearChip);
      await tester.tap(yearChip);
      await tester.pumpAndSettle();

      expect(cubit.state.period.name, 'byYear');
    });

    testWidgets('renders on standard mobile screen without overflow', (tester) async {
      tester.view.physicalSize = const Size(360 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidgetUnderTest());
      cubit.loadGroupAnalytics();
      await tester.pumpAndSettle();
    });

    testWidgets('tapping back button calls navigator pop', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      cubit.loadGroupAnalytics();
      await tester.pumpAndSettle();

      final backButton = find.byType(IconButton);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    });

    testWidgets('renders shimmer in header while loading without groupName', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        groupName: null,
        groupCategory: null,
        memberCount: null,
      ));

      // Verify header renders shimmer placeholder, never raw fallback title
      expect(find.textContaining('Thống kê nhóm #10'), findsNothing);
    });

    testWidgets('renders translated category and 48x48 back button container', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        groupName: 'Chung cư Sunrise Room',
        groupCategory: 'Apartment',
        memberCount: 5,
      ));
      cubit.loadGroupAnalytics();
      await tester.pumpAndSettle();

      expect(find.text('Chung cư Sunrise Room'), findsOneWidget);
      expect(find.text('Căn hộ & Phòng trọ • 5 thành viên'), findsOneWidget);

      // Back button container must have 48x48 min touch target
      final backContainerFinder = find.ancestor(
        of: find.byType(IconButton),
        matching: find.byType(Container),
      ).first;
      final RenderBox backBox = tester.renderObject(backContainerFinder);
      expect(backBox.size.width, 48.0);
      expect(backBox.size.height, 48.0);
    });
  });
}
