import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:group_spending_app/core/storage/app_preferences.dart';
import 'package:group_spending_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:group_spending_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:group_spending_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cubit/auth_cubit_test.dart';

void main() {
  testWidgets('AuthScreen switches between Login and Register tabs', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await AppPreferences.init();
    final fakeRepo = FakeAuthRepository();
    final authCubit = AuthCubit(fakeRepo);

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AppPreferences>.value(value: prefs),
          RepositoryProvider<AuthRepository>.value(value: fakeRepo),
        ],
        child: BlocProvider<AuthCubit>.value(
          value: authCubit,
          child: const MaterialApp(home: AuthScreen()),
        ),
      ),
    );

    // Initial is Login tab
    final alignBefore = tester.widget<AnimatedAlign>(
      find.byType(AnimatedAlign),
    );
    expect(alignBefore.alignment, Alignment.centerLeft);
    expect(find.text('Đăng nhập vào ứng dụng'), findsOneWidget);
    expect(find.text('Quên mật khẩu?'), findsOneWidget);
    expect(find.text('Số điện thoại'), findsNothing);
    expect(find.text('HOẶC ĐĂNG NHẬP BẰNG EMAIL'), findsOneWidget);
    expect(find.text('Chưa có tài khoản? '), findsOneWidget);
    expect(find.text('Đăng ký ngay'), findsOneWidget);
    expect(find.text('Họ và tên'), findsNothing);

    // Tap Register tab
    await tester.tap(find.text('Đăng ký').first);
    await tester.pumpAndSettle();

    // Now should show Register form and indicator slided to right
    final alignRegister = tester.widget<AnimatedAlign>(
      find.byType(AnimatedAlign),
    );
    expect(alignRegister.alignment, Alignment.centerRight);
    expect(find.text('Họ và tên'), findsOneWidget);
    expect(find.text('Tạo tài khoản mới'), findsOneWidget);
    expect(find.text('Số điện thoại'), findsOneWidget);
    expect(find.text('Quên mật khẩu?'), findsNothing);
    expect(find.text('Đã có tài khoản? '), findsOneWidget);

    // Tap Login tab at top to switch back
    await tester.tap(find.text('Đăng nhập').first);
    await tester.pumpAndSettle();

    // Back to Login tab and indicator slided back to left
    final alignLogin = tester.widget<AnimatedAlign>(find.byType(AnimatedAlign));
    expect(alignLogin.alignment, Alignment.centerLeft);
    expect(find.text('Đăng nhập vào ứng dụng'), findsOneWidget);
    expect(find.text('Quên mật khẩu?'), findsOneWidget);
  });

  testWidgets('AuthScreen login navigates to /dashboard when authenticated', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await AppPreferences.init();
    final fakeRepo = FakeAuthRepository();
    final authCubit = AuthCubit(fakeRepo);

    final router = GoRouter(
      initialLocation: '/auth',
      routes: [
        GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) =>
              const Scaffold(body: Text('Dashboard Screen')),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AppPreferences>.value(value: prefs),
          RepositoryProvider<AuthRepository>.value(value: fakeRepo),
        ],
        child: BlocProvider<AuthCubit>.value(
          value: authCubit,
          child: MaterialApp.router(routerConfig: router),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    final loginBtn = find.text('Đăng nhập vào ứng dụng');
    await tester.ensureVisible(loginBtn);
    await tester.tap(loginBtn);
    await tester.pumpAndSettle();

    expect(find.text('Dashboard Screen'), findsOneWidget);
  });

  testWidgets('AuthScreen tapping "Quên mật khẩu?" navigates to /forgot-password', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await AppPreferences.init();
    final fakeRepo = FakeAuthRepository();
    final authCubit = AuthCubit(fakeRepo);

    final router = GoRouter(
      initialLocation: '/auth',
      routes: [
        GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) =>
              const Scaffold(body: Text('Forgot Password Screen')),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AppPreferences>.value(value: prefs),
          RepositoryProvider<AuthRepository>.value(value: fakeRepo),
        ],
        child: BlocProvider<AuthCubit>.value(
          value: authCubit,
          child: MaterialApp.router(routerConfig: router),
        ),
      ),
    );

    final forgotPwBtn = find.text('Quên mật khẩu?');
    expect(forgotPwBtn, findsOneWidget);

    await tester.tap(forgotPwBtn);
    await tester.pumpAndSettle();

    expect(find.text('Forgot Password Screen'), findsOneWidget);
  });
}
