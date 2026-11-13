import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/session/session_coordinator.dart';
import 'package:group_spending_app/core/storage/app_preferences.dart';
import 'package:group_spending_app/core/storage/token_storage.dart';
import 'package:group_spending_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/presentation/cubit/auth_cubit_test.dart';

void main() {
  testWidgets('FairShareApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await AppPreferences.init();
    final tokenStorage = TokenStorage();

    await tester.pumpWidget(
      FairShareApp(appPreferences: prefs, tokenStorage: tokenStorage),
    );

    // Verify FairShare title appears on splash screen
    expect(find.text('FairShare'), findsOneWidget);
    expect(
      find.text('Chia tiền minh bạch & nhắc nợ thông minh'),
      findsOneWidget,
    );
  });

  testWidgets('FairShareApp full flow: login navigates to dashboard', (
    WidgetTester tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    final prefs = await AppPreferences.init();
    final tokenStorage = TokenStorage();
    final sessionCoordinator = SessionCoordinator(tokenStorage: tokenStorage);
    final fakeRepo = FakeAuthRepository(sessionCoordinator: sessionCoordinator);

    await tester.pumpWidget(
      FairShareApp(
        appPreferences: prefs,
        tokenStorage: tokenStorage,
        sessionCoordinator: sessionCoordinator,
        authRepository: fakeRepo,
      ),
    );

    // Initial splash
    expect(find.text('FairShare'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(milliseconds: 1600));

    // Now on Auth screen
    expect(find.text('Đăng nhập vào ứng dụng'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');

    final loginBtn = find.text('Đăng nhập vào ứng dụng');
    await tester.ensureVisible(loginBtn);
    await tester.tap(loginBtn);
    await tester.pumpAndSettle();

    // Verify arrived on Main Shell and tap Settings tab to access logout
    expect(find.text('Tổng quan'), findsAtLeastNWidgets(1));
    await tester.tap(find.text('Cài đặt'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Đăng xuất'), findsOneWidget);
  });
}
