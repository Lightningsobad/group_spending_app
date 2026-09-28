import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/analytics/presentation/cubit/global_analytics_cubit.dart';
import 'package:group_spending_app/features/analytics/presentation/screens/global_analytics_screen.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';
import '../cubit/analytics_cubits_test.dart';

void main() {
  group('GlobalAnalyticsScreen Widget Tests', () {
    late FakeAnalyticsRepository analyticsRepo;
    late GlobalAnalyticsCubit cubit;

    setUp(() {
      analyticsRepo = FakeAnalyticsRepository();
      cubit = GlobalAnalyticsCubit(
        analyticsRepository: analyticsRepo,
      );
    });

    Widget createWidgetUnderTest({Locale locale = const Locale('vi')}) {
      return BlocProvider<GlobalAnalyticsCubit>.value(
        value: cubit,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: GlobalAnalyticsScreen(cubit: cubit),
          ),
        ),
      );
    }

    testWidgets('renders all sections in Vietnamese', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      cubit.loadAnalytics();
      await tester.pumpAndSettle();

      // Header title & subtitle
      expect(find.text('Báo cáo tổng quan'), findsOneWidget);
      expect(find.text('Tổng hợp tất cả nhóm đang tham gia'), findsOneWidget);

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

      // Leaderboard
      expect(find.text('ĐÓNG GÓP & CHI TIÊU THÀNH VIÊN'), findsOneWidget);
      expect(find.text('Nguyễn Nhật Minh'), findsAtLeastNWidgets(1));

      // Recent expense history
      expect(find.text('HÓA ĐƠN CHI TIÊU GẦN ĐÂY'), findsOneWidget);
      expect(find.text('Lẩu Haidilao cuối tuần'), findsOneWidget);
    });

    testWidgets('changing period triggers cubit period update', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      cubit.loadAnalytics();
      await tester.pumpAndSettle();

      final lastMonthChip = find.text('Tháng trước');
      expect(lastMonthChip, findsOneWidget);
      await tester.tap(lastMonthChip);
      await tester.pumpAndSettle();

      expect(cubit.state.period.name, 'lastMonth');
    });

    testWidgets('tapping back button pops the screen', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      cubit.loadAnalytics();
      await tester.pumpAndSettle();

      final backButton = find.byType(IconButton);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    });
  });
}
