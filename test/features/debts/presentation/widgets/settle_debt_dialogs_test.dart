import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/debts/presentation/widgets/settle_debt_dialogs.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';

void main() {
  group('SettleDebtDialogs Tests', () {
    Widget buildTestHost({
      required WidgetBuilder builder,
      Locale locale = const Locale('vi'),
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        locale: locale,
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

    testWidgets('showRejectSettledDialog uses Vietnamese l10n strings by default', (tester) async {
      String? result;

      await tester.pumpWidget(
        buildTestHost(
          locale: const Locale('vi'),
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await SettleDebtDialogs.showRejectSettledDialog(
                context,
                debtorName: 'Lê Văn C',
              );
            },
            child: const Text('Show Reject Dialog'),
          ),
        ),
      );

      await tester.tap(find.text('Show Reject Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Từ chối nhận tiền'), findsOneWidget);
      expect(
        find.textContaining('Bạn chưa nhận được số tiền này và muốn yêu cầu Lê Văn C kiểm tra lại?'),
        findsOneWidget,
      );
      expect(find.text('Lý do từ chối'), findsOneWidget);
      expect(find.text('Chưa nhận được tiền vào tài khoản ngân hàng'), findsOneWidget);

      await tester.tap(find.text('Xác nhận'));
      await tester.pumpAndSettle();

      expect(result, 'Chưa nhận được tiền vào tài khoản ngân hàng');
    });

    testWidgets('showRejectSettledDialog uses English l10n strings when locale is en', (tester) async {
      String? result;

      await tester.pumpWidget(
        buildTestHost(
          locale: const Locale('en'),
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await SettleDebtDialogs.showRejectSettledDialog(
                context,
                debtorName: 'John',
              );
            },
            child: const Text('Show Reject Dialog EN'),
          ),
        ),
      );

      await tester.tap(find.text('Show Reject Dialog EN'));
      await tester.pumpAndSettle();

      expect(find.text('Decline payment confirmation'), findsOneWidget);
      expect(
        find.textContaining('You have not received this payment and want to ask John to check again?'),
        findsOneWidget,
      );
      expect(find.text('Rejection reason'), findsOneWidget);
      expect(find.text('Have not received money in bank account'), findsOneWidget);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(result, 'Have not received money in bank account');
    });

    testWidgets('showRejectSettledDialog returns custom entered reason', (tester) async {
      String? result;

      await tester.pumpWidget(
        buildTestHost(
          locale: const Locale('vi'),
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await SettleDebtDialogs.showRejectSettledDialog(
                context,
                debtorName: 'Lê Văn C',
              );
            },
            child: const Text('Show Reject Dialog'),
          ),
        ),
      );

      await tester.tap(find.text('Show Reject Dialog'));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Sai số tài khoản chuyển khoản');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Xác nhận'));
      await tester.pumpAndSettle();

      expect(result, 'Sai số tài khoản chuyển khoản');
    });

    testWidgets('showConfirmSettled displays confirm message and returns status', (tester) async {
      bool? result;

      await tester.pumpWidget(
        buildTestHost(
          locale: const Locale('vi'),
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await SettleDebtDialogs.showConfirmSettled(
                context,
                debtorName: 'Lê Văn C',
                formattedAmount: '200.000 đ',
                confirmed: true,
              );
            },
            child: const Text('Show Confirm'),
          ),
        ),
      );

      await tester.tap(find.text('Show Confirm'));
      await tester.pumpAndSettle();

      expect(find.text('Xác nhận nhận tiền'), findsOneWidget);
      expect(find.textContaining('Bạn đã nhận được số tiền 200.000 đ từ Lê Văn C?'), findsOneWidget);

      await tester.tap(find.text('Xác nhận'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('showRemindConfirm displays remind message and returns status', (tester) async {
      bool? result;

      await tester.pumpWidget(
        buildTestHost(
          locale: const Locale('vi'),
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await SettleDebtDialogs.showRemindConfirm(
                context,
                debtorName: 'Lê Văn C',
                formattedAmount: '200.000 đ',
              );
            },
            child: const Text('Show Remind'),
          ),
        ),
      );

      await tester.tap(find.text('Show Remind'));
      await tester.pumpAndSettle();

      expect(find.text('Gửi thông báo nhắc nợ'), findsOneWidget);
      expect(find.textContaining('Gửi thông báo nhắc nhở thanh toán khoản nợ 200.000 đ đến Lê Văn C?'), findsOneWidget);

      await tester.tap(find.text('Xác nhận'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });
  });
}
