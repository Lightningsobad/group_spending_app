import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/debts/domain/entities/debt_enums.dart';
import 'package:group_spending_app/features/debts/domain/entities/group_debt_entity.dart';
import 'package:group_spending_app/features/debts/presentation/widgets/actual_debt_card_widget.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';

void main() {
  group('ActualDebtCardWidget Tests', () {
    final testDebt = ActualDebtEntity(
      expenseId: 1,
      title: 'Lẩu Haidilao cuối tuần',
      categoryName: 'Ăn uống',
      totalAmount: 1280,
      totalAmountVnd: 1280000,
      expenseDate: '2026-09-10',
      createdAt: '2026-09-10T19:30:00Z',
      paidByUserId: 1,
      paidByUserName: 'Nguyễn Nhật Minh',
      isPaidByMe: true,
      debtorCount: 3,
      debtors: const [
        ActualDebtorEntity(
          splitId: 101,
          userId: 2,
          name: 'An',
          amount: 320,
          amountVnd: 320000,
          status: DebtStatus.settled,
          action: DebtAction.none,
        ),
        ActualDebtorEntity(
          splitId: 102,
          userId: 3,
          name: 'Hương',
          amount: 320,
          amountVnd: 320000,
          status: DebtStatus.pending,
          action: DebtAction.remind,
        ),
        ActualDebtorEntity(
          splitId: 103,
          userId: 4,
          name: 'Linh',
          amount: 320,
          amountVnd: 320000,
          status: DebtStatus.waitingForConfirmation,
          action: DebtAction.confirm,
        ),
      ],
    );

    Widget createWidgetUnderTest({
      ActualDebtEntity? debt,
      void Function(ActualDebtorEntity)? onDebtorTap,
      void Function(ActualDebtorEntity)? onDebtorRemind,
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
              onDebtorTap: onDebtorTap,
              onDebtorRemind: onDebtorRemind,
            ),
          ),
        ),
      );
    }

    testWidgets('renders all card details matching screenshot', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Category chip & Date
      expect(find.text('Ăn uống'), findsOneWidget);
      expect(find.text('10/09/2026 - 19:30'), findsOneWidget);

      // Total expense
      expect(find.text('TỔNG CHI'), findsOneWidget);
      expect(find.text('1.280.000 đ'), findsOneWidget);

      // Title & Payer
      expect(find.text('Lẩu Haidilao cuối tuần'), findsOneWidget);
      expect(find.textContaining('Nguyễn Nhật Minh (Bạn)'), findsOneWidget);

      // Allocation section header
      expect(find.text('PHÂN BỐ THEO THÀNH VIÊN:'), findsOneWidget);
      expect(find.text('3 người nợ'), findsOneWidget);

      // Debtors
      expect(find.text('An'), findsOneWidget);
      expect(find.text('Hương'), findsOneWidget);
      expect(find.text('Linh'), findsOneWidget);
      expect(find.text('320k'), findsNWidgets(3));
    });

    testWidgets('tapping on debtor triggers callback', (tester) async {
      ActualDebtorEntity? tappedDebtor;

      await tester.pumpWidget(createWidgetUnderTest(
        onDebtorTap: (debtor) {
          tappedDebtor = debtor;
        },
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hương'));
      await tester.pumpAndSettle();

      expect(tappedDebtor, isNotNull);
      expect(tappedDebtor?.name, 'Hương');
      expect(tappedDebtor?.splitId, 102);
    });
  });
}
