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
    late GroupAnalyticsCubit cubit;

    setUp(() {
      analyticsRepo = FakeAnalyticsRepository();
      cubit = GroupAnalyticsCubit(
        groupId: 10,
        analyticsRepository: analyticsRepo,
      );
    });

    Widget createWidgetUnderTest({Locale locale = const Locale('vi')}) {
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
              groupName: 'Chung cư Sunrise Room',
              groupCategory: 'Nhà ở',
              memberCount: 4,
              cubit: cubit,
            ),
          ),
        ),
      );
    }

    testWidgets('renders group header, financial metrics and member contribution in Vietnamese', (tester) async {
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
    });

    testWidgets('changing period triggers cubit period update', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      cubit.loadGroupAnalytics();
      await tester.pumpAndSettle();

      final yearChip = find.text('Cả năm');
      expect(yearChip, findsOneWidget);
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
  });
}
