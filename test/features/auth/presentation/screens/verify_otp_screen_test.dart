import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:group_spending_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:group_spending_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:group_spending_app/features/auth/presentation/screens/verify_otp_screen.dart';
import '../cubit/auth_cubit_test.dart';

void main() {
  testWidgets(
    'VerifyOtpScreen renders email and allows entering 6-digit OTP to navigate to onboarding',
    (WidgetTester tester) async {
      final fakeRepo = FakeAuthRepository();
      final authCubit = AuthCubit(fakeRepo);

      final router = GoRouter(
        initialLocation: '/verify-otp',
        routes: [
          GoRoute(
            path: '/verify-otp',
            builder: (context, state) =>
                const VerifyOtpScreen(email: 'user@example.com'),
          ),
          GoRoute(
            path: '/onboarding',
            builder: (context, state) =>
                const Scaffold(body: Text('Onboarding Page')),
          ),
          GoRoute(
            path: '/auth',
            builder: (context, state) =>
                const Scaffold(body: Text('Auth Page')),
          ),
        ],
      );

      await tester.pumpWidget(
        BlocProvider<AuthCubit>.value(
          value: authCubit,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      // Verify header and email pill
      expect(find.text('Xác thực địa chỉ Email'), findsOneWidget);
      expect(find.text('user@example.com'), findsOneWidget);
      expect(find.text('Xác thực & Kích hoạt'), findsOneWidget);

      // Verify typing into the OTP input field
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      await tester.enterText(textField, '852941');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify successful OTP verification redirects to Onboarding
      expect(find.text('Onboarding Page'), findsOneWidget);

      authCubit.cancelCountdown();
      await authCubit.close();
    },
  );

  testWidgets(
    'VerifyOtpScreen back button resets auth status and returns to auth',
    (WidgetTester tester) async {
      final fakeRepo = FakeAuthRepository();
      final authCubit = AuthCubit(fakeRepo);
      authCubit.emit(
        authCubit.state.copyWith(status: AuthStatus.needsVerification),
      );

      final router = GoRouter(
        initialLocation: '/verify-otp',
        routes: [
          GoRoute(
            path: '/verify-otp',
            builder: (context, state) =>
                const VerifyOtpScreen(email: 'user@example.com'),
          ),
          GoRoute(
            path: '/auth',
            builder: (context, state) =>
                const Scaffold(body: Text('Auth Page')),
          ),
        ],
      );

      await tester.pumpWidget(
        BlocProvider<AuthCubit>.value(
          value: authCubit,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      // Tap back button
      final backButton = find.byType(IconButton).first;
      await tester.tap(backButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify auth status reset
      expect(authCubit.state.status, AuthStatus.unauthenticated);
      expect(find.text('Auth Page'), findsOneWidget);

      authCubit.cancelCountdown();
      await authCubit.close();
    },
  );

  testWidgets(
    'TEST-06: VerifyOtpScreen renders on narrow 320px width screen without overflow',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeRepo = FakeAuthRepository();
      final authCubit = AuthCubit(fakeRepo);

      await tester.pumpWidget(
        BlocProvider<AuthCubit>.value(
          value: authCubit,
          child: const MaterialApp(
            home: VerifyOtpScreen(email: 'user@example.com'),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Xác thực địa chỉ Email'), findsOneWidget);
      expect(find.text('Xác thực & Kích hoạt'), findsOneWidget);

      authCubit.cancelCountdown();
      await authCubit.close();
    },
  );
}
