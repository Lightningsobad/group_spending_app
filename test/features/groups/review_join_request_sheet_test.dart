import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/groups/data/models/group_member_models.dart';
import 'package:group_spending_app/features/groups/presentation/widgets/review_join_request_sheet.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';

void main() {
  group('ReviewJoinRequestSheet Widget Tests', () {
    const testRequest = GroupJoinRequestModel(
      id: 10,
      groupId: 1,
      groupName: 'Chung cư Sunrise Room',
      userId: 5,
      userFullName: 'Phan Hoàng Nam',
      userEmail: 'nam@example.com',
      userAvatarUrl: null,
      status: 'PENDING',
      requestedAt: '2026-03-30',
    );

    Widget createWidgetUnderTest({
      required Future<void> Function(bool includePastFunds) onConfirm,
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ReviewJoinRequestSheet(
            request: testRequest,
            onConfirm: onConfirm,
          ),
        ),
      );
    }

    testWidgets('renders title, checkbox, and 48px action buttons', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        onConfirm: (_) async {},
      ));
      await tester.pumpAndSettle();

      expect(find.text('Chấp thuận cho Phan Hoàng Nam tham gia nhóm?'), findsOneWidget);
      expect(find.text('Yêu cầu đóng các đợt quỹ trước đây của nhóm'), findsOneWidget);

      final cancelButtonFinder = find.widgetWithText(OutlinedButton, 'Hủy');
      expect(cancelButtonFinder, findsOneWidget);
      expect(tester.getSize(cancelButtonFinder).height, greaterThanOrEqualTo(48.0));

      final confirmButtonFinder = find.widgetWithText(ElevatedButton, 'Xác nhận duyệt');
      expect(confirmButtonFinder, findsOneWidget);
      expect(tester.getSize(confirmButtonFinder).height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('taps checkbox card to toggle includePastFunds and confirms', (tester) async {
      bool? confirmedWithPastFunds;

      await tester.pumpWidget(createWidgetUnderTest(
        onConfirm: (includePastFunds) async {
          confirmedWithPastFunds = includePastFunds;
        },
      ));
      await tester.pumpAndSettle();

      // Tap whole card containing hint
      await tester.tap(find.text('Yêu cầu đóng các đợt quỹ trước đây của nhóm'));
      await tester.pumpAndSettle();

      // Tap confirm button
      await tester.tap(find.text('Xác nhận duyệt'));
      await tester.pumpAndSettle();

      expect(confirmedWithPastFunds, isTrue);
    });
  });
}
