import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/features/auth/presentation/widgets/otp_input_field.dart';

void main() {
  testWidgets('OtpInputField renders 6 boxes by default for numeric OTP', (
    WidgetTester tester,
  ) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    String? completedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OtpInputField(
            controller: controller,
            focusNode: focusNode,
            onCompleted: (val) => completedValue = val,
          ),
        ),
      ),
    );

    // Verify 6 cells
    expect(find.byType(Container), findsWidgets);
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();

    expect(completedValue, '123456');
    expect(find.text('1'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);

    controller.dispose();
    focusNode.dispose();
  });

  testWidgets('OtpInputField renders 8 boxes and auto-capitalizes alphanumeric characters', (
    WidgetTester tester,
  ) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    String? completedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OtpInputField(
            controller: controller,
            focusNode: focusNode,
            length: 8,
            isAlphanumeric: true,
            onCompleted: (val) => completedValue = val,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '47285baf');
    await tester.pump();

    expect(completedValue, '47285BAF');
    expect(find.text('B'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('F'), findsOneWidget);

    controller.dispose();
    focusNode.dispose();
  });
}
