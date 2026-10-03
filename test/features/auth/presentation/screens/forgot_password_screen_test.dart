import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:group_spending_app/features/auth/presentation/cubit/password_reset_cubit.dart';
import 'package:group_spending_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';
import '../cubit/auth_cubit_test.dart';

Widget buildTestWidget({
  required FakeAuthRepository fakeRepo,
  PasswordResetCubit? cubit,
  GoRouter? router,
}) {
  final testRouter = router ??
      GoRouter(
        initialLocation: '/forgot-password',
        routes: [
          GoRoute(
            path: '/forgot-password',
            builder: (context, state) => ForgotPasswordScreen(cubit: cubit),
          ),
          GoRoute(
            path: '/auth',
            builder: (context, state) =>
                const Scaffold(body: Text('Auth Login Screen')),
          ),
        ],
      );

  return MaterialApp.router(
    routerConfig: testRouter,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('vi'),
  );
}

void main() {
  late FakeAuthRepository fakeRepo;
  late PasswordResetCubit cubit;

  setUp(() {
    fakeRepo = FakeAuthRepository();
    cubit = PasswordResetCubit(fakeRepo);
  });

  tearDown(() {
    cubit.cancelCountdown();
    cubit.close();
  });

  testWidgets('ForgotPasswordScreen renders Email step initially', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestWidget(fakeRepo: fakeRepo, cubit: cubit));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Quên mật khẩu'), findsOneWidget);
    expect(
      find.text('Nhập địa chỉ email của bạn để nhận mã xác thực đặt lại mật khẩu.'),
      findsOneWidget,
    );
    expect(find.text('Địa chỉ Email'), findsOneWidget);
    expect(find.text('Gửi mã xác thực'), findsOneWidget);
    expect(find.text('Quay lại đăng nhập'), findsOneWidget);

    cubit.cancelCountdown();
  });

  testWidgets('ForgotPasswordScreen transitions to OTP step after submitting email', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestWidget(fakeRepo: fakeRepo, cubit: cubit));
    await tester.pump();

    final emailField = find.byType(TextField);
    await tester.enterText(emailField, 'test@example.com');
    await tester.pump();

    await tester.tap(find.text('Gửi mã xác thực'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Xác thực đặt lại mật khẩu'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('Mã xác thực 8 ký tự'), findsOneWidget);
    expect(find.text('8 ký tự chữ và số (VD: 47285BAF)'), findsOneWidget);
    expect(find.text('Xác nhận mã & Đặt lại mật khẩu'), findsOneWidget);
    expect(find.textContaining('Gửi lại mã sau'), findsOneWidget);

    cubit.cancelCountdown();
  });

  testWidgets('ForgotPasswordScreen OTP step verifies code and transitions to New Password step', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestWidget(fakeRepo: fakeRepo, cubit: cubit));
    await tester.pump();

    // Step 1: Submit email
    await tester.enterText(find.byType(TextField), 'test@example.com');
    await tester.pump();
    await tester.tap(find.text('Gửi mã xác thực'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Step 2: Enter 8-char OTP (auto-completes via OtpInputField)
    final hiddenOtpField = find.byType(TextField).first;
    await tester.enterText(hiddenOtpField, '47285BAF');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Step 3: Automatically on Set New Password step
    expect(find.text('Đặt lại mật khẩu mới'), findsOneWidget);
    expect(find.text('Mật khẩu mới'), findsOneWidget);
    expect(find.text('Xác nhận mật khẩu mới'), findsOneWidget);
    expect(find.text('Lưu mật khẩu mới & Đăng nhập'), findsOneWidget);

    cubit.cancelCountdown();
  });

  testWidgets('ForgotPasswordScreen completes reset and navigates back to auth', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestWidget(fakeRepo: fakeRepo, cubit: cubit));
    await tester.pump();

    // Go to OTP
    await tester.enterText(find.byType(TextField), 'test@example.com');
    await tester.pump();
    await tester.tap(find.text('Gửi mã xác thực'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Go to New Password (auto completes on 8th character)
    await tester.enterText(find.byType(TextField).first, '47285BAF');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Enter new password & confirm
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'NewPass123');
    await tester.enterText(textFields.at(1), 'NewPass123');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Lưu mật khẩu mới & Đăng nhập'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify redirected to Auth Login Screen
    expect(find.text('Auth Login Screen'), findsOneWidget);
    expect(find.textContaining('Đặt lại mật khẩu thành công'), findsOneWidget);

    cubit.cancelCountdown();
  });

  testWidgets('ForgotPasswordScreen back button on OTP step returns to Email step', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestWidget(fakeRepo: fakeRepo, cubit: cubit));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'test@example.com');
    await tester.pump();
    await tester.tap(find.text('Gửi mã xác thực'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap top back button
    final backBtn = find.byIcon(Icons.arrow_back_ios_new);
    await tester.tap(backBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Quên mật khẩu'), findsOneWidget);

    cubit.cancelCountdown();
  });

  testWidgets('ForgotPasswordScreen renders on narrow 320px width without overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320 * 2.0, 640 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget(fakeRepo: fakeRepo, cubit: cubit));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Check step 1
    expect(tester.takeException(), isNull);

    // Go to step 2 (8 OTP cells)
    await tester.enterText(find.byType(TextField), 'test@example.com');
    await tester.pump();
    await tester.tap(find.text('Gửi mã xác thực'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.text('Xác thực đặt lại mật khẩu'), findsOneWidget);

    cubit.cancelCountdown();
  });
}
