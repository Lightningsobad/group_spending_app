import 'package:go_router/go_router.dart';
import 'features/analytics/presentation/cubit/analytics_tab_cubit.dart';
import 'features/analytics/presentation/cubit/global_analytics_cubit.dart';
import 'features/analytics/presentation/cubit/group_analytics_cubit.dart';
import 'features/analytics/presentation/screens/global_analytics_screen.dart';
import 'features/analytics/presentation/screens/group_analytics_screen.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/auth/presentation/screens/flash_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/verify_otp_screen.dart';
import 'features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'features/debts/presentation/cubit/debts_cubit.dart';
import 'features/expenses/presentation/screens/expense_detail_host_screen.dart';
import 'features/funds/presentation/screens/fund_detail_screen.dart';
import 'features/funds/presentation/screens/fund_form_screen.dart';
import 'features/groups/data/models/group_model.dart';
import 'features/expenses/presentation/cubit/expenses_cubit.dart';
import 'features/groups/presentation/cubit/groups_cubit.dart';
import 'features/main_shell/presentation/screens/main_shell_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/settings/presentation/screens/privacy_policy_screen.dart';

List<RouteBase> buildAppRoutes({
  DashboardCubit? dashboardCubit,
  GroupsCubit? groupsCubit,
  AnalyticsTabCubit? analyticsTabCubit,
  GlobalAnalyticsCubit? globalAnalyticsCubit,
  GroupAnalyticsCubit? groupAnalyticsCubit,
  DebtsCubit? debtsCubit,
  ExpensesCubit? expensesCubit,
}) {
  return [
    GoRoute(path: '/splash', builder: (context, state) => const FlashScreen()),
    GoRoute(
      path: '/auth',
      builder: (context, state) {
        final mode = state.uri.queryParameters['mode'] ?? 'login';
        return AuthScreen(initialMode: mode);
      },
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/verify-otp',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return VerifyOtpScreen(email: email);
      },
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) {
        final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
        final debtGroupId = int.tryParse(
          state.uri.queryParameters['debtGroupId'] ??
              (tab == 2 ? state.uri.queryParameters['groupId'] : null) ??
              '',
        );
        final debtDetailTab = int.tryParse(
          state.uri.queryParameters['debtDetailTab'] ??
              state.uri.queryParameters['detailTab'] ??
              '',
        );
        final groupId = int.tryParse(
          (tab == 1 ? state.uri.queryParameters['groupId'] : null) ?? '',
        );
        final groupTab = int.tryParse(state.uri.queryParameters['groupTab'] ?? '');

        return MainShellScreen(
          initialTabIndex: tab,
          initialDebtGroupId: debtGroupId,
          initialDebtDetailTab: debtDetailTab,
          initialGroupId: groupId,
          initialGroupTab: groupTab,
          dashboardCubit: dashboardCubit,
          groupsCubit: groupsCubit,
          analyticsTabCubit: analyticsTabCubit,
          debtsCubit: debtsCubit,
          expensesCubit: expensesCubit,
        );
      },
    ),
    GoRoute(
      path: '/groups/:groupId/expenses/:expenseId',
      builder: (context, state) {
        final groupId = int.tryParse(state.pathParameters['groupId'] ?? '') ?? 0;
        final expenseId = int.tryParse(state.pathParameters['expenseId'] ?? '') ?? 0;
        final group = state.extra as GroupModel?;
        return ExpenseDetailHostScreen(
          groupId: groupId,
          expenseId: expenseId,
          group: group,
        );
      },
    ),
    GoRoute(
      path: '/analytics/overview',
      builder: (context, state) => GlobalAnalyticsScreen(
        cubit: globalAnalyticsCubit,
      ),
    ),
    GoRoute(
      path: '/groups/:groupId/analytics',
      builder: (context, state) {
        final groupId = int.tryParse(state.pathParameters['groupId'] ?? '') ?? 0;
        final name = state.uri.queryParameters['name'];
        final category = state.uri.queryParameters['category'];
        final memberCount = int.tryParse(state.uri.queryParameters['memberCount'] ?? '');

        return GroupAnalyticsScreen(
          groupId: groupId,
          groupName: name,
          groupCategory: category,
          memberCount: memberCount,
          cubit: groupAnalyticsCubit,
        );
      },
    ),
    GoRoute(
      path: '/settings',
      redirect: (context, state) => '/dashboard?tab=4',
    ),
    GoRoute(
      path: '/settings/privacy-policy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: '/groups/:groupId/funds/create',
      builder: (context, state) {
        final groupId = int.tryParse(state.pathParameters['groupId'] ?? '') ?? 0;
        final group = state.extra as GroupModel?;
        return FundFormScreen(
          groupId: groupId,
          group: group,
        );
      },
    ),
    GoRoute(
      path: '/groups/:groupId/funds/:fundId',
      builder: (context, state) {
        final fundId = int.tryParse(state.pathParameters['fundId'] ?? '') ?? 0;
        final group = state.extra as GroupModel?;
        return FundDetailScreen(
          fundId: fundId,
          group: group,
        );
      },
    ),
    GoRoute(
      path: '/groups/:groupId/funds/:fundId/edit',
      builder: (context, state) {
        final groupId = int.tryParse(state.pathParameters['groupId'] ?? '') ?? 0;
        final group = state.extra as GroupModel?;
        return FundFormScreen(
          groupId: groupId,
          group: group,
          isEdit: true,
        );
      },
    ),
  ];
}
