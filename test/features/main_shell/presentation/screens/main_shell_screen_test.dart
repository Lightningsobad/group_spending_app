import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/l10n/locale_cubit.dart';
import 'package:group_spending_app/l10n/l10n.dart';
import 'package:group_spending_app/core/storage/app_preferences.dart';
import 'package:group_spending_app/core/theme/theme_cubit.dart';
import 'package:group_spending_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:group_spending_app/features/main_shell/presentation/screens/main_shell_screen.dart';
import 'package:group_spending_app/features/main_shell/presentation/widgets/app_header.dart';
import 'package:group_spending_app/features/main_shell/presentation/widgets/main_bottom_nav_bar.dart';
import 'package:group_spending_app/features/main_shell/presentation/widgets/notification_modal.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/presentation/cubit/auth_cubit_test.dart';
import '../../../dashboard/dashboard_cubit_test.dart';
import '../../../groups/groups_cubit_test.dart';
import '../../../analytics/presentation/cubit/analytics_cubits_test.dart';
import 'package:group_spending_app/features/analytics/presentation/cubit/analytics_tab_cubit.dart';
import 'package:group_spending_app/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:group_spending_app/features/debts/presentation/cubit/debts_cubit.dart';
import 'package:group_spending_app/features/groups/presentation/cubit/groups_cubit.dart';

void main() {
  group('MainShellScreen Tests', () {
    late AppPreferences prefs;
    late ThemeCubit themeCubit;
    late LocaleCubit localeCubit;
    late FakeAuthRepository fakeRepo;
    late AuthCubit authCubit;
    late FakeDebtsRepository debtsRepo;
    late FakeGroupsRepo groupsRepo;
    late FakeAnalyticsRepository analyticsRepo;
    late DashboardCubit dashboardCubit;
    late GroupsCubit groupsCubit;
    late AnalyticsTabCubit analyticsTabCubit;
    late DebtsCubit debtsCubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'user_full_name': 'Nguyễn Nhật Minh',
        'user_email': 'minh.nguyen@example.com',
      });
      prefs = await AppPreferences.init();
      themeCubit = ThemeCubit(prefs);
      localeCubit = LocaleCubit(prefs);
      fakeRepo = FakeAuthRepository();
      authCubit = AuthCubit(fakeRepo);
      debtsRepo = FakeDebtsRepository();
      groupsRepo = FakeGroupsRepo();
      analyticsRepo = FakeAnalyticsRepository();
      dashboardCubit = DashboardCubit(
        debtsRepository: debtsRepo,
        groupsRepository: groupsRepo,
      );
      groupsCubit = GroupsCubit(groupsRepo);
      analyticsTabCubit = AnalyticsTabCubit(
        analyticsRepository: analyticsRepo,
        groupsRepository: groupsRepo,
      );
      debtsCubit = DebtsCubit(debtsRepo);
    });

    Widget createWidgetUnderTest({int initialTabIndex = 0}) {
      return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AppPreferences>.value(value: prefs),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<ThemeCubit>.value(value: themeCubit),
            BlocProvider<LocaleCubit>.value(value: localeCubit),
            BlocProvider<DashboardCubit>.value(value: dashboardCubit),
            BlocProvider<GroupsCubit>.value(value: groupsCubit),
            BlocProvider<AnalyticsTabCubit>.value(value: analyticsTabCubit),
            BlocProvider<DebtsCubit>.value(value: debtsCubit),
          ],
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return BlocBuilder<LocaleCubit, Locale>(
                builder: (context, locale) {
                  return MaterialApp(
                    themeMode: themeMode,
                    locale: locale,
                    localizationsDelegates: AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    home: MainShellScreen(
                      initialTabIndex: initialTabIndex,
                      analyticsTabCubit: analyticsTabCubit,
                    ),
                  );
                },
              );
            },
          ),
        ),
      );
    }

    testWidgets('renders AppHeader, BottomNavBar with 5 tabs and initials', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Header verification
      expect(find.byType(AppHeader), findsOneWidget);
      expect(find.text('Xin chào,'), findsOneWidget);
      expect(find.text('Nguyễn Nhật Minh'), findsAtLeastNWidgets(1));
      // Initials for Nguyễn Nhật Minh is "NM"
      expect(find.text('NM'), findsOneWidget);

      // Bottom nav verification
      expect(find.byType(MainBottomNavBar), findsOneWidget);
      expect(find.text('Tổng quan'), findsAtLeastNWidgets(1));
      expect(find.text('Nhóm'), findsOneWidget);
      expect(find.text('Công nợ'), findsOneWidget);
      expect(find.text('Thống kê'), findsOneWidget);
      expect(find.text('Cài đặt'), findsOneWidget);
    });

    testWidgets('tab switching changes active view properly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Initial tab is Overview (Tổng quan)
      expect(find.text('Tổng quan'), findsAtLeastNWidgets(1));

      // Switch to Groups (Nhóm)
      await tester.tap(find.text('Nhóm'));
      await tester.pumpAndSettle();
      expect(find.text('Nhóm'), findsAtLeastNWidgets(1));

      // Switch to Debts (Công nợ)
      await tester.tap(find.text('Công nợ'));
      await tester.pumpAndSettle();
      expect(find.text('Công nợ'), findsAtLeastNWidgets(1));

      // Switch to Analytics (Thống kê)
      await tester.tap(find.text('Thống kê'));
      await tester.pumpAndSettle();
      expect(find.text('Thống kê'), findsAtLeastNWidgets(1));

      // Switch to Settings (Cài đặt)
      await tester.tap(find.text('Cài đặt'));
      await tester.pumpAndSettle();
      expect(find.text('Đăng xuất tài khoản'), findsOneWidget);
    });

    testWidgets('header action buttons: theme, language, notifications', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Toggle Theme from header
      final themeBtn = find.byIcon(LucideIcons.moon);
      expect(themeBtn, findsOneWidget);
      await tester.tap(themeBtn);
      await tester.pumpAndSettle();
      expect(themeCubit.isDarkMode, isTrue);

      // Toggle Language from header (badge shows VI initially)
      expect(find.text('VI'), findsOneWidget);
      final langBtn = find.byIcon(LucideIcons.languages);
      await tester.tap(langBtn);
      await tester.pumpAndSettle();
      expect(localeCubit.isEnglish, isTrue);
      expect(find.text('EN'), findsOneWidget);
      expect(find.text('Hello,'), findsOneWidget);

      // Open Notifications modal from bell icon
      final bellBtn = find.descendant(
        of: find.byType(AppHeader),
        matching: find.byIcon(LucideIcons.bell),
      );
      await tester.tap(bellBtn);
      await tester.pumpAndSettle();
      expect(find.byType(NotificationModal), findsOneWidget);
    });
  });
}
