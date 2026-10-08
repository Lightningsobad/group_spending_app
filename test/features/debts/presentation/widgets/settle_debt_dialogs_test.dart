import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/debts/presentation/widgets/settle_debt_dialogs.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';

void main() {
  group('SettleDebtDialogs Tests', () {
    Widget buildTestHost({required WidgetBuilder builder}) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(builder: builder),
        ),
      );
    }

    testWidgets('showNoBankInfoAlert displays dialog with creditor name and closes on tap', (tester) async {
      await tester.pumpWidget(
        buildTestHost(
          builder: (context) => ElevatedButton(
            onPressed: () {
              SettleDebtDialogs.showNoBankInfoAlert(
                context,
                creditorName: 'Nguyễn Văn A',
              );
            },
            child: const Text('Show Dialog'),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Chưa có thông tin thanh toán'), findsOneWidget);
      expect(
        find.textContaining('Nguyễn Văn A chưa cập nhật thông tin số tài khoản và ngân hàng'),
        findsOneWidget,
      );

      final closeBtn = find.text('Đóng');
      expect(closeBtn, findsOneWidget);

      await tester.tap(closeBtn);
      await tester.pumpAndSettle();

      expect(find.text('Chưa có thông tin thanh toán'), findsNothing);
    });

    testWidgets('showPayConfirm displays confirmation and returns true on confirm', (tester) async {
      bool? result;

      await tester.pumpWidget(
        buildTestHost(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await SettleDebtDialogs.showPayConfirm(
                context,
                creditorName: 'Trần Thị B',
                formattedAmount: '150.000 đ',
              );
            },
            child: const Text('Show Pay Confirm'),
          ),
        ),
      );

      await tester.tap(find.text('Show Pay Confirm'));
      await tester.pumpAndSettle();

      expect(find.text('Xác nhận đã thanh toán'), findsOneWidget);
      expect(
        find.textContaining('Bạn đã chuyển khoản hoặc trả tiền mặt cho Trần Thị B số tiền 150.000 đ?'),
        findsOneWidget,
      );

      await tester.tap(find.text('Xác nhận'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });
  });
}
