import 'package:go_router/go_router.dart';
import '../session/session_coordinator.dart';

class AppRouter {
  AppRouter._();

  static GoRouter createRouter({
    required List<RouteBase> routes,
    SessionCoordinator? sessionCoordinator,
    String initialLocation = '/splash',
  }) {
    return GoRouter(
      initialLocation: initialLocation,
      refreshListenable: sessionCoordinator,
      redirect: (context, state) {
        if (sessionCoordinator == null) return null;

        final isAuthenticated = sessionCoordinator.isAuthenticated;
        final matchedLoc = state.matchedLocation;
        final isAuthPath = matchedLoc == '/auth';
        final isProtectedPath = matchedLoc == '/dashboard';

        // Người dùng chưa xác thực không được vào route riêng tư
        if (!isAuthenticated && isProtectedPath) {
          return '/auth';
        }

        // Người dùng đã xác thực tự động đưa về dashboard nếu đang ở auth
        if (isAuthenticated && isAuthPath) {
          return '/dashboard';
        }

        return null;
      },
      routes: routes,
    );
  }

  static GoRouter? _router;

  static GoRouter get router => _router ?? createRouter(routes: const []);
  static set router(GoRouter router) => _router = router;
}
