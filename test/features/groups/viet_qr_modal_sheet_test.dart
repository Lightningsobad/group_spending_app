import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/groups/presentation/widgets/viet_qr_modal_sheet.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';

void main() {
  group('VietQrModalSheet Widget Tests', () {
    Widget buildSheet({
      required String bankName,
      required String accountNumber,
      required String accountName,
      num? amount,
      String? note,
      VoidCallback? onPaidConfirmed,
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: VietQrModalSheet(
            bankName: bankName,
            accountNumber: accountNumber,
            accountName: accountName,
            amount: amount,
            note: note,
            onPaidConfirmed: onPaidConfirmed,
          ),
        ),
      );
    }

    testWidgets('renders basic bank info without amount or note', (tester) async {
      await tester.pumpWidget(
        buildSheet(
          bankName: 'MBBank',
          accountNumber: '0987654321',
          accountName: 'NGUYEN VAN A',
        ),
      );
      await tester.pump();

      expect(find.text('MBBank'), findsOneWidget);
      expect(find.text('0987654321'), findsWidgets);
      expect(find.text('NGUYEN VAN A'), findsOneWidget);
      expect(find.text('Số tiền thanh toán'), findsNothing);
      expect(find.text('Nội dung chuyển khoản'), findsNothing);
      expect(find.text('Tôi đã chuyển khoản'), findsNothing);
    });

    testWidgets('renders payment amount, note, and confirm button when provided', (tester) async {
      bool paidConfirmedCalled = false;

      await tester.pumpWidget(
        buildSheet(
          bankName: 'Techcombank',
          accountNumber: '19034829104018',
          accountName: 'TRAN THI B',
          amount: 250000,
          note: 'An tra no nhom Da Lat',
          onPaidConfirmed: () {
            paidConfirmedCalled = true;
          },
        ),
      );
      await tester.pump();

      expect(find.text('Techcombank'), findsOneWidget);
      expect(find.text('19034829104018'), findsWidgets);
      expect(find.text('TRAN THI B'), findsOneWidget);

      // Amount row
      expect(find.text('Số tiền thanh toán'), findsOneWidget);
      expect(find.text('250.000 đ'), findsOneWidget);

      // Note row
      expect(find.text('Nội dung chuyển khoản'), findsOneWidget);
      expect(find.text('An tra no nhom Da Lat'), findsOneWidget);

      // Confirm button
      final confirmBtn = find.text('Tôi đã chuyển khoản');
      expect(confirmBtn, findsOneWidget);

      // Verify QR Image URL contains amount and addInfo
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);
      final imageWidget = tester.widget<Image>(imageFinder);
      expect(imageWidget.image, isA<NetworkImage>());
      final networkImage = imageWidget.image as NetworkImage;
      expect(networkImage.url, contains('amount=250000'));
      expect(networkImage.url, contains('addInfo=An%20tra%20no%20nhom%20Da%20Lat'));

      // Tap confirm button
      await tester.ensureVisible(confirmBtn);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      expect(paidConfirmedCalled, isTrue);
    });
  });
}
