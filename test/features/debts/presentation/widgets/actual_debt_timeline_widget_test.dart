import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/debts/domain/entities/debt_enums.dart';
import 'package:group_spending_app/features/debts/domain/entities/group_debt_entity.dart';
import 'package:group_spending_app/features/debts/presentation/widgets/actual_debt_timeline_widget.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

void main() {
  group('ActualDebtTimelineWidget Tests', () {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final yesterdayStr = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)));

    final debtToday = ActualDebtEntity(
      expenseId: 1,
      title: 'Lẩu Haidilao trưa nay',
      categoryName: 'Ăn uống',
      totalAmount: 1200,
      totalAmountVnd: 1200000,
      expenseDate: todayStr,
      createdAt: '${todayStr}T12:30:00Z',
      paidByUserId: 1,
      paidByUserName: 'Minh',
      isPaidByMe: true,
      debtorCount: 2,
      debtors: const [
        ActualDebtorEntity(
          splitId: 11,
          userId: 2,
          name: 'An',
          amountVnd: 400000,
          status: DebtStatus.settled,
          action: DebtAction.none,
        ),
        ActualDebtorEntity(
          splitId: 12,
          userId: 3,
          name: 'Bình',
          amountVnd: 400000,
          status: DebtStatus.pending,
          action: DebtAction.remind,
        ),
      ],
    );

    final debtYesterday = ActualDebtEntity(
      expenseId: 2,
      title: 'Cafe Highlands hôm qua',
      categoryName: 'Cafe',
      totalAmount: 150,
      totalAmountVnd: 150000,
      expenseDate: yesterdayStr,
      createdAt: '${yesterdayStr}T15:00:00Z',
      paidByUserId: 2,
      paidByUserName: 'An',
      isPaidByMe: false,
      debtorCount: 1,
      debtors: const [
        ActualDebtorEntity(
          splitId: 21,
          userId: 1,
          name: 'Minh',
          amountVnd: 75000,
          status: DebtStatus.waitingForConfirmation,
          action: DebtAction.confirm,
        ),
      ],
    );

    final debtPastSettled = ActualDebtEntity(
      expenseId: 3,
      title: 'Xem phim tuần trước',
      categoryName: 'Giải trí',
      totalAmount: 300,
      totalAmountVnd: 300000,
      expenseDate: '2026-09-01',
      createdAt: '2026-09-01T20:00:00Z',
      paidByUserId: 1,
      paidByUserName: 'Minh',
      isPaidByMe: true,
      debtorCount: 1,
      debtors: const [
        ActualDebtorEntity(
          splitId: 31,
          userId: 2,
          name: 'An',
          amountVnd: 150000,
          status: DebtStatus.settled,
          action: DebtAction.none,
        ),
      ],
    );

    Widget createWidgetUnderTest({
      required List<ActualDebtEntity> debts,
      Locale locale = const Locale('vi'),
      void Function(ActualDebtorEntity)? onDebtorTap,
      void Function(ActualDebtorEntity)? onDebtorRemind,
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ActualDebtTimelineWidget(
              debts: debts,
              onDebtorTap: onDebtorTap,
              onDebtorRemind: onDebtorRemind,
            ),
          ),
        ),
      );
    }

    testWidgets('renders empty shrink widget when debts list is empty', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(debts: []));
      await tester.pumpAndSettle();

      expect(find.byType(ActualDebtTimelineWidget), findsOneWidget);
      expect(find.byType(IntrinsicHeight), findsNothing);
    });

    testWidgets('groups debts chronologically by date headers', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        debts: [debtYesterday, debtToday, debtPastSettled],
      ));
      await tester.pumpAndSettle();

      // Check date headers
      expect(find.textContaining('Hôm nay'), findsOneWidget);
      expect(find.textContaining('Hôm qua'), findsOneWidget);
      expect(find.text('01/09/2026'), findsOneWidget);

      // Check daily bill count chips
      expect(find.text('1 hóa đơn'), findsNWidgets(3));

      // Check daily total VND amounts
      expect(find.text('Tổng: 1.200.000 đ'), findsOneWidget);
      expect(find.text('Tổng: 150.000 đ'), findsOneWidget);
      expect(find.text('Tổng: 300.000 đ'), findsOneWidget);

      // Check expense titles
      expect(find.text('Lẩu Haidilao trưa nay'), findsOneWidget);
      expect(find.text('Cafe Highlands hôm qua'), findsOneWidget);
      expect(find.text('Xem phim tuần trước'), findsOneWidget);
    });

    testWidgets('renders in English when locale is en', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        debts: [debtToday, debtYesterday],
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('Today'), findsOneWidget);
      expect(find.textContaining('Yesterday'), findsOneWidget);
      expect(find.text('1 bills'), findsNWidgets(2));
      expect(find.text('Total: 1.200.000 đ'), findsOneWidget);
    });

    testWidgets('forwards debtor tap callback when debtor is tapped', (tester) async {
      ActualDebtorEntity? tappedDebtor;

      await tester.pumpWidget(createWidgetUnderTest(
        debts: [debtToday],
        onDebtorTap: (debtor) {
          tappedDebtor = debtor;
        },
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('An'));
      await tester.pumpAndSettle();

      expect(tappedDebtor, isNotNull);
      expect(tappedDebtor?.name, 'An');
      expect(tappedDebtor?.amountVnd, 400000);
    });

    testWidgets('renders in English on narrow 360px screen with text scaling without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 640),
            textScaler: TextScaler.linear(1.25),
          ),
          child: createWidgetUnderTest(
            debts: [debtToday, debtYesterday],
            locale: const Locale('en'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('TOTAL EXPENSE'), findsNWidgets(2));
      expect(find.text('ALLOCATION BY MEMBER:'), findsNWidgets(2));
    });
  });
}
