import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/analytics/presentation/cubit/analytics_tab_cubit.dart';
import 'package:group_spending_app/features/analytics/presentation/screens/analytics_tab_screen.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';
import '../../../groups/groups_cubit_test.dart';
import '../cubit/analytics_cubits_test.dart';

void main() {
  group('AnalyticsTabScreen Widget Tests', () {
    late FakeAnalyticsRepository analyticsRepo;
    late FakeGroupsRepo groupsRepo;
    late AnalyticsTabCubit cubit;

    setUp(() {
      analyticsRepo = FakeAnalyticsRepository();
      groupsRepo = FakeGroupsRepo();
      cubit = AnalyticsTabCubit(
        analyticsRepository: analyticsRepo,
        groupsRepository: groupsRepo,
      );
    });

    Widget createWidgetUnderTest({
      Locale locale = const Locale('vi'),
      void Function(int)? onNavigateToGroupAnalytics,
      VoidCallback? onNavigateToGlobalOverview,
    }) {
      return BlocProvider<AnalyticsTabCubit>.value(
        value: cubit,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AnalyticsTabScreen(
              onNavigateToGroupAnalytics: onNavigateToGroupAnalytics,
              onNavigateToGlobalOverview: onNavigateToGlobalOverview,
            ),
          ),
        ),
      );
    }

    testWidgets('renders personal overview card and group cards in Vietnamese', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(locale: const Locale('vi')));
      await tester.pumpAndSettle();

      // Header title
      expect(find.text('Báo cáo & Thống kê'), findsOneWidget);

      // Total spending overview banner
      expect(find.text('Tổng chi tất cả nhóm'), findsOneWidget);
      expect(find.text('20.490.000 đ'), findsOneWidget);
      expect(find.text('Xem toàn cảnh >'), findsOneWidget);

      // Search bar hint
      expect(find.text('Tìm kiếm nhóm theo tên, danh mục...'), findsOneWidget);

      // Group cards rendered from groups repository
      expect(find.text('Chung cư Sunrise Room'), findsOneWidget);
      expect(find.text('Đi phượt Đà Lạt 2024'), findsOneWidget);
    });

    testWidgets('tap on overview card triggers onNavigateToGlobalOverview callback', (tester) async {
      bool overviewTapped = false;
      await tester.pumpWidget(createWidgetUnderTest(
        onNavigateToGlobalOverview: () {
          overviewTapped = true;
        },
      ));
      await tester.pumpAndSettle();

      final overviewCard = find.text('Xem toàn cảnh >');
      expect(overviewCard, findsOneWidget);
      await tester.tap(overviewCard);
      await tester.pumpAndSettle();

      expect(overviewTapped, isTrue);
    });

    testWidgets('tap on group card triggers onNavigateToGroupAnalytics callback', (tester) async {
      int? tappedGroupId;
      await tester.pumpWidget(createWidgetUnderTest(
        onNavigateToGroupAnalytics: (id) {
          tappedGroupId = id;
        },
      ));
      await tester.pumpAndSettle();

      final firstGroup = find.text('Chung cư Sunrise Room');
      expect(firstGroup, findsOneWidget);
      await tester.tap(firstGroup);
      await tester.pumpAndSettle();

      expect(tappedGroupId, 1);
    });

    testWidgets('search query filters groups properly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Chung cư Sunrise Room'), findsOneWidget);
      expect(find.text('Đi phượt Đà Lạt 2024'), findsOneWidget);

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Đà Lạt');
      await tester.pumpAndSettle();

      expect(find.text('Chung cư Sunrise Room'), findsNothing);
      expect(find.text('Đi phượt Đà Lạt 2024'), findsOneWidget);
    });
  });
}
