import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/shared/widgets/app_snack_bar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  Widget buildTestApp({
    ThemeMode themeMode = ThemeMode.light,
    required WidgetBuilder bodyBuilder,
  }) {
    return MaterialApp(
      themeMode: themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        body: Builder(builder: bodyBuilder),
      ),
    );
  }

  testWidgets('AppSnackBar.showSuccess renders message, title and check icon', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        bodyBuilder: (context) => ElevatedButton(
          onPressed: () {
            AppSnackBar.showSuccess(
              context,
              'Kích hoạt tài khoản thành công',
              title: 'Thành công',
            );
          },
          child: const Text('Show Success'),
        ),
      ),
    );

    await tester.tap(find.text('Show Success'));
    await tester.pumpAndSettle();

    expect(find.text('Kích hoạt tài khoản thành công'), findsOneWidget);
    expect(find.text('Thành công'), findsOneWidget);
    expect(find.byIcon(LucideIcons.checkCircle2), findsOneWidget);
    expect(find.byIcon(LucideIcons.x), findsOneWidget);

    // Tap close button dismisses it
    await tester.tap(find.byIcon(LucideIcons.x));
    await tester.pumpAndSettle();
    expect(find.text('Kích hoạt tài khoản thành công'), findsNothing);
  });

  testWidgets('AppSnackBar.showError renders message and alertCircle icon', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        bodyBuilder: (context) => ElevatedButton(
          onPressed: () {
            AppSnackBar.showError(
              context,
              'Mật khẩu không chính xác',
            );
          },
          child: const Text('Show Error'),
        ),
      ),
    );

    await tester.tap(find.text('Show Error'));
    await tester.pumpAndSettle();

    expect(find.text('Mật khẩu không chính xác'), findsOneWidget);
    expect(find.byIcon(LucideIcons.alertCircle), findsOneWidget);
  });

  testWidgets('AppSnackBar.showWarning renders message and alertTriangle icon', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        bodyBuilder: (context) => ElevatedButton(
          onPressed: () {
            AppSnackBar.showWarning(
              context,
              'Vui lòng nhập đầy đủ thông tin',
            );
          },
          child: const Text('Show Warning'),
        ),
      ),
    );

    await tester.tap(find.text('Show Warning'));
    await tester.pumpAndSettle();

    expect(find.text('Vui lòng nhập đầy đủ thông tin'), findsOneWidget);
    expect(find.byIcon(LucideIcons.alertTriangle), findsOneWidget);
  });

  testWidgets('AppSnackBar.showInfo renders message and info icon in dark mode', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        themeMode: ThemeMode.dark,
        bodyBuilder: (context) => ElevatedButton(
          onPressed: () {
            AppSnackBar.showInfo(
              context,
              'Hệ thống đang bảo trì',
            );
          },
          child: const Text('Show Info'),
        ),
      ),
    );

    await tester.tap(find.text('Show Info'));
    await tester.pumpAndSettle();

    expect(find.text('Hệ thống đang bảo trì'), findsOneWidget);
    expect(find.byIcon(LucideIcons.info), findsOneWidget);
  });

  testWidgets('AppSnackBar hides previous snackbar when showing a new one', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        bodyBuilder: (context) => Column(
          children: [
            ElevatedButton(
              onPressed: () {
                AppSnackBar.showWarning(context, 'Thông báo đầu tiên');
              },
              child: const Text('First'),
            ),
            ElevatedButton(
              onPressed: () {
                AppSnackBar.showSuccess(context, 'Thông báo thứ hai');
              },
              child: const Text('Second'),
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('First'));
    await tester.pumpAndSettle();
    expect(find.text('Thông báo đầu tiên'), findsOneWidget);

    await tester.tap(find.text('Second'));
    await tester.pumpAndSettle();
    expect(find.text('Thông báo thứ hai'), findsOneWidget);
    expect(find.text('Thông báo đầu tiên'), findsNothing);
  });
}
