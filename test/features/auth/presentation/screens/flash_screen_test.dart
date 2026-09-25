import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:group_spending_app/core/storage/app_preferences.dart';
import 'package:group_spending_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:group_spending_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:group_spending_app/features/auth/presentation/screens/flash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cubit/auth_cubit_test.dart';

void main() {
  testWidgets('FlashScreen renders logo, title, and loading progress bar',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await AppPreferences.init();
    final fakeRepo = FakeAuthRepository();
    final authCubit = AuthCubit(fakeRepo);

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const FlashScreen(),
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) => const Scaffold(body: Text('Auth Screen')),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) =>
              const Scaffold(body: Text('Onboarding Screen')),
        ),
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
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      ),
    );

    // Verify FairShare branding
    expect(find.text('FairShare'), findsOneWidget);
    expect(
      find.text('Chia tiền minh bạch & nhắc nợ thông minh'),
      findsOneWidget,
    );

    // Verify progress bar with FractionallySizedBox is present
    final fractionallySizedBoxFinder = find.descendant(
      of: find.byType(FlashScreen),
      matching: find.byType(FractionallySizedBox),
    );
    expect(fractionallySizedBoxFinder, findsOneWidget);

    // Check intermediate progress
    await tester.pump(const Duration(milliseconds: 600));
    final FractionallySizedBox sizedBox =
        tester.widget<FractionallySizedBox>(fractionallySizedBoxFinder);
    expect(sizedBox.widthFactor, isNotNull);
    expect(sizedBox.widthFactor!, greaterThan(0.0));
    expect(sizedBox.heightFactor, 1.0);

    // Complete bootstrap lifecycle
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 500));

    // After bootstrap, unauthenticated user is navigated to /auth
    expect(find.text('Auth Screen'), findsOneWidget);
  });
}
