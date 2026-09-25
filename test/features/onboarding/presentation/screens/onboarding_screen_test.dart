import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/storage/app_preferences.dart';
import 'package:group_spending_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('OnboardingScreen renders slides with corresponding SVG assets',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await AppPreferences.init();

    await tester.pumpWidget(
      RepositoryProvider<AppPreferences>.value(
        value: prefs,
        child: const MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );

    // Verify slide 1: Group Management
    expect(find.text('KẾT NỐI & QUẢN LÝ NHÓM'), findsOneWidget);
    expect(find.text('QUẢN LÝ NHÓM'), findsOneWidget);
    expect(find.text('Bỏ qua'), findsOneWidget);
    expect(find.byType(SvgPicture), findsWidgets);

    final nextButton = find.byType(GestureDetector).last;

    // Advance to slide 2: Expense Management
    await tester.tap(nextButton);
    await tester.pumpAndSettle();
    expect(find.text('QUẢN LÝ CHI TIÊU THÔNG MINH'), findsOneWidget);
    expect(find.text('QUẢN LÝ CHI TIÊU'), findsOneWidget);

    // Advance to slide 3: Fund Management
    await tester.tap(nextButton);
    await tester.pumpAndSettle();
    expect(find.text('QUẢN LÝ QUỸ CHUNG MINH BẠCH'), findsOneWidget);
    expect(find.text('QUẢN LÝ QUỸ CHUNG'), findsOneWidget);

    // Advance to slide 4: Reminder & Settlement
    await tester.tap(nextButton);
    await tester.pumpAndSettle();
    expect(find.text('NHẮC NỢ & THANH TOÁN TỐC ĐỘ'), findsOneWidget);
    expect(find.text('NHẮC NỢ & THANH TOÁN'), findsOneWidget);
  });
}
