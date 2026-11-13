import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/features/groups/presentation/widgets/qr_code_widget.dart';

void main() {
  group('QrCodeWidget Tests', () {
    testWidgets('renders CustomPaint with QrCodePainter for valid invite code', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QrCodeWidget(
              data: 'SUN402-VIP',
              size: 200,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomPaint), findsWidgets);
      final customPaint = tester.widget<CustomPaint>(
        find.byWidgetPredicate((w) => w is CustomPaint && w.painter is QrCodePainter),
      );
      expect(customPaint.painter, isA<QrCodePainter>());
    });

    testWidgets('renders fallback icon when data is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QrCodeWidget(
              data: '',
              size: 200,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.qr_code), findsOneWidget);
    });
  });
}
