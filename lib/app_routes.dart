import 'package:go_router/go_router.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/auth/presentation/screens/flash_screen.dart';
import 'features/auth/presentation/screens/verify_otp_screen.dart';
import 'features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'features/groups/presentation/cubit/groups_cubit.dart';
import 'features/main_shell/presentation/screens/main_shell_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';

List<RouteBase> buildAppRoutes({
  DashboardCubit? dashboardCubit,
  GroupsCubit? groupsCubit,
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
        return MainShellScreen(
          initialTabIndex: tab,
          dashboardCubit: dashboardCubit,
          groupsCubit: groupsCubit,
        );
      },
    ),
  ];
}
