import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/groups/data/models/group_model.dart';
import 'package:group_spending_app/features/groups/presentation/widgets/group_invite_qr_sheet.dart';
import 'package:group_spending_app/features/groups/presentation/widgets/qr_code_widget.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';

void main() {
  group('GroupInviteQrSheet Widget Tests', () {
    const testGroup = GroupModel(
      id: 1,
      name: 'Chung cư Sunrise Room',
      category: 'Apartment',
      inviteCode: 'SUN402-VIP',
      memberCount: 5,
      ownerId: 1,
    );

    Widget createWidgetUnderTest() {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: GroupInviteQrSheet(group: testGroup),
        ),
      );
    }

    testWidgets('renders header, tabs, QR code and invite code correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Header title
      expect(find.text('Mời thành viên vào nhóm'), findsOneWidget);
      expect(find.textContaining('Chung cư Sunrise Room'), findsWidgets);

      // Mode tabs
      expect(find.text('Mã QR Code'), findsOneWidget);
      expect(find.text('Sao chép mã mời'), findsWidgets);

      // QR Code widget
      expect(find.byType(QrCodeWidget), findsOneWidget);

      // Invite code SUN402-VIP
      expect(find.text('SUN402-VIP'), findsOneWidget);

      // Action buttons
      expect(find.text('Tải ảnh mã QR'), findsOneWidget);
      expect(find.text('Chia sẻ qua ứng dụng khác'), findsOneWidget);
      expect(find.text('Đóng'), findsOneWidget);
    });

    testWidgets('switching between tabs updates state', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap on Tab "Sao chép mã mời"
      final copyTab = find.text('Sao chép mã mời').first;
      await tester.tap(copyTab);
      await tester.pumpAndSettle();

      // Tap on Tab "Mã QR Code"
      await tester.tap(find.text('Mã QR Code'));
      await tester.pumpAndSettle();

      expect(find.byType(QrCodeWidget), findsOneWidget);
    });

    testWidgets('tapping copy invite code copies to clipboard', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final List<MethodCall> log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
        log.add(methodCall);
        return null;
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap copy button at bottom banner
      final copyButton = find.text('Sao chép mã mời').last;
      await tester.ensureVisible(copyButton);
      await tester.pumpAndSettle();
      await tester.tap(copyButton);
      await tester.pumpAndSettle();

      final setClipboardCall = log.firstWhere((call) => call.method == 'Clipboard.setData');
      expect(setClipboardCall.arguments['text'], 'SUN402-VIP');
    });
  });
}
