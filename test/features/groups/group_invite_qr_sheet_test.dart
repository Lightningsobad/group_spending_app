import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/core/theme/app_theme_colors.dart';
import 'package:group_spending_app/features/groups/data/models/group_model.dart';
import 'package:group_spending_app/features/groups/presentation/widgets/group_invite_qr_sheet.dart';
import 'package:group_spending_app/features/groups/presentation/widgets/qr_code_widget.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';
import 'package:group_spending_app/shared/widgets/app_shimmer.dart';

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

    Widget createWidgetUnderTest({
      GroupModel group = testGroup,
      bool isLoading = false,
      ThemeData? theme,
      TextScaler? textScaler,
    }) {
      return MaterialApp(
        theme: theme ?? AppTheme.lightTheme,
        locale: const Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final mediaQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: textScaler ?? TextScaler.noScaling,
                ),
                child: GroupInviteQrSheet(
                  group: group,
                  isLoading: isLoading,
                ),
              );
            },
          ),
        ),
      );
    }

    testWidgets('renders header with SVG icon, tabs, QR code on Tab 0 (no code banner on Tab 0)', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Header title and group information
      expect(find.text('Mời thành viên vào nhóm'), findsOneWidget);
      expect(find.textContaining('Chung cư Sunrise Room'), findsWidgets);
      expect(find.textContaining('5 thành viên'), findsOneWidget);

      // Category icon for Apartment category
      expect(find.byIcon(LucideIcons.home), findsOneWidget);

      // Mode tabs: titles present, subtitles removed
      expect(find.text('Mã QR Code'), findsOneWidget);
      expect(find.text('Sao chép mã mời'), findsOneWidget);
      expect(find.text('Quét trực tiếp khi ở cạnh nhau'), findsNothing);
      expect(find.text('Gửi mã văn bản qua tin nhắn, Zalo'), findsNothing);

      // Tab 0 displays QR Code widget & instructions
      expect(find.byType(QrCodeWidget), findsOneWidget);
      expect(find.text('Thành viên quét mã này bằng điện thoại để gửi yêu cầu gia nhập'), findsOneWidget);
      expect(find.byKey(const ValueKey('btn_download_qr')), findsOneWidget);
      expect(find.byKey(const ValueKey('btn_share_qr')), findsOneWidget);

      // Invite code SUN402-VIP is moved off Tab 0
      expect(find.text('SUN402-VIP'), findsNothing);

      // Close button
      expect(find.byKey(const ValueKey('btn_close_sheet')), findsOneWidget);
    });

    testWidgets('switching to Tab 1 reveals invite code card, copy and share buttons', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap on Tab "Sao chép mã mời" via key
      await tester.tap(find.byKey(const ValueKey('tab_copy_code')));
      await tester.pumpAndSettle();

      // Tab 0 QR code is no longer rendered
      expect(find.byType(QrCodeWidget), findsNothing);

      // Tab 1 displays invite code & actions
      expect(find.text('MÃ MỜI THAM GIA NHÓM'), findsOneWidget);
      expect(find.text('SUN402-VIP'), findsOneWidget);
      expect(find.text('Thành viên nhập mã này để gửi yêu cầu gia nhập nhóm'), findsOneWidget);
      expect(find.byKey(const ValueKey('btn_copy_code')), findsOneWidget);
      expect(find.byKey(const ValueKey('btn_share_code')), findsOneWidget);

      // Switch back to Tab 0
      await tester.tap(find.byKey(const ValueKey('tab_qr_code')));
      await tester.pumpAndSettle();

      expect(find.byType(QrCodeWidget), findsOneWidget);
      expect(find.text('SUN402-VIP'), findsNothing);
    });

    testWidgets('tapping copy invite code in Tab 1 copies to clipboard', (tester) async {
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

      // Switch to Tab 1
      await tester.tap(find.byKey(const ValueKey('tab_copy_code')));
      await tester.pumpAndSettle();

      // Tap the copy button on Tab 1
      final copyButton = find.byKey(const ValueKey('btn_copy_code'));
      expect(copyButton, findsOneWidget);
      await tester.tap(copyButton);
      await tester.pumpAndSettle();

      final setClipboardCall = log.firstWhere((call) => call.method == 'Clipboard.setData');
      expect(setClipboardCall.arguments['text'], 'SUN402-VIP');
    });

    testWidgets('renders shimmer skeleton when isLoading is true', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(isLoading: true));
      await tester.pump();

      expect(find.byType(AppShimmer), findsOneWidget);
      expect(find.byType(AppShimmerBox), findsWidgets);
      expect(find.byType(QrCodeWidget), findsNothing);
    });

    testWidgets('interactive buttons have touch targets of at least 48px height', (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tab 0 buttons
      final downloadBtnSize = tester.getSize(find.byKey(const ValueKey('btn_download_qr')));
      expect(downloadBtnSize.height, greaterThanOrEqualTo(48.0));

      final shareBtnSize = tester.getSize(find.byKey(const ValueKey('btn_share_qr')));
      expect(shareBtnSize.height, greaterThanOrEqualTo(48.0));

      final closeBtnSize = tester.getSize(find.byKey(const ValueKey('btn_close_sheet')));
      expect(closeBtnSize.height, greaterThanOrEqualTo(48.0));

      // Switch to Tab 1
      await tester.tap(find.byKey(const ValueKey('tab_copy_code')));
      await tester.pumpAndSettle();

      final copyBtnSize = tester.getSize(find.byKey(const ValueKey('btn_copy_code')));
      expect(copyBtnSize.height, greaterThanOrEqualTo(48.0));

      final shareTextBtnSize = tester.getSize(find.byKey(const ValueKey('btn_share_code')));
      expect(shareTextBtnSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('renders properly under dark theme with high contrast QR card and quiet zone', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(theme: AppTheme.darkTheme));
      await tester.pumpAndSettle();

      final qrCodeWidget = tester.widget<QrCodeWidget>(find.byType(QrCodeWidget));
      expect(qrCodeWidget.backgroundColor, equals(Colors.white));
      expect(qrCodeWidget.color, equals(AppThemeColors.dark.qrCodeForeground));

      // Group name is rendered with dark theme textPrimary (white-ish on dark qrCardBg)
      final nameText = tester.widget<Text>(find.text('Chung cư Sunrise Room'));
      expect(nameText.style?.color, equals(AppThemeColors.dark.textPrimary));

      // Instruction is rendered with dark theme textSecondary
      final instructionFinder = find.text('Thành viên quét mã này bằng điện thoại để gửi yêu cầu gia nhập');
      expect(instructionFinder, findsOneWidget);
      final instructionText = tester.widget<Text>(instructionFinder);
      expect(instructionText.style?.color, equals(AppThemeColors.dark.textSecondary));

      expect(tester.takeException(), isNull);
    });

    testWidgets('adapts cleanly on compact 320px screen with 1.35x textScaler without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest(
        textScaler: const TextScaler.linear(1.35),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(QrCodeWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
