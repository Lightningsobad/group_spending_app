import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/debts/domain/entities/debt_enums.dart';
import 'package:group_spending_app/features/debts/domain/entities/group_debt_entity.dart';
import 'package:group_spending_app/features/debts/presentation/widgets/actual_debt_card_widget.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';

void main() {
  group('ActualDebtCardWidget Remediation Tests (DEBT-03)', () {
    final testDebt = ActualDebtEntity(
      expenseId: 1,
      title: 'Lẩu Haidilao cuối tuần',
      totalAmountVnd: 320000,
      paidByUserId: 1,
      paidByUserName: 'Nguyễn Nhật Minh',
      isPaidByMe: true,
      debtorCount: 1,
      debtors: const [
        ActualDebtorEntity(
          splitId: 103,
          userId: 4,
          name: 'Linh',
          amountVnd: 320000,
          status: DebtStatus.waitingForConfirmation,
          action: DebtAction.confirm,
        ),
      ],
    );

    Widget createWidgetUnderTest({
      ActualDebtEntity? debt,
      void Function(ActualDebtorEntity debtor, bool confirmed)? onDebtorConfirm,
      bool isSubmitting = false,
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ActualDebtCardWidget(
              debt: debt ?? testDebt,
              onDebtorConfirm: onDebtorConfirm,
              isSubmitting: isSubmitting,
            ),
          ),
        ),
      );
    }

    testWidgets('03-A: Creditor selects "Xác nhận nhận tiền", confirms -> calls onDebtorConfirm(debtor, true)', (tester) async {
      ActualDebtorEntity? confirmedDebtor;
      bool? confirmStatus;

      await tester.pumpWidget(createWidgetUnderTest(
        onDebtorConfirm: (debtor, confirmed) {
          confirmedDebtor = debtor;
          confirmStatus = confirmed;
        },
      ));
      await tester.pumpAndSettle();

      // Tap on debtor row
      await tester.tap(find.text('Linh'));
      await tester.pumpAndSettle();

      // Choice dialog should appear with options: "Xác nhận nhận tiền" and "Từ chối"
      expect(find.text('Xác nhận nhận tiền'), findsWidgets);
      expect(find.text('Từ chối'), findsOneWidget);

      // Select "Xác nhận nhận tiền" in the choice dialog
      await tester.tap(find.widgetWithText(ElevatedButton, 'Xác nhận nhận tiền'));
      await tester.pumpAndSettle();

      // Second confirmation dialog appears
      expect(find.text('Xác nhận'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Xác nhận'));
      await tester.pumpAndSettle();

      expect(confirmedDebtor, isNotNull);
      expect(confirmedDebtor?.name, 'Linh');
      expect(confirmStatus, isTrue);
    });

    testWidgets('03-B: Creditor selects "Từ chối", confirms -> calls onDebtorConfirm(debtor, false)', (tester) async {
      ActualDebtorEntity? confirmedDebtor;
      bool? confirmStatus;

      await tester.pumpWidget(createWidgetUnderTest(
        onDebtorConfirm: (debtor, confirmed) {
          confirmedDebtor = debtor;
          confirmStatus = confirmed;
        },
      ));
      await tester.pumpAndSettle();

      // Tap on debtor row
      await tester.tap(find.text('Linh'));
      await tester.pumpAndSettle();

      // Select "Từ chối" in choice dialog
      await tester.tap(find.widgetWithText(OutlinedButton, 'Từ chối'));
      await tester.pumpAndSettle();

      // Reject confirmation dialog appears
      expect(find.text('Từ chối nhận tiền'), findsOneWidget);
      expect(find.text('Xác nhận'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Xác nhận'));
      await tester.pumpAndSettle();

      expect(confirmedDebtor, isNotNull);
      expect(confirmedDebtor?.name, 'Linh');
      expect(confirmStatus, isFalse);
    });

    testWidgets('03-C: Cancel on choice dialog -> does not call onDebtorConfirm', (tester) async {
      bool called = false;

      await tester.pumpWidget(createWidgetUnderTest(
        onDebtorConfirm: (debtor, confirmed) {
          called = true;
        },
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Linh'));
      await tester.pumpAndSettle();

      // Cancel choice dialog
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();

      expect(called, isFalse);
    });

    testWidgets('03-F: isSubmitting = true prevents tap action', (tester) async {
      bool called = false;

      await tester.pumpWidget(createWidgetUnderTest(
        onDebtorConfirm: (debtor, confirmed) {
          called = true;
        },
        isSubmitting: true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Linh'));
      await tester.pumpAndSettle();

      // Choice dialog should NOT appear
      expect(find.text('Từ chối'), findsNothing);
      expect(called, isFalse);
    });
  });
}
