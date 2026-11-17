import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/dashboard/presentation/widgets/financial_balance_card.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';

void main() {
  group('FinancialBalanceCard Overflow Tests', () {
    Widget buildCard({
      Locale locale = const Locale('en'),
      double textScaleFactor = 1.0,
      num owed = 663000,
      num receivable = 1500000,
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(
              size: const Size(360, 640),
              textScaler: TextScaler.linear(textScaleFactor),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FinancialBalanceCard(
                  totalOwedVnd: owed,
                  totalReceivableVnd: receivable,
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders in English on 360dp phone without RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(720, 1280);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(buildCard(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(FinancialBalanceCard), findsOneWidget);
    });

    testWidgets('renders in Vietnamese on 360dp phone without RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(720, 1280);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(buildCard(locale: const Locale('vi')));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(FinancialBalanceCard), findsOneWidget);
    });

    testWidgets('renders in English with 1.35x text scale without RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(720, 1280);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(buildCard(locale: const Locale('en'), textScaleFactor: 1.35));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(FinancialBalanceCard), findsOneWidget);
    });
  });
}
